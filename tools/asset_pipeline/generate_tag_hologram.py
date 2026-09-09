#!/usr/bin/env python3
"""Project-authored 256x384 오색 패찰 (hologram tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/hologram-v1.png")
WOOD, DARK, GOLD = (88, 72, 132, 255), (36, 24, 72, 255), (214, 168, 72, 255)
PAPER, INK = (236, 228, 252, 255), (40, 28, 72, 255)
MAGENTA, CYAN, LIME = (196, 48, 140, 255), (40, 180, 196, 255), (88, 196, 72, 255)
AMBER = (232, 164, 48, 255)


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
    # Five-color gwang prism: next-gwang hologram edition skip tag.
    d.polygon([(cx, 148), (cx + 48, 196), (cx, 244), (cx - 48, 196)],
              fill=CYAN, outline=INK, width=4)
    d.polygon([(cx, 160), (cx + 28, 196), (cx, 232), (cx - 28, 196)],
              fill=MAGENTA)
    star(d, cx, 196, 22, GOLD, INK)
    d.ellipse((cx - 38, 252, cx - 14, 276), fill=MAGENTA, outline=GOLD, width=3)
    d.ellipse((cx - 12, 252, cx + 12, 276), fill=CYAN, outline=GOLD, width=3)
    d.ellipse((cx + 14, 252, cx + 38, 276), fill=LIME, outline=GOLD, width=3)
    d.polygon([(cx - 8, 268), (cx + 8, 268), (cx, 292)], fill=AMBER, outline=INK, width=2)
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=MAGENTA, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=GOLD, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=CYAN, width=8)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
