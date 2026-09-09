#!/usr/bin/env python3
"""Generate or validate the manifest-backed asset inventory checklist."""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
DEFAULT_MANIFEST = ROOT / "assets" / "manifest.json"
DEFAULT_CHECKLIST = ROOT / "docs" / "ASSET_INVENTORY.md"
CHECKBOX_RE = re.compile(r"^- \[([ xX])\] `([^`]+)`", re.MULTILINE)


def load_assets(path: Path) -> list[dict]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    assets = payload.get("assets")
    if not isinstance(assets, list):
        raise ValueError(f"{path}: manifest must contain an assets list")
    return assets


def checklist_states(text: str) -> dict[str, bool]:
    states: dict[str, bool] = {}
    for mark, asset_id in CHECKBOX_RE.findall(text):
        if asset_id in states:
            raise ValueError(f"duplicate checklist id: {asset_id}")
        states[asset_id] = mark.lower() == "x"
    return states


def expected_states(assets: list[dict]) -> dict[str, bool]:
    states: dict[str, bool] = {}
    for asset in assets:
        asset_id = asset.get("id")
        if not isinstance(asset_id, str) or not asset_id:
            raise ValueError("every manifest asset must have a non-empty id")
        if asset_id in states:
            raise ValueError(f"duplicate manifest id: {asset_id}")
        states[asset_id] = asset.get("status") == "runtime"
    return states


def validate(assets: list[dict], checklist_text: str) -> list[str]:
    expected = expected_states(assets)
    actual = checklist_states(checklist_text)
    errors: list[str] = []
    for asset_id in sorted(expected.keys() - actual.keys()):
        errors.append(f"missing checklist id: {asset_id}")
    for asset_id in sorted(actual.keys() - expected.keys()):
        errors.append(f"unknown checklist id: {asset_id}")
    for asset_id in sorted(expected.keys() & actual.keys()):
        if expected[asset_id] != actual[asset_id]:
            wanted = "checked" if expected[asset_id] else "unchecked"
            errors.append(f"status mismatch: {asset_id} must be {wanted}")
    return errors


def render(assets: list[dict]) -> str:
    categories: dict[str, list[dict]] = {}
    for asset in assets:
        categories.setdefault(asset["category"], []).append(asset)

    lines = ["# Asset Pipeline Checklist", ""]
    for category in sorted(categories):
        lines.extend((f"## {category}", ""))
        for asset in categories[category]:
            mark = "x" if asset.get("status") == "runtime" else " "
            lines.append(f"- [{mark}] `{asset['id']}` - {asset.get('name', asset['id'])}")
        lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true", help="fail if checklist ids or statuses differ from the manifest")
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--checklist", type=Path, default=DEFAULT_CHECKLIST)
    args = parser.parse_args()

    assets = load_assets(args.manifest)
    if args.check:
        errors = validate(assets, args.checklist.read_text(encoding="utf-8"))
        if errors:
            for error in errors:
                print(error)
            return 1
        print(f"ASSET_INVENTORY_OK {len(assets)} assets")
        return 0

    args.checklist.write_text(render(assets), encoding="utf-8")
    print(f"Created {args.checklist}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
