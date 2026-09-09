#!/usr/bin/env python3
"""Project-authored 256x384 행운 패찰 (charm tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/charm-v1.png")
WOOD, DARK, GOLD = (140, 84, 44, 255), (72, 36, 16, 255), (214, 168, 72, 255)
PAPER, INK = (248, 232, 208, 255), (64, 28, 20, 255)
CRIMSON, CORD, COIN = (176, 36, 48, 255), (196, 64, 56, 255), (232, 188, 64, 255)


def star(d, cx, cy, r, fill, outline):
    pts = [(cx, cy - r), (cx + r * 0.28, cy - r * 0.28), (cx + r, cy),
           (cx + r * 0.28, cy + r * 0.28), (cx, cy + r),
           (cx - r * 0.28, cy + r * 0.28), (cx - r, cy),
           (cx - r * 0.28, cy - r * 0.28)]
    d.polygon(pts, fill=fill, outline=outline)


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
    # Lucky pouch + twin shop lanterns: extra shop-slot skip tag.
    d.polygon([(cx - 36, 168), (cx + 36, 168), (cx + 44, 236), (cx, 268),
               (cx - 44, 236)], fill=CRIMSON, outline=INK, width=4)
    d.polygon([(cx - 18, 176), (cx + 18, 176), (cx + 12, 220), (cx - 12, 220)],
              fill=GOLD)
    star(d, cx, 198, 16, COIN, INK)
    d.line((cx, 148, cx, 168), fill=CORD, width=6)
    d.ellipse((cx - 10, 140, cx + 10, 156), fill=GOLD, outline=INK, width=2)
    d.ellipse((cx - 44, 248, cx - 16, 276), fill=COIN, outline=INK, width=3)
    d.ellipse((cx + 16, 248, cx + 44, 276), fill=COIN, outline=INK, width=3)
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=CRIMSON, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=GOLD, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=CRIMSON, width=8)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
