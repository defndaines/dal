#!/bin/bash
# 1. Open https://www.goodreads.com/search?q=test in your browser
# 2. DevTools → Network tab → click the search request → Request Headers → Cookie
# 3. Copy the full Cookie header value, then run this script and paste it

echo "Paste the Cookie header value from DevTools and press Enter, then Ctrl-D:"
cookie=$(cat)
echo "$cookie" > ~/.goodreads_cookie
echo "Saved to ~/.goodreads_cookie"
