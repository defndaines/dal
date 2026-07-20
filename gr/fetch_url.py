#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = ["curl_cffi", "playwright"]
# ///
import re, sys, subprocess, time
from pathlib import Path
from urllib.parse import urlparse

RATE_LIMIT_STATUSES = {429, 503}
RATE_LIMIT_BACKOFFS = [3, 8]

COOKIE_DIR = Path.home() / ".spider_cookies"

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
    sys.stderr.write(f"[{ts}] [fetch_url] {msg}\n")

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
    from playwright.sync_api import sync_playwright

    host = urlparse(url).netloc

    def _get(p):
        try:
            browser = p.chromium.launch(channel="chrome", headless=True)
        except Exception:
            browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()
        page.goto(url, wait_until="networkidle", timeout=30000)
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

if len(sys.argv) < 2:
    sys.stderr.write("Usage: fetch_url.py <url>\n")
    sys.exit(2)

url = sys.argv[1]
cookie_str = load_cookies(urlparse(url).netloc)
r, status = fetch(url, cookie_str)

if status in RATE_LIMIT_STATUSES and r is not None:
    retry_after = r.headers.get("Retry-After")
    server = r.headers.get("Server")
    via = r.headers.get("Via")
    title_match = re.search(r"<title>(.*?)</title>", r.text, re.IGNORECASE | re.DOTALL)
    title = title_match.group(1).strip() if title_match else None
    body_snippet = re.sub(r"\s+", " ", r.text)[:400]
    log(f"Retry-After={retry_after!r} Server={server!r} Via={via!r} title={title!r} body={body_snippet!r}")

for delay in RATE_LIMIT_BACKOFFS:
    if status not in RATE_LIMIT_STATUSES:
        break
    log(f"status {status} — backing off {delay}s and retrying")
    time.sleep(delay)
    r, status = fetch(url, cookie_str)

if status != 200 and status not in RATE_LIMIT_STATUSES:
    log(f"WAF challenge (status {status}) — refreshing cookies via headless browser")
    cookie_str = refresh_cookies(url)
    r, status = fetch(url, cookie_str)
    if status != 200:
        log(f"retry after cookie refresh still failed (status {status})")

if r is not None and status == 200:
    sys.stdout.buffer.write(r.content)
    sys.stdout.buffer.write(b"\n200\n")
else:
    sys.stdout.buffer.write(f"\n{status}\n".encode())
