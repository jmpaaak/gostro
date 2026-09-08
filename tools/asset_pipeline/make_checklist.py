import json

base_path = '/Users/jm/orca/workspaces/interactive-story-game-factory/gostro/'

with open(base_path + 'assets/manifest.json', 'r') as f:
    manifest = json.load(f)

lines = ["# Asset Pipeline Checklist\n"]

categories = {}
for asset in manifest['assets']:
    cat = asset['category']
    categories.setdefault(cat, []).append(asset)

for cat in sorted(categories.keys()):
    lines.append(f"## {cat}\n")
    for asset in categories[cat]:
        checked = "x" if asset.get('status') == 'runtime' else " "
        lines.append(f"- [{checked}] `{asset['id']}` - {asset.get('name', asset['id'])}")
    lines.append("")

with open(base_path + 'docs/ASSET_INVENTORY.md', 'w') as f:
    f.write("\n".join(lines))

print("Created docs/ASSET_INVENTORY.md")
