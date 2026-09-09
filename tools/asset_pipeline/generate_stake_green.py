#!/usr/bin/env python3
"""Project-authored 384x384 green hwatu stake chip master."""
from math import cos, pi, sin
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 384, 384, Path("assets/masters/ui/stake-green-v1.png")
JADE = (48, 108, 86, 255)
LACQUER = (18, 46, 36, 255)
GOLD = (196, 158, 72, 255)
PEARL = (248, 232, 210, 255)
IVORY = (236, 214, 186, 255)
CRIMSON = (168, 36, 42, 255)
SHADOW = (10, 22, 16, 255)


def polar(cx, cy, r, a):
    return cx + r * cos(a), cy + r * sin(a)


def star(draw, cx, cy, outer, inner, n, fill, outline=None):
    pts = [polar(cx, cy, outer if i % 2 == 0 else inner, -pi / 2 + i * pi / n) for i in range(n * 2)]
    draw.polygon(pts, fill=fill, outline=outline)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx, cy = ImageDraw.Draw(im, "RGBA"), W // 2, H // 2
    d.ellipse((8, 12, W - 8, H - 4), fill=SHADOW)
    d.ellipse((8, 8, W - 8, H - 12), fill=JADE)
    d.ellipse((28, 28, W - 28, H - 32), fill=LACQUER)
    d.ellipse((48, 48, W - 48, H - 52), outline=GOLD, width=10)
    d.ellipse((68, 68, W - 68, H - 72), outline=(168, 214, 176, 255), width=6)
    for i in range(8):
        a = i * pi / 4 + 0.18
        d.polygon(
            [polar(cx, cy - 4, 22, a), polar(cx, cy - 4, 118, a - 0.07), polar(cx, cy - 4, 118, a + 0.07)],
            fill=(168, 214, 176, 80) if i % 2 == 0 else (248, 232, 210, 55),
        )
    d.ellipse((cx - 58, cy - 62, cx + 58, cy + 50), fill=PEARL)
    d.ellipse((cx - 40, cy - 44, cx + 40, cy + 32), fill=IVORY)
    star(d, cx, cy - 6, 36, 14, 8, GOLD, (255, 232, 150, 255))
    star(d, cx, cy - 6, 14, 5, 8, JADE)
    d.polygon([(cx - 108, cy - 8), (cx - 62, cy - 42), (cx - 68, cy + 16)], fill=CRIMSON, outline=GOLD)
    d.rectangle((cx - 116, cy - 46, cx - 106, cy + 20), fill=SHADOW)
    d.polygon([(cx + 108, cy - 8), (cx + 62, cy - 42), (cx + 68, cy + 16)], fill=(42, 58, 118, 255), outline=GOLD)
    d.rectangle((cx + 106, cy - 46, cx + 116, cy + 20), fill=SHADOW)
    d.polygon(
        [(cx - 18, cy + 86), (cx, cy + 62), (cx + 18, cy + 86), (cx, cy + 110)],
        fill=(214, 176, 74, 255),
        outline=GOLD,
    )
    for x, y, dx, dy in ((36, 36, 1, 1), (W - 36, 36, -1, 1), (36, H - 40, 1, -1), (W - 36, H - 40, -1, -1)):
        d.line((x, y, x + dx * 36, y), fill=GOLD, width=8)
        d.line((x, y, x, y + dy * 36), fill=GOLD, width=8)
        d.ellipse((x - 7, y - 7, x + 7, y + 7), fill=(255, 224, 140, 255))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
