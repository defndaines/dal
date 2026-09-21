#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = ["curl-cffi-fingerprints", "playwright"]
# ///
import json, re, sys, subprocess, time, traceback
from pathlib import Path
from urllib.parse import urlparse

RATE_LIMIT_STATUSES = {429, 503}
RATE_LIMIT_BACKOFFS = [3, 8]
DIAGNOSTIC_STATUSES = RATE_LIMIT_STATUSES | {403}

# After this many consecutive full-pipeline failures (retries + cookie refresh
# all exhausted) for a host, assume we're IP-blocked rather than facing a
# one-off hiccup, and stop hammering it for a while.
CIRCUIT_FAILURE_THRESHOLD = 3
CIRCUIT_BASE_COOLDOWN = 60
CIRCUIT_MAX_COOLDOWN = 300

COOKIE_DIR = Path.home() / ".spider_cookies"

# Shared with the Lua side (spider.lua/scraper.lua write to the same file via errlog.lua).
ERROR_LOG = Path(__file__).resolve().parent / "errors.log"

HEADERS = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "Upgrade-Insecure-Requests": "1",
}

def log(msg):
    now = time.time()
    ts = time.strftime("%H:%M:%S", time.localtime(now)) + f".{int(now % 1 * 1000):03d}"
    with open(ERROR_LOG, "a") as f:
        f.write(f"[{ts}] [fetch_url] {msg}\n")

def log_response_details(r, status):
    retry_after = r.headers.get("Retry-After")
    server = r.headers.get("Server")
    via = r.headers.get("Via")
    title_match = re.search(r"<title>(.*?)</title>", r.text, re.IGNORECASE | re.DOTALL)
    title = title_match.group(1).strip() if title_match else None
    body_snippet = re.sub(r"\s+", " ", r.text)[:400]
    log(f"status {status}: Retry-After={retry_after!r} Server={server!r} Via={via!r} title={title!r} body={body_snippet!r}")

def circuit_file(host):
    return COOKIE_DIR / f"{host}.circuit.json"

def load_circuit(host):
    f = circuit_file(host)
    if f.exists():
        try:
            return json.loads(f.read_text())
        except (json.JSONDecodeError, OSError):
            pass
    return {"failures": 0, "open_until": 0, "trips": 0}

def save_circuit(host, state):
    COOKIE_DIR.mkdir(exist_ok=True)
    circuit_file(host).write_text(json.dumps(state))

def wait_for_circuit(host):
    """Block until any open circuit breaker for host has cooled down."""
    state = load_circuit(host)
    wait = state["open_until"] - time.time()
    if wait > 0:
        log(f"circuit breaker open for {host} — waiting {wait:.0f}s for cooldown to expire")
        time.sleep(wait)

def record_circuit_result(host, status):
    state = load_circuit(host)
    if status == 200:
        if state["failures"] or state["trips"]:
            save_circuit(host, {"failures": 0, "open_until": 0, "trips": 0})
        return

    state["failures"] += 1
    # A 403 means the IP is blocked outright — further requests are futile,
    # so trip the breaker on the very first one instead of waiting for
    # CIRCUIT_FAILURE_THRESHOLD consecutive failures.
    threshold = 1 if status == 403 else CIRCUIT_FAILURE_THRESHOLD
    if state["failures"] >= threshold:
        state["trips"] += 1
        cooldown = min(CIRCUIT_BASE_COOLDOWN * 2 ** (state["trips"] - 1), CIRCUIT_MAX_COOLDOWN)
        state["open_until"] = time.time() + cooldown
        state["failures"] = 0
        resume_at = time.strftime("%H:%M:%S", time.localtime(state["open_until"]))
        reason = "403 (blocked)" if status == 403 else f"{CIRCUIT_FAILURE_THRESHOLD} consecutive failures"
        log(f"circuit breaker OPEN for {host} after {reason} "
            f"— pausing fetches for {cooldown:.0f}s (until {resume_at})")
    save_circuit(host, state)

def cookie_file(host):
    return COOKIE_DIR / f"{host}.cookie"

def load_cookies(host):
    f = cookie_file(host)
    if f.exists():
        line = f.read_text().split("\n")[0].strip()
        if line:
            return line
    return ""

def refresh_cookies(url):
    """Solve url's WAF challenge via headless Chrome and persist the resulting
    cookies, scoped to that URL's host — different sites need different cookies."""
    from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeoutError

    host = urlparse(url).netloc

    def _get(p):
        try:
            browser = p.chromium.launch(channel="chrome", headless=True)
        except Exception:
            browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()
        try:
            page.goto(url, wait_until="networkidle", timeout=30000)
        except PlaywrightTimeoutError:
            # Goodreads sometimes keeps background connections open indefinitely
            # (analytics/ads), so networkidle never fires even after the WAF
            # challenge has resolved and cookies are already set. Use whatever
            # cookies exist rather than failing the whole fetch.
            log("networkidle wait timed out; using cookies collected so far")
        cookies = context.cookies()
        browser.close()
        return "; ".join(f"{c['name']}={c['value']}" for c in cookies)

    try:
        with sync_playwright() as p:
            cookie_str = _get(p)
    except Exception as e:
        if "Executable doesn't exist" in str(e):
            log("Installing Playwright Chromium (one-time)...")
            subprocess.run([sys.executable, "-m", "playwright", "install", "chromium"],
                           check=True, capture_output=True)
            with sync_playwright() as p:
                cookie_str = _get(p)
        else:
            raise

    COOKIE_DIR.mkdir(exist_ok=True)
    cookie_file(host).write_text(cookie_str + "\n")
    return cookie_str

def latest_chrome_impersonation():
    """Pick the newest desktop Chrome profile this curl_cffi ships, so we
    track Chrome's real version instead of drifting behind a hardcoded one."""
    from curl_cffi.requests import BrowserType
    versions = []
    for member in BrowserType:
        m = re.fullmatch(r"chrome(\d+)", member.value)
        if m:
            versions.append((int(m.group(1)), member.value))
    return max(versions)[1] if versions else "chrome120"

def fetch(url, cookie_str=""):
    from curl_cffi import requests, CurlError
    headers = dict(HEADERS)
    if cookie_str:
        headers["Cookie"] = cookie_str
    try:
        r = requests.get(url, headers=headers, impersonate=latest_chrome_impersonation(), timeout=15)
        return r, r.status_code
    except CurlError:
        return None, None

def main():
    if len(sys.argv) < 2:
        sys.stderr.write("Usage: fetch_url.py <url>\n")
        sys.exit(2)

    url = sys.argv[1]
    host = urlparse(url).netloc
    wait_for_circuit(host)

    cookie_str = load_cookies(host)
    r, status = fetch(url, cookie_str)

    if status in DIAGNOSTIC_STATUSES and r is not None:
        log_response_details(r, status)

    for delay in RATE_LIMIT_BACKOFFS:
        if status not in RATE_LIMIT_STATUSES:
            break
        log(f"status {status} — backing off {delay}s and retrying")
        time.sleep(delay)
        r, status = fetch(url, cookie_str)

    if status != 200:
        log(f"status {status} still failing after retries — refreshing cookies via headless browser")
        try:
            cookie_str = refresh_cookies(url)
            r, status = fetch(url, cookie_str)
        except Exception:
            log("cookie refresh via headless browser failed:\n" + traceback.format_exc())
        if status != 200:
            log(f"retry after cookie refresh still failed (status {status})")
            if status in DIAGNOSTIC_STATUSES and r is not None:
                log_response_details(r, status)

    record_circuit_result(host, status)

    if r is not None and status == 200:
        sys.stdout.buffer.write(r.content)
        sys.stdout.buffer.write(b"\n200\n")
    else:
        sys.stdout.buffer.write(f"\n{status}\n".encode())

if __name__ == "__main__":
    try:
        main()
    except Exception:
        log("unhandled error:\n" + traceback.format_exc())
        sys.stdout.buffer.write(b"\n0\n")
