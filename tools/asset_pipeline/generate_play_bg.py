#!/usr/bin/env python3
"""Project-authored 960x540 play-scene background master."""

from pathlib import Path
from PIL import Image, ImageDraw

W, H = 960, 540
OUT = Path("assets/masters/ui/play-bg-v1.png")


def play_bg() -> Image.Image:
    im = Image.new("RGBA", (W, H), (6, 9, 20, 255))
    draw = ImageDraw.Draw(im, "RGBA")
    draw.rectangle((24, 24, W - 24, H - 24), fill=(10, 18, 42, 255))
    draw.rectangle((48, 42, W - 48, H - 42), outline=(28, 48, 86, 255), width=6)
    for y in range(72, H - 72, 36):
        draw.line((72, y, W - 72, y), fill=(18, 32, 64, 90), width=3)
    brass = (214, 176, 74, 255)
    for x, y, dx, dy in (
        (36, 36, 1, 1), (W - 36, 36, -1, 1),
        (36, H - 36, 1, -1), (W - 36, H - 36, -1, -1),
    ):
        draw.line((x, y, x + dx * 54, y), fill=brass, width=8)
        draw.line((x, y, x, y + dy * 54), fill=brass, width=8)
    cx, cy = W // 2, H // 2
    draw.ellipse((cx - 18, cy - 18, cx + 18, cy + 18), outline=(184, 31, 41, 80), width=6)
    draw.ellipse((cx - 8, cy - 8, cx + 8, cy + 8), fill=(240, 184, 56, 70))
    return im


def run() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    play_bg().save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
