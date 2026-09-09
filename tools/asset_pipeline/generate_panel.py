#!/usr/bin/env python3
"""Project-authored 640x368 lacquered wood panel master for 9-slice UI."""

from pathlib import Path
from PIL import Image, ImageDraw

W, H, R = 640, 368, 48


def run() -> None:
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    draw.rounded_rectangle((0, 10, W, H), radius=R, fill=(36, 16, 8, 255))
    draw.rounded_rectangle((0, 0, W, H - 10), radius=R, fill=(118, 64, 28, 255))
    draw.rounded_rectangle((10, 8, W - 10, H - 22), radius=36, fill=(86, 46, 20, 255))
    for y in range(28, H - 36, 11):
        tone = 58 + (y * 3) % 28
        draw.line((28, y, W - 28, y + ((y // 13) % 9) - 4), fill=(tone, 28, 10, 210), width=4)
        draw.line((36, y + 5, W - 40, y + 3), fill=(168, 104, 48, 70), width=2)
    draw.rounded_rectangle((22, 18, W - 22, H - 32), radius=28, outline=(214, 164, 74, 255), width=10)
    draw.rounded_rectangle((40, 34, W - 40, H - 48), radius=18, outline=(48, 22, 10, 255), width=6)
    for x, y, dx, dy in ((18, 16, 1, 1), (W - 18, 16, -1, 1), (18, H - 28, 1, -1), (W - 18, H - 28, -1, -1)):
        draw.line((x, y, x + dx * 78, y), fill=(232, 186, 86, 255), width=14)
        draw.line((x, y, x, y + dy * 78), fill=(232, 186, 86, 255), width=14)
        draw.ellipse((x - 10, y - 10, x + 10, y + 10), fill=(255, 224, 140, 255))
    out = Path("assets/masters/ui/panel-wood-v1.png")
    out.parent.mkdir(parents=True, exist_ok=True)
    im.save(out)
    print(f"Saved {out}")


if __name__ == "__main__":
    run()
