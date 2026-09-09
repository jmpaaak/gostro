#!/usr/bin/env python3
"""Project-authored 256x384 재주꾼 패찰 (handy tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/handy-v1.png")
WOOD, DARK, GOLD = (72, 116, 92, 255), (28, 56, 40, 255), (214, 168, 72, 255)
PAPER, TEAL, FAN = (236, 244, 228, 255), (48, 140, 116, 255), (36, 96, 88, 255)
INK, COIN = (24, 48, 36, 255), (196, 140, 48, 255)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2
    d.line((cx, 20, cx - 40, 80), fill=GOLD, width=12)
    d.line((cx, 20, cx + 40, 80), fill=GOLD, width=12)
    d.ellipse((cx - 16, 8, cx + 16, 40), fill=GOLD)
    d.polygon([(cx - 80, 60), (cx + 80, 60), (cx + 100, 90), (cx + 100, H - 40),
               (cx - 100, H - 40), (cx - 100, 90)], fill=DARK)
    d.polygon([(cx - 70, 70), (cx + 70, 70), (cx + 88, 96), (cx + 88, H - 52),
               (cx - 88, H - 52), (cx - 88, 96)], fill=WOOD)
    d.rectangle((cx - 60, 110, cx + 60, H - 70), fill=PAPER, outline=DARK, width=4)
    # Folding fan + coin: leftover-hand money skip tag. No text, people, or month art.
    d.pieslice((cx - 48, 148, cx + 48, 244), 200, 340, fill=TEAL, outline=GOLD, width=6)
    d.pieslice((cx - 36, 160, cx + 36, 232), 205, 335, fill=FAN)
    d.line((cx, 196, cx - 40, 168), fill=GOLD, width=4)
    d.line((cx, 196, cx, 156), fill=GOLD, width=4)
    d.line((cx, 196, cx + 40, 168), fill=GOLD, width=4)
    d.polygon([(cx - 10, 196), (cx + 10, 196), (cx, 228)], fill=INK)
    d.ellipse((cx - 22, 236, cx + 22, 280), fill=COIN, outline=GOLD, width=4)
    d.ellipse((cx - 10, 248, cx + 10, 268), fill=GOLD)
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=TEAL, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=GOLD, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=TEAL, width=8)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
