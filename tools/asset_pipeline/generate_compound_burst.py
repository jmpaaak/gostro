#!/usr/bin/env python3
"""Request and save the compound-burst animation atlas from Asset Studio."""

import base64
import json
import urllib.request
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[2]
BASE_URL = "http://127.0.0.1:4176"

def get_session():
    # Make a GET request to get cookies
    req = Request(f"{BASE_URL}/index.html")
    with urlopen(req) as resp:
        cookies = resp.headers.get_all('Set-Cookie')
        if not cookies:
            return "", ""
        cookie_str = "; ".join(c.split(";")[0] for c in cookies)
        csrf = ""
        for c in cookies:
            if "pas_csrf=" in c:
                csrf = c.split("pas_csrf=")[1].split(";")[0]
        return cookie_str, csrf

def main() -> None:
    source = ROOT / "assets/masters/gwang/compound-v1.png"
    encoded = base64.b64encode(source.read_bytes()).decode("ascii")
    payload = {
        "characterId": "gwang_compound_burst", "provider": "grok",
        "cellSize": 256, "chromaKey": "magenta", "assetType": "object",
        "states": [
            {"id": "idle", "frames": 4, "fps": 4, "loop": True, "action": "idle animation"},
            {"id": "burst", "frames": 4, "fps": 8, "loop": True, "action": "burst energy animation"},
        ],
        "description": "Gwang compound burst slot item",
        "baseImageDataUrl": f"data:image/png;base64,{encoded}",
    }
    
    cookie_str, csrf = get_session()
    
    headers = {
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
        "Referer": "http://127.0.0.1:4176/index.html",
        "Origin": "http://127.0.0.1:4176",
        "Accept": "application/json",
        "Cookie": cookie_str,
        "x-pas-csrf": csrf
    }
    request = Request(f"{BASE_URL}/api/sprite-generate",
                      data=json.dumps(payload).encode(), headers=headers)
    try:
        with urlopen(request) as response:
            result = json.load(response)
        with urlopen(f"{BASE_URL}{result['atlas']}") as response:
            atlas = response.read()
    except HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode()}") from error

    output = ROOT / "assets/masters/gwang/compound-burst-v1.png"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(atlas)
    print(f"Saved master atlas to {output.relative_to(ROOT)}")

if __name__ == "__main__":
    main()