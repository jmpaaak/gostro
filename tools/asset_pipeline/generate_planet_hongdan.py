#!/usr/bin/env python3
"""Project-authored 400x560 주작 기원패 (hongdan wish card) master."""
from math import cos, pi, sin
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 400, 560, Path("assets/masters/planet/hongdan-v1.png")
CRIMSON, LACQUER = (168, 28, 36, 255), (42, 12, 16, 255)
GOLD, IVORY = (214, 168, 72, 255), (248, 228, 196, 255)
SILK, SHADOW = (196, 48, 54, 255), (18, 8, 10, 255)
PEARL, TEAL = (255, 236, 210, 255), (24, 72, 78, 255)


def polar(cx, cy, r, a):
    return cx + r * cos(a), cy + r * sin(a)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2
    d.rounded_rectangle((18, 22, W - 18, H - 10), 28, fill=SHADOW)
    d.rounded_rectangle((12, 14, W - 12, H - 18), 26, fill=LACQUER, outline=TEAL, width=10)
    d.rounded_rectangle((28, 30, W - 28, H - 34), 18, fill=IVORY, outline=CRIMSON, width=8)
    d.polygon([(cx - 70, 14), (cx + 70, 14), (cx + 52, 46), (cx - 52, 46)], fill=GOLD, outline=LACQUER)
    d.ellipse((cx - 10, 22, cx + 10, 42), fill=CRIMSON)
    d.rectangle((48, 78, W - 48, 118), fill=SILK)
    d.polygon([(48, 78), (88, 58), (128, 78), (168, 58), (208, 78), (248, 58), (288, 78), (328, 58), (352, 78)], fill=GOLD)
    d.polygon([(cx, 168), (cx + 118, 236), (cx + 42, 228), (cx + 78, 318), (cx, 268), (cx - 78, 318), (cx - 42, 228), (cx - 118, 236)], fill=CRIMSON, outline=GOLD)
    d.polygon([(cx, 196), (cx + 36, 248), (cx, 238), (cx - 36, 248)], fill=PEARL)
    d.ellipse((cx - 28, 214, cx + 28, 258), fill=GOLD)
    d.ellipse((cx - 12, 226, cx + 12, 250), fill=LACQUER)
    for i in range(7):
        a = -pi / 2 + (i - 3) * 0.28
        d.polygon([polar(cx, 236, 34, a), polar(cx, 236, 92, a - 0.12), polar(cx, 236, 92, a + 0.12)], fill=SILK if i % 2 else GOLD)
    d.polygon([(72, 360), (cx, 332), (W - 72, 360), (cx, 402)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 90, 430), (cx, 390), (cx + 90, 430), (cx, 470)], fill=CRIMSON, outline=GOLD)
    d.rounded_rectangle((cx + 78, 392, cx + 146, 460), 6, fill=CRIMSON, outline=GOLD, width=6)
    d.line((cx + 90, 410, cx + 134, 410), fill=GOLD, width=6)
    d.line((cx + 90, 428, cx + 134, 428), fill=GOLD, width=6)
    d.line((cx + 90, 444, cx + 134, 444), fill=GOLD, width=6)
    d.ellipse((54, 488, 86, 520), fill=CRIMSON)
    d.ellipse((W - 86, 488, W - 54, 520), fill=TEAL)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
