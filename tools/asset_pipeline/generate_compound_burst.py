#!/usr/bin/env python3
"""Request and save the compound-burst animation atlas from Asset Studio."""

import base64
import json
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[2]
BASE_URL = "http://127.0.0.1:4176"


def main() -> None:
    source = ROOT / "assets/masters/gwang/compound-v1.png"
    encoded = base64.b64encode(source.read_bytes()).decode("ascii")
    payload = {
        "characterId": "gwang_compound_burst", "provider": "codex",
        "cellSize": 256, "chromaKey": "magenta", "assetType": "object",
        "states": [
            {"id": "idle", "frames": 4, "fps": 4, "loop": True, "action": "idle animation"},
            {"id": "burst", "frames": 4, "fps": 8, "loop": True, "action": "burst energy animation"},
        ],
        "description": "Gwang compound burst slot item",
        "baseImageDataUrl": f"data:image/png;base64,{encoded}",
    }
    request = Request(f"{BASE_URL}/api/sprite-generate",
                      data=json.dumps(payload).encode(), headers={"Content-Type": "application/json"})
    try:
        with urlopen(request) as response:
            result = json.load(response)
        with urlopen(f"{BASE_URL}{result['atlas']}") as response:
            atlas = response.read()
    except HTTPError as error:
        raise SystemExit(f"HTTP {error.code}: {error.read().decode()}") from error

    output = ROOT / "assets/masters/gwang/compound-burst-v1.png"
    output.write_bytes(atlas)
    print(f"Saved master atlas to {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()