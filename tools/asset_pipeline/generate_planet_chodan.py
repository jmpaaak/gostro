#!/usr/bin/env python3
"""Project-authored 400x560 백호 기원패 (chodan wish card) master."""
from math import cos, pi, sin
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 400, 560, Path("assets/masters/planet/chodan-v1.png")
IVORY, LACQUER = (244, 236, 214, 255), (46, 28, 16, 255)
GOLD, PAPER = (214, 168, 72, 255), (252, 244, 228, 255)
SILK, SHADOW = (232, 216, 176, 255), (18, 12, 8, 255)
PEARL, CRIMSON = (255, 252, 244, 255), (168, 28, 36, 255)
TEAL = (24, 72, 78, 255)
INK = (36, 24, 16, 255)


def polar(cx, cy, r, a):
    return cx + r * cos(a), cy + r * sin(a)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2
    d.rounded_rectangle((18, 22, W - 18, H - 10), 28, fill=SHADOW)
    d.rounded_rectangle((12, 14, W - 12, H - 18), 26, fill=LACQUER, outline=GOLD, width=10)
    d.rounded_rectangle((28, 30, W - 28, H - 34), 18, fill=PAPER, outline=INK, width=8)
    d.polygon([(cx - 70, 14), (cx + 70, 14), (cx + 52, 46), (cx - 52, 46)], fill=GOLD, outline=LACQUER)
    d.ellipse((cx - 10, 22, cx + 10, 42), fill=IVORY)
    d.rectangle((48, 78, W - 48, 118), fill=SILK)
    d.polygon(
        [(48, 78), (88, 58), (128, 78), (168, 58), (208, 78), (248, 58), (288, 78), (328, 58), (352, 78)],
        fill=GOLD,
    )
    # White-tiger mark: crouched body, geometric stripes, gold eye — no people or month art.
    d.polygon([(cx - 148, 268), (cx - 72, 188), (cx + 18, 214), (cx - 12, 292), (cx - 96, 318)], fill=IVORY, outline=GOLD)
    d.polygon([(cx + 8, 214), (cx + 132, 176), (cx + 156, 236), (cx + 72, 262), (cx + 28, 244)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 12, 292), (cx + 72, 262), (cx + 108, 348), (cx + 18, 372), (cx - 54, 338)], fill=IVORY, outline=GOLD)
    d.polygon([(cx + 18, 372), (cx + 96, 404), (cx + 42, 444), (cx - 18, 412)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 86, 232), (cx - 18, 214), (cx - 8, 248), (cx - 72, 266)], fill=INK)
    d.polygon([(cx + 36, 228), (cx + 92, 208), (cx + 104, 236), (cx + 48, 252)], fill=INK)
    d.ellipse((cx - 8, 206, cx + 48, 262), fill=GOLD)
    d.ellipse((cx + 6, 220, cx + 34, 248), fill=INK)
    d.ellipse((cx + 16, 226, cx + 26, 236), fill=PEARL)
    for i in range(4):
        a = -pi / 2 + (i - 1.5) * 0.38
        d.polygon(
            [polar(cx + 20, 234, 26, a), polar(cx + 20, 234, 68, a - 0.12), polar(cx + 20, 234, 68, a + 0.12)],
            fill=GOLD if i % 2 else INK,
        )
    d.polygon([(72, 360), (cx, 332), (W - 72, 360), (cx, 402)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 90, 430), (cx, 390), (cx + 90, 430), (cx, 470)], fill=IVORY, outline=GOLD)
    d.rounded_rectangle((cx + 78, 392, cx + 146, 460), 6, fill=IVORY, outline=GOLD, width=6)
    d.line((cx + 90, 410, cx + 134, 410), fill=GOLD, width=6)
    d.line((cx + 90, 428, cx + 134, 428), fill=GOLD, width=6)
    d.line((cx + 90, 444, cx + 134, 444), fill=GOLD, width=6)
    d.ellipse((54, 488, 86, 520), fill=IVORY)
    d.ellipse((W - 86, 488, W - 54, 520), fill=CRIMSON)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
