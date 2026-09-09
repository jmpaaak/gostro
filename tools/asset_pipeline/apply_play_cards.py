#!/usr/bin/env python3
"""Promote the approved play-card sheet and point card entries at its cells."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "assets" / "manifest.json"
SHEET_ID = "play-card.contact-sheet-v1"
ORDER = ["pi", "hongdan", "cheongdan", "chodan", "godori"]


def main() -> None:
    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    candidates = data.get("candidateSheets", [])
    sheet = next((item for item in candidates if item["id"] == SHEET_ID), None)
    if sheet:
        candidates.remove(sheet)
        overlap = sheet["overlapQa"]
        overlap["status"] = "automated-pass"
        overlap["loveCapture"]["artApproval"] = "approved"
        data["assets"].append({
            "id": SHEET_ID, "category": "play-card-sheet", "status": "runtime",
            "master": sheet["master"], "runtime": sheet["pixelPerfectCandidate"],
            "conversion": sheet["conversion"], "overlapQa": overlap,
        })

    for asset in data["assets"]:
        if asset.get("id", "").removeprefix("play-card.") not in ORDER:
            continue
        index = ORDER.index(asset["id"].removeprefix("play-card."))
        asset.clear()
        asset.update({
            "id": f"play-card.{ORDER[index]}", "category": "play-card",
            "status": "runtime", "candidateSheet": SHEET_ID,
            "candidateCell": {
                "index": index + 1, "masterRegion": [index * 192, 0, 192, 288],
                "runtimeRegion": [index * 72, 0, 72, 108],
                "alphaBounds": [0, 0, 71, 107],
            },
        })

    MANIFEST.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()