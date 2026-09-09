#!/usr/bin/env python3
"""Project-authored 256x384 영롱 패찰 (polychrome tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/polychrome-v1.png")
WOOD, DARK, GOLD = (72, 88, 108, 255), (28, 36, 56, 255), (214, 168, 72, 255)
PAPER, INK = (244, 236, 228, 255), (40, 32, 48, 255)
ROSE, AMBER, LIME = (220, 72, 108, 255), (236, 180, 48, 255), (72, 188, 92, 255)
CYAN, VIOLET = (48, 164, 212, 255), (148, 84, 196, 255)


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
    # Iridescent nacre fan: next-gwang polychrome edition skip tag.
    d.pieslice((cx - 52, 148, cx + 52, 252), 200, 250, fill=ROSE, outline=INK, width=3)
    d.pieslice((cx - 52, 148, cx + 52, 252), 230, 280, fill=AMBER, outline=INK, width=3)
    d.pieslice((cx - 52, 148, cx + 52, 252), 260, 310, fill=LIME, outline=INK, width=3)
    d.pieslice((cx - 52, 148, cx + 52, 252), 290, 340, fill=CYAN, outline=INK, width=3)
    d.pieslice((cx - 52, 148, cx + 52, 252), 320, 10, fill=VIOLET, outline=INK, width=3)
    star(d, cx, 196, 20, GOLD, INK)
    d.ellipse((cx - 10, 258, cx + 10, 278), fill=GOLD, outline=INK, width=2)
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=ROSE, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=GOLD, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=CYAN, width=8)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
