#!/usr/bin/env python3
"""Project-authored 960x540 shop-scene background master."""

from pathlib import Path
from PIL import Image, ImageDraw

W, H = 960, 540
OUT = Path("assets/masters/ui/shop-bg-v1.png")


def shop_bg() -> Image.Image:
    im = Image.new("RGBA", (W, H), (28, 12, 8, 255))
    draw = ImageDraw.Draw(im, "RGBA")
    draw.rectangle((24, 24, W - 24, H - 24), fill=(62, 28, 16, 255))
    draw.rectangle((48, 42, W - 48, H - 42), outline=(148, 92, 36, 255), width=6)
    for y in range(78, H - 78, 42):
        draw.line((78, y, W - 78, y), fill=(92, 48, 22, 90), width=4)
    for x in range(120, W - 120, 96):
        draw.line((x, 72, x, H - 72), fill=(84, 40, 18, 50), width=3)
    lacquer = (196, 42, 36, 255)
    brass = (214, 176, 74, 255)
    for x, y, dx, dy in (
        (36, 36, 1, 1),
        (W - 36, 36, -1, 1),
        (36, H - 36, 1, -1),
        (W - 36, H - 36, -1, -1),
    ):
        draw.line((x, y, x + dx * 54, y), fill=brass, width=8)
        draw.line((x, y, x, y + dy * 54), fill=brass, width=8)
        draw.ellipse((x + dx * 18 - 8, y + dy * 18 - 8, x + dx * 18 + 8, y + dy * 18 + 8), fill=lacquer)
    cx, cy = W // 2, H // 2
    draw.ellipse((cx - 26, cy - 26, cx + 26, cy + 26), outline=(214, 176, 74, 90), width=6)
    draw.ellipse((cx - 10, cy - 10, cx + 10, cy + 10), fill=(240, 184, 56, 80))
    return im


def run() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    shop_bg().save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
