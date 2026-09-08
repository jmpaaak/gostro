import json
import hashlib
from PIL import Image

def sha256(path):
    with open(path, "rb") as f:
        return hashlib.sha256(f.read()).hexdigest()

with open("assets/manifest.json", "r") as f:
    manifest = json.load(f)

sheet = Image.open("assets/runtime/cards/play-card-contact-sheet-v1.png")

for asset in manifest["assets"]:
    if asset.get("category") == "play-card" and "candidateCell" in asset:
        name = asset["id"].split(".")[1]
        region = asset["candidateCell"]["runtimeRegion"]
        x, y, w, h = region
        cropped = sheet.crop((x, y, x + w, y + h))
        out_path = f"assets/runtime/cards/{name}.png"
        cropped.save(out_path)
        
        asset["runtime"] = {
            "path": out_path,
            "width": w,
            "height": h,
            "alphaBounds": asset["candidateCell"]["alphaBounds"],
            "sha256": sha256(out_path),
            "filter": "nearest"
        }

with open("assets/manifest.json", "w") as f:
    json.dump(manifest, f, indent=2)
