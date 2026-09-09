#!/usr/bin/env python3
"""Project-authored 400x560 청룡 기원패 (cheongdan wish card) master."""
from math import cos, pi, sin
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 400, 560, Path("assets/masters/planet/cheongdan-v1.png")
AZURE, LACQUER = (28, 72, 168, 255), (10, 18, 46, 255)
GOLD, IVORY = (214, 168, 72, 255), (236, 244, 252, 255)
SILK, SHADOW = (48, 108, 196, 255), (8, 12, 28, 255)
PEARL, CRIMSON = (210, 236, 255, 255), (168, 28, 36, 255)
TEAL = (24, 96, 92, 255)


def polar(cx, cy, r, a):
    return cx + r * cos(a), cy + r * sin(a)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2
    d.rounded_rectangle((18, 22, W - 18, H - 10), 28, fill=SHADOW)
    d.rounded_rectangle((12, 14, W - 12, H - 18), 26, fill=LACQUER, outline=GOLD, width=10)
    d.rounded_rectangle((28, 30, W - 28, H - 34), 18, fill=IVORY, outline=AZURE, width=8)
    d.polygon([(cx - 70, 14), (cx + 70, 14), (cx + 52, 46), (cx - 52, 46)], fill=GOLD, outline=LACQUER)
    d.ellipse((cx - 10, 22, cx + 10, 42), fill=AZURE)
    d.rectangle((48, 78, W - 48, 118), fill=SILK)
    d.polygon(
        [(48, 78), (88, 58), (128, 78), (168, 58), (208, 78), (248, 58), (288, 78), (328, 58), (352, 78)],
        fill=GOLD,
    )
    # Azure dragon mark: coiled body, pearl, geometric crest — no people or month art.
    d.polygon([(cx - 132, 248), (cx - 40, 176), (cx + 28, 214), (cx - 18, 268), (cx - 96, 292)], fill=AZURE, outline=GOLD)
    d.polygon([(cx + 18, 214), (cx + 126, 188), (cx + 148, 236), (cx + 72, 258), (cx + 36, 244)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 18, 268), (cx + 72, 258), (cx + 96, 332), (cx + 18, 352), (cx - 42, 318)], fill=AZURE, outline=GOLD)
    d.polygon([(cx + 18, 352), (cx + 86, 390), (cx + 42, 428), (cx - 12, 396)], fill=SILK, outline=GOLD)
    d.ellipse((cx - 18, 214, cx + 38, 270), fill=GOLD)
    d.ellipse((cx - 4, 228, cx + 24, 256), fill=LACQUER)
    d.ellipse((cx + 96, 196, cx + 132, 232), fill=PEARL, outline=GOLD)
    d.ellipse((cx + 108, 208, cx + 120, 220), fill=TEAL)
    for i in range(5):
        a = -pi / 2 + (i - 2) * 0.42
        d.polygon([polar(cx + 10, 242, 28, a), polar(cx + 10, 242, 74, a - 0.14), polar(cx + 10, 242, 74, a + 0.14)], fill=GOLD if i % 2 else PEARL)
    d.polygon([(72, 360), (cx, 332), (W - 72, 360), (cx, 402)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 90, 430), (cx, 390), (cx + 90, 430), (cx, 470)], fill=AZURE, outline=GOLD)
    d.rounded_rectangle((cx + 78, 392, cx + 146, 460), 6, fill=AZURE, outline=GOLD, width=6)
    d.line((cx + 90, 410, cx + 134, 410), fill=GOLD, width=6)
    d.line((cx + 90, 428, cx + 134, 428), fill=GOLD, width=6)
    d.line((cx + 90, 444, cx + 134, 444), fill=GOLD, width=6)
    d.ellipse((54, 488, 86, 520), fill=AZURE)
    d.ellipse((W - 86, 488, W - 54, 520), fill=CRIMSON)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
