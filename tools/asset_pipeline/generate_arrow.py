#!/usr/bin/env python3
"""Project-authored 624x432 New Run carousel arrow masters."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H = 624, 432
LACQUER, CRIMSON = (28, 22, 16, 255), (168, 42, 48, 255)
GOLD, IVORY = (214, 176, 74, 255), (248, 232, 186, 255)
PEARL, INDIGO = (255, 244, 214, 255), (42, 78, 148, 255)


def draw_arrow(path, points_right):
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx, cy = ImageDraw.Draw(im, "RGBA"), W // 2, H // 2
    d.rounded_rectangle((12, 24, W - 12, H - 8), 48, fill=LACQUER)
    d.rounded_rectangle((12, 12, W - 12, H - 20), 48, fill=CRIMSON)
    d.rounded_rectangle((36, 36, W - 36, H - 44), 36, outline=GOLD, width=10)
    d.rounded_rectangle((56, 56, W - 56, H - 64), 28, outline=(92, 28, 32, 255), width=6)
    s = 1 if points_right else -1
    chevron = [
        (cx + 190 * s, cy), (cx - 150 * s, cy - 148), (cx - 48 * s, cy - 148),
        (cx + 86 * s, cy), (cx - 48 * s, cy + 148), (cx - 150 * s, cy + 148),
    ]
    d.polygon(chevron, fill=IVORY, outline=GOLD)
    inner = [
        (cx + 132 * s, cy), (cx - 86 * s, cy - 88), (cx - 28 * s, cy - 88),
        (cx + 52 * s, cy), (cx - 28 * s, cy + 88), (cx - 86 * s, cy + 88),
    ]
    d.polygon(inner, fill=PEARL, outline=(196, 158, 72, 255))
    d.polygon([(cx + 28 * s, cy), (cx - 36 * s, cy - 36), (cx - 36 * s, cy + 36)], fill=INDIGO)
    for x, y, dx, dy in ((40, 32, 1, 1), (W - 40, 32, -1, 1), (40, H - 44, 1, -1), (W - 40, H - 44, -1, -1)):
        d.line((x, y, x + dx * 44, y), fill=GOLD, width=8)
        d.line((x, y, x, y + dy * 44), fill=GOLD, width=8)
        d.ellipse((x - 7, y - 7, x + 7, y + 7), fill=(255, 224, 140, 255))
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    im.save(path)
    print(f"Saved {path}")


if __name__ == "__main__":
    draw_arrow("assets/masters/ui/arrow-left-v1.png", False)
    draw_arrow("assets/masters/ui/arrow-right-v1.png", True)
