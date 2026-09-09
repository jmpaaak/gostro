#!/usr/bin/env python3
"""Project-authored 256x384 대풍년 패찰 (mega tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/mega-v1.png")
WOOD, DARK, GOLD = (148, 108, 36, 255), (72, 44, 12, 255), (214, 168, 72, 255)
PAPER, GRAIN, LEAF = (248, 236, 196, 255), (196, 148, 40, 255), (72, 116, 40, 255)
STAR, INK = (232, 196, 72, 255), (56, 28, 8, 255)


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
    # Twin gwang stars + grain: duplicate-next-gwang harvest skip tag.
    star(d, cx - 22, 176, 28, STAR, GOLD)
    star(d, cx + 22, 196, 28, GOLD, INK)
    d.line((cx - 8, 232, cx - 8, 276), fill=LEAF, width=6)
    d.line((cx + 8, 232, cx + 8, 276), fill=LEAF, width=6)
    d.ellipse((cx - 22, 224, cx + 6, 248), fill=GRAIN, outline=GOLD, width=3)
    d.ellipse((cx - 6, 224, cx + 22, 248), fill=GRAIN, outline=GOLD, width=3)
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=LEAF, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=GOLD, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=LEAF, width=8)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
