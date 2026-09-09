#!/usr/bin/env python3
"""Project-authored 384x384 blue hwatu deck thumbnail master."""
from math import cos, pi, sin
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 384, 384, Path("assets/masters/ui/deck-blue-v1.png")
GOLD, CRIMSON, INDIGO = (214, 176, 74, 255), (168, 42, 48, 255), (42, 78, 148, 255)


def polar(cx, cy, r, a):
    return cx + r * cos(a), cy + r * sin(a)


def star(draw, cx, cy, outer, inner, n, fill, outline=None):
    pts = [polar(cx, cy, outer if i % 2 == 0 else inner, -pi / 2 + i * pi / n) for i in range(n * 2)]
    draw.polygon(pts, fill=fill, outline=outline)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx, cy = ImageDraw.Draw(im, "RGBA"), W // 2, H // 2
    d.rounded_rectangle((8, 16, W - 8, H - 4), 36, fill=(8, 10, 18, 255))
    d.rounded_rectangle((8, 8, W - 8, H - 16), 36, fill=(18, 42, 86, 255))
    d.rounded_rectangle((24, 24, W - 24, H - 32), 28, fill=(12, 28, 64, 255))
    d.rounded_rectangle((40, 40, W - 40, H - 48), 22, outline=GOLD, width=10)
    d.rounded_rectangle((56, 56, W - 56, H - 64), 16, outline=(8, 14, 28, 255), width=6)
    for i in range(8):
        a = i * pi / 4 + 0.2
        d.polygon([polar(cx, cy - 8, 18, a), polar(cx, cy - 8, 92, a - 0.08), polar(cx, cy - 8, 92, a + 0.08)],
                  fill=(48, 92, 148, 90) if i % 2 == 0 else (214, 176, 74, 70))
    d.ellipse((cx - 54, cy - 62, cx + 54, cy + 46), fill=(28, 78, 118, 255))
    d.ellipse((cx - 40, cy - 48, cx + 40, cy + 32), fill=(186, 214, 210, 255))
    star(d, cx, cy - 8, 34, 14, 8, GOLD, (255, 232, 150, 255))
    star(d, cx, cy - 8, 14, 5, 8, (12, 22, 48, 255))
    d.polygon([(cx - 92, cy - 18), (cx - 48, cy - 48), (cx - 52, cy + 8)], fill=CRIMSON, outline=GOLD)
    d.rectangle((cx - 98, cy - 54, cx - 90, cy + 12), fill=(12, 10, 18, 255))
    d.polygon([(cx + 92, cy - 18), (cx + 48, cy - 48), (cx + 52, cy + 8)], fill=INDIGO, outline=GOLD)
    d.rectangle((cx + 90, cy - 54, cx + 98, cy + 12), fill=(12, 10, 18, 255))
    d.polygon([(cx - 78, cy + 58), (cx - 58, cy + 34), (cx - 38, cy + 58), (cx - 58, cy + 82)], fill=(164, 128, 172, 255), outline=GOLD)
    d.polygon([(cx + 78, cy + 58), (cx + 58, cy + 34), (cx + 38, cy + 58), (cx + 58, cy + 82)], fill=(48, 108, 86, 255), outline=GOLD)
    d.ellipse((cx + 50, cy + 50, cx + 66, cy + 66), fill=GOLD)
    for i, y in enumerate((cy + 96, cy + 110, cy + 124)):
        d.rounded_rectangle((cx - 22, y, cx + 22, y + 8), 3, fill=GOLD if i != 1 else CRIMSON)
    for x, y, dx, dy in ((28, 24, 1, 1), (W - 28, 24, -1, 1), (28, H - 36, 1, -1), (W - 28, H - 36, -1, -1)):
        d.line((x, y, x + dx * 48, y), fill=(232, 186, 86, 255), width=8)
        d.line((x, y, x, y + dy * 48), fill=(232, 186, 86, 255), width=8)
        d.ellipse((x - 8, y - 8, x + 8, y + 8), fill=(255, 224, 140, 255))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
