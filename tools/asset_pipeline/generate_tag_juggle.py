#!/usr/bin/env python3
"""Project-authored 256x384 곡예사 패찰 (juggle tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/juggle-v1.png")
WOOD, DARK, GOLD = (92, 52, 28, 255), (44, 20, 12, 255), (214, 168, 72, 255)
PAPER, INK = (248, 236, 216, 255), (48, 20, 16, 255)
CRIMSON, TEAL, CREAM = (176, 36, 48, 255), (40, 108, 116, 255), (232, 208, 160, 255)


def card(d, x, y, fill, stripe):
    d.rounded_rectangle((x, y, x + 44, y + 64), radius=6, fill=fill, outline=GOLD, width=3)
    d.rectangle((x + 8, y + 8, x + 36, y + 18), fill=stripe)
    d.ellipse((x + 14, y + 28, x + 30, y + 50), fill=GOLD, outline=INK, width=2)


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
    # Three airborne hwatu cards: extra-hand-size skip tag. No people or months.
    card(d, cx - 52, 176, CRIMSON, CREAM)
    card(d, cx - 22, 148, TEAL, GOLD)
    card(d, cx + 8, 188, CREAM, CRIMSON)
    d.arc((cx - 48, 236, cx + 48, 284), 200, 340, fill=GOLD, width=6)
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=CRIMSON, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=GOLD, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=TEAL, width=8)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
