#!/usr/bin/env python3
"""Project-authored 400x560 황룡 기원패 (pi wish card) master."""
from math import cos, pi, sin
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 400, 560, Path("assets/masters/planet/pi-v1.png")
AMBER, LACQUER = (196, 132, 36, 255), (46, 28, 10, 255)
GOLD, PAPER = (214, 168, 72, 255), (252, 236, 196, 255)
SILK, SHADOW = (232, 176, 64, 255), (22, 12, 6, 255)
PEARL, CRIMSON = (255, 244, 214, 255), (168, 28, 36, 255)
INK = (72, 36, 12, 255)


def polar(cx, cy, r, a):
    return cx + r * cos(a), cy + r * sin(a)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2
    d.rounded_rectangle((18, 22, W - 18, H - 10), 28, fill=SHADOW)
    d.rounded_rectangle((12, 14, W - 12, H - 18), 26, fill=LACQUER, outline=GOLD, width=10)
    d.rounded_rectangle((28, 30, W - 28, H - 34), 18, fill=PAPER, outline=AMBER, width=8)
    d.polygon([(cx - 70, 14), (cx + 70, 14), (cx + 52, 46), (cx - 52, 46)], fill=GOLD, outline=LACQUER)
    d.ellipse((cx - 10, 22, cx + 10, 42), fill=AMBER)
    d.rectangle((48, 78, W - 48, 118), fill=SILK)
    d.polygon(
        [(48, 78), (88, 58), (128, 78), (168, 58), (208, 78), (248, 58), (288, 78), (328, 58), (352, 78)],
        fill=GOLD,
    )
    # Yellow-dragon mark: coiled body, pearl, geometric crest — no people or month art.
    d.polygon([(cx - 120, 252), (cx - 28, 172), (cx + 40, 210), (cx - 4, 270), (cx - 84, 300)], fill=AMBER, outline=GOLD)
    d.polygon([(cx + 24, 210), (cx + 140, 186), (cx + 158, 250), (cx + 76, 270), (cx + 36, 244)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 4, 270), (cx + 76, 270), (cx + 104, 348), (cx + 22, 372), (cx - 44, 328)], fill=AMBER, outline=GOLD)
    d.polygon([(cx + 22, 372), (cx + 94, 412), (cx + 48, 452), (cx - 8, 416)], fill=SILK, outline=GOLD)
    d.ellipse((cx - 6, 206, cx + 54, 266), fill=GOLD)
    d.ellipse((cx + 8, 220, cx + 36, 248), fill=INK)
    d.ellipse((cx + 18, 226, cx + 28, 236), fill=PEARL)
    d.ellipse((cx + 108, 188, cx + 148, 228), fill=PEARL, outline=GOLD)
    d.ellipse((cx + 120, 200, cx + 136, 216), fill=AMBER)
    for i in range(6):
        a = -pi / 2 + (i - 2.5) * 0.46
        d.polygon(
            [polar(cx + 18, 236, 24, a), polar(cx + 18, 236, 70, a - 0.16), polar(cx + 18, 236, 70, a + 0.16)],
            fill=GOLD if i % 2 else PEARL,
        )
    d.polygon([(72, 360), (cx, 332), (W - 72, 360), (cx, 402)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 90, 430), (cx, 390), (cx + 90, 430), (cx, 470)], fill=AMBER, outline=GOLD)
    d.rounded_rectangle((cx + 78, 392, cx + 146, 460), 6, fill=AMBER, outline=GOLD, width=6)
    d.line((cx + 90, 410, cx + 134, 410), fill=GOLD, width=6)
    d.line((cx + 90, 428, cx + 134, 428), fill=GOLD, width=6)
    d.line((cx + 90, 444, cx + 134, 444), fill=GOLD, width=6)
    d.ellipse((54, 488, 86, 520), fill=AMBER)
    d.ellipse((W - 86, 488, W - 54, 520), fill=CRIMSON)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
