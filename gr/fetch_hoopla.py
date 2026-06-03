#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.11"
# dependencies = ["curl_cffi"]
# ///
import sys
from curl_cffi import requests

GQL_QUERY = """
query Search($criteria: SearchCriteria!) {
  search(criteria: $criteria) {
    hits {
      titleId
      title
      seconds
      primaryArtist { name }
      authors { name }
    }
  }
}
"""

if len(sys.argv) < 2:
    sys.stderr.write("Usage: fetch_hoopla.py <query>\n")
    sys.exit(2)

query = sys.argv[1]

payload = {
    "operationName": "Search",
    "variables": {"criteria": {"q": query, "kindId": "8"}},
    "query": GQL_QUERY,
}

try:
    r = requests.post(
        "https://patron-api-gateway.hoopladigital.com/graphql",
        json=payload,
        headers={
            "Content-Type": "application/json",
            "Origin": "https://www.hoopladigital.com",
        },
        impersonate="chrome120",
        timeout=15,
    )
    sys.stdout.buffer.write(r.content)
    sys.stdout.buffer.write(f"\n{r.status_code}\n".encode())
except Exception as e:
    sys.stderr.write(f"[fetch_hoopla] Error: {e}\n")
    sys.stdout.write("\n0\n")
