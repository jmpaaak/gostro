#!/usr/bin/env python3
"""Project-authored 256x384 은박 패찰 (foil tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/foil-v1.png")
WOOD, DARK, GOLD = (108, 116, 140, 255), (40, 48, 72, 255), (214, 168, 72, 255)
PAPER, SILVER, SHEEN = (228, 236, 244, 255), (196, 212, 228, 255), (240, 248, 255)
INK, SPARK = (36, 48, 72, 255), (168, 196, 228, 255)


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
    # Folded silver-foil leaf + gwang star: next-gwang foil edition skip tag.
    d.polygon([(cx - 42, 168), (cx + 8, 148), (cx + 44, 188), (cx + 20, 248),
               (cx - 28, 232)], fill=SILVER, outline=INK, width=4)
    d.polygon([(cx - 18, 176), (cx + 8, 164), (cx + 28, 196), (cx + 8, 228)],
              fill=SHEEN)
    star(d, cx - 4, 196, 26, SPARK, GOLD)
    d.line((cx + 28, 156, cx + 44, 140), fill=SHEEN, width=5)
    d.line((cx - 36, 212, cx - 52, 228), fill=SHEEN, width=5)
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=SILVER, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=GOLD, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=SILVER, width=8)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
