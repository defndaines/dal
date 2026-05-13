#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = ["curl_cffi", "playwright"]
# ///
import sys, os, subprocess
from pathlib import Path

COOKIE_PATH = Path.home() / ".goodreads_cookie"

HEADERS = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "Upgrade-Insecure-Requests": "1",
}

def load_cookies():
    if COOKIE_PATH.exists():
        line = COOKIE_PATH.read_text().split("\n")[0].strip()
        if line:
            return line
    return ""

def refresh_cookies():
    """Solve the WAF challenge via headless Chrome and persist the resulting cookies."""
    from playwright.sync_api import sync_playwright

    def _get(p):
        try:
            browser = p.chromium.launch(channel="chrome", headless=True)
        except Exception:
            browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        page = context.new_page()
        page.goto("https://www.goodreads.com/search?q=test",
                  wait_until="networkidle", timeout=30000)
        cookies = context.cookies()
        browser.close()
        return "; ".join(f"{c['name']}={c['value']}" for c in cookies)

    try:
        with sync_playwright() as p:
            cookie_str = _get(p)
    except Exception as e:
        if "Executable doesn't exist" in str(e):
            sys.stderr.write("[fetch_url] Installing Playwright Chromium (one-time)...\n")
            subprocess.run([sys.executable, "-m", "playwright", "install", "chromium"],
                           check=True, capture_output=True)
            with sync_playwright() as p:
                cookie_str = _get(p)
        else:
            raise

    COOKIE_PATH.write_text(cookie_str + "\n")
    return cookie_str

def fetch(url, cookie_str=""):
    from curl_cffi import requests, CurlError
    headers = dict(HEADERS)
    if cookie_str:
        headers["Cookie"] = cookie_str
    try:
        r = requests.get(url, headers=headers, impersonate="chrome120", timeout=15)
        return r, r.status_code
    except CurlError:
        return None, None

if len(sys.argv) < 2:
    sys.stderr.write("Usage: fetch_url.py <url>\n")
    sys.exit(2)

url = sys.argv[1]
cookie_str = load_cookies()
r, status = fetch(url, cookie_str)

if status != 200:
    sys.stderr.write("[fetch_url] WAF challenge — refreshing cookies via headless browser\n")
    cookie_str = refresh_cookies()
    r, status = fetch(url, cookie_str)

if status == 200:
    sys.stdout.buffer.write(r.content)
    sys.stdout.buffer.write(b"\n200\n")
else:
    sys.stdout.buffer.write(f"\n{status}\n".encode())
