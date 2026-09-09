#!/usr/bin/env python3
"""Project-authored 192x288 silver-foil play-card overlay master.

Korean hwatu foil sheen: brass corner clips, silver frame, and geometric
sparkle ticks. Hard-alpha interior so the 24x36 hwatu face stays
identifiable. No people, month names, month numbers, or Latin letters.
"""

from pathlib import Path

from PIL import Image, ImageDraw

W, H, OUT = 192, 288, Path("assets/masters/effect/foil-v1.png")
SILVER = (214, 228, 240, 255)
SHEEN = (240, 248, 255, 255)
BRASS = (214, 176, 74, 255)
INK = (48, 40, 28, 255)
SPARK = (196, 216, 232, 255)


def clip(draw, x, y, dx, dy):
    draw.line((x, y, x + dx * 28, y), fill=BRASS, width=8)
    draw.line((x, y, x, y + dy * 28), fill=BRASS, width=8)
    draw.ellipse((x - 6, y - 6, x + 6, y + 6), fill=SHEEN, outline=INK, width=2)


def sparkle(draw, cx, cy, r):
    draw.line((cx, cy - r, cx, cy + r), fill=SHEEN, width=4)
    draw.line((cx - r, cy, cx + r, cy), fill=SHEEN, width=4)
    draw.line((cx - r // 2, cy - r // 2, cx + r // 2, cy + r // 2), fill=SPARK, width=3)
    draw.line((cx - r // 2, cy + r // 2, cx + r // 2, cy - r // 2), fill=SPARK, width=3)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im, "RGBA")

    # Outer silver frame only — interior stays fully transparent.
    d.rounded_rectangle((4, 4, W - 5, H - 5), radius=16, outline=SILVER, width=8)
    d.rounded_rectangle((14, 14, W - 15, H - 15), radius=10, outline=SHEEN, width=3)

    clip(d, 18, 18, 1, 1)
    clip(d, W - 19, 18, -1, 1)
    clip(d, 18, H - 19, 1, -1)
    clip(d, W - 19, H - 19, -1, -1)

    sparkle(d, 48, 72, 14)
    sparkle(d, W - 52, 118, 10)
    sparkle(d, 70, H - 78, 12)
    sparkle(d, W - 64, H - 48, 8)

    # Sparse diagonal sheen ticks, not a filled veil.
    for i in range(5):
        x0 = 36 + i * 18
        y0 = 54 + i * 28
        d.line((x0, y0, x0 + 28, y0 + 10), fill=SPARK, width=3)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
