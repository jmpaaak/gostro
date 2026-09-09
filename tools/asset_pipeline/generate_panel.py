#!/usr/bin/env python3
"""Project-authored 640x368 9-slice UI panel masters."""

from pathlib import Path
from PIL import Image, ImageDraw

W, H, R = 640, 368, 48
OUT_DIR = Path("assets/masters/ui")


def wood() -> Image.Image:
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
    return im


def metal() -> Image.Image:
    """Patina bronze plaque with taegeuk-inspired corner bosses for HUD 9-slice."""
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    draw.rounded_rectangle((0, 12, W, H), radius=R, fill=(18, 22, 28, 255))
    draw.rounded_rectangle((0, 0, W, H - 12), radius=R, fill=(92, 108, 124, 255))
    draw.rounded_rectangle((12, 10, W - 12, H - 24), radius=36, fill=(58, 72, 86, 255))
    for y in range(32, H - 40, 14):
        shine = 70 + (y * 2) % 36
        draw.line((30, y, W - 30, y + 2), fill=(shine, shine + 12, shine + 22, 160), width=3)
        draw.line((38, y + 7, W - 44, y + 4), fill=(28, 34, 42, 90), width=2)
    draw.rounded_rectangle((24, 20, W - 24, H - 36), radius=26, outline=(214, 186, 96, 255), width=10)
    draw.rounded_rectangle((42, 36, W - 42, H - 52), radius=16, outline=(24, 30, 38, 255), width=6)
    for cx, cy in ((28, 26), (W - 28, 26), (28, H - 38), (W - 28, H - 38)):
        draw.ellipse((cx - 22, cy - 22, cx + 22, cy + 22), fill=(196, 86, 54, 255))
        draw.pieslice((cx - 18, cy - 18, cx + 18, cy + 18), 180, 360, fill=(36, 42, 54, 255))
        draw.ellipse((cx - 7, cy - 7, cx + 7, cy + 7), fill=(232, 204, 110, 255))
    return im


def glass() -> Image.Image:
    """Celadon glass overlay with najeon plum-blossom corners for 9-slice UI."""
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im)
    draw.rounded_rectangle((0, 14, W, H), radius=R, fill=(8, 18, 22, 90))
    draw.rounded_rectangle((0, 0, W, H - 14), radius=R, fill=(62, 122, 120, 235))
    draw.rounded_rectangle((14, 12, W - 14, H - 28), radius=36, fill=(72, 132, 128, 210))
    for x in range(-40, W, 44):
        draw.line((x, 24, x + 168, H - 40), fill=(210, 236, 228, 42), width=6)
    draw.rounded_rectangle((28, 22, W - 28, 70), radius=18, fill=(186, 228, 220, 72))
    draw.rounded_rectangle((22, 18, W - 22, H - 34), radius=28, outline=(214, 232, 236, 255), width=10)
    draw.rounded_rectangle((40, 34, W - 40, H - 50), radius=16, outline=(28, 64, 68, 255), width=6)
    for cx, cy in ((30, 28), (W - 30, 28), (30, H - 40), (W - 30, H - 40)):
        for dx, dy in ((0, -16), (14, -6), (10, 12), (-10, 12), (-14, -6)):
            draw.ellipse((cx + dx - 10, cy + dy - 10, cx + dx + 10, cy + dy + 10),
                         fill=(236, 244, 240, 255))
        draw.ellipse((cx - 8, cy - 8, cx + 8, cy + 8), fill=(196, 86, 92, 255))
        draw.ellipse((cx - 3, cy - 3, cx + 3, cy + 3), fill=(255, 228, 160, 255))
    return im


def run() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    wood_path = OUT_DIR / "panel-wood-v1.png"
    metal_path = OUT_DIR / "panel-metal-v1.png"
    glass_path = OUT_DIR / "panel-glass-v1.png"
    wood().save(wood_path)
    metal().save(metal_path)
    glass().save(glass_path)
    print(f"Saved {wood_path}")
    print(f"Saved {metal_path}")
    print(f"Saved {glass_path}")


if __name__ == "__main__":
    run()
