#!/usr/bin/env python3
"""Project-authored 400x560 현무 기원패 (godori wish card) master."""
from math import cos, pi, sin
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 400, 560, Path("assets/masters/planet/godori-v1.png")
MOSS, LACQUER = (28, 60, 44, 255), (16, 32, 24, 255)
GOLD, PAPER = (214, 168, 72, 255), (232, 240, 228, 255)
SILK, SHADOW = (44, 76, 58, 255), (8, 20, 14, 255)
PEARL, CRIMSON = (232, 240, 228, 255), (168, 28, 36, 255)
INK = (8, 20, 14, 255)


def polar(cx, cy, r, a):
    return cx + r * cos(a), cy + r * sin(a)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2
    d.rounded_rectangle((18, 22, W - 18, H - 10), 28, fill=SHADOW)
    d.rounded_rectangle((12, 14, W - 12, H - 18), 26, fill=LACQUER, outline=GOLD, width=10)
    d.rounded_rectangle((28, 30, W - 28, H - 34), 18, fill=PAPER, outline=MOSS, width=8)
    d.polygon([(cx - 70, 14), (cx + 70, 14), (cx + 52, 46), (cx - 52, 46)], fill=GOLD, outline=LACQUER)
    d.ellipse((cx - 10, 22, cx + 10, 42), fill=MOSS)
    d.rectangle((48, 78, W - 48, 118), fill=SILK)
    d.polygon(
        [(48, 78), (88, 58), (128, 78), (168, 58), (208, 78), (248, 58), (288, 78), (328, 58), (352, 78)],
        fill=GOLD,
    )
    # Black-tortoise mark: shell body, geometric hex plates, gold eye — no people or month art.
    d.polygon([(cx - 126, 246), (cx - 32, 176), (cx + 36, 214), (cx - 12, 274), (cx - 92, 304)], fill=MOSS, outline=GOLD)
    d.polygon([(cx + 28, 214), (cx + 138, 198), (cx + 152, 256), (cx + 68, 274), (cx + 32, 248)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 12, 274), (cx + 68, 274), (cx + 92, 352), (cx + 14, 372), (cx - 52, 330)], fill=MOSS, outline=GOLD)
    d.polygon([(cx + 14, 372), (cx + 86, 408), (cx + 40, 448), (cx - 16, 412)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 104, 248), (cx - 52, 228), (cx - 40, 260), (cx - 90, 278)], fill=INK)
    d.polygon([(cx + 48, 232), (cx + 104, 216), (cx + 116, 246), (cx + 60, 260)], fill=INK)
    d.ellipse((cx + 2, 208, cx + 62, 264), fill=GOLD)
    d.ellipse((cx + 16, 222, cx + 44, 250), fill=INK)
    d.ellipse((cx + 26, 228, cx + 36, 238), fill=PEARL)
    for i in range(6):
        a = -pi / 2 + (i - 2.5) * 0.52
        d.polygon(
            [polar(cx + 16, 236, 22, a), polar(cx + 16, 236, 58, a - 0.18), polar(cx + 16, 236, 58, a + 0.18)],
            fill=GOLD if i % 2 else SILK,
        )
    d.polygon([(72, 360), (cx, 332), (W - 72, 360), (cx, 402)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 90, 430), (cx, 390), (cx + 90, 430), (cx, 470)], fill=MOSS, outline=GOLD)
    d.rounded_rectangle((cx + 78, 392, cx + 146, 460), 6, fill=MOSS, outline=GOLD, width=6)
    d.line((cx + 90, 410, cx + 134, 410), fill=GOLD, width=6)
    d.line((cx + 90, 428, cx + 134, 428), fill=GOLD, width=6)
    d.line((cx + 90, 444, cx + 134, 444), fill=GOLD, width=6)
    d.ellipse((54, 488, 86, 520), fill=MOSS)
    d.ellipse((W - 86, 488, W - 54, 520), fill=CRIMSON)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
