#!/usr/bin/env python3
"""Project-authored 256x384 진품 패찰 (uncommon tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/uncommon-v1.png")
WOOD, DARK, GOLD = (108, 68, 116, 255), (52, 24, 64, 255), (214, 168, 72, 255)
PAPER, INK = (244, 228, 236, 255), (48, 20, 56, 255)
JADE, SEAL, GEM = (72, 148, 108, 255), (176, 36, 48, 255), (120, 196, 168, 255)


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
    # Jade gwang seal + authenticity stamp: uncommon-shop skip tag.
    d.rounded_rectangle((cx - 40, 156, cx + 40, 252), radius=10, fill=JADE, outline=GOLD, width=5)
    star(d, cx, 196, 22, GEM, INK)
    d.ellipse((cx - 18, 228, cx + 18, 264), fill=SEAL, outline=INK, width=3)
    d.polygon([(cx - 6, 236), (cx + 6, 236), (cx, 256)], fill=GOLD)
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=JADE, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=GOLD, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=SEAL, width=8)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
