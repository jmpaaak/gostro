#!/usr/bin/env python3
"""Project-authored 192x288 hologram play-card overlay master.

Korean hwatu rainbow sheen: five-color prism frame and geometric ticks.
Hard-alpha interior so the 24x36 hwatu face stays identifiable.
No people, month names, month numbers, or Latin letters.
"""

from pathlib import Path

from PIL import Image, ImageDraw

W, H, OUT = 192, 288, Path("assets/masters/effect/hologram-v1.png")
MAGENTA, CYAN, LIME = (196, 48, 140, 255), (40, 180, 196, 255), (88, 196, 72, 255)
AMBER, GOLD, INK = (232, 164, 48, 255), (214, 168, 72, 255), (40, 28, 72, 255)


def prism(draw, x, y, dx, dy):
    draw.line((x, y, x + dx * 28, y), fill=CYAN, width=8)
    draw.line((x, y, x, y + dy * 28), fill=MAGENTA, width=8)
    draw.ellipse((x - 6, y - 6, x + 6, y + 6), fill=GOLD, outline=INK, width=2)


def sparkle(draw, cx, cy, r, a, b):
    draw.line((cx, cy - r, cx, cy + r), fill=a, width=4)
    draw.line((cx - r, cy, cx + r, cy), fill=b, width=4)
    draw.line((cx - r // 2, cy - r // 2, cx + r // 2, cy + r // 2), fill=GOLD, width=3)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im, "RGBA")
    d.rounded_rectangle((4, 4, W - 5, H - 5), radius=16, outline=CYAN, width=8)
    d.rounded_rectangle((14, 14, W - 15, H - 15), radius=10, outline=MAGENTA, width=3)
    prism(d, 18, 18, 1, 1)
    prism(d, W - 19, 18, -1, 1)
    prism(d, 18, H - 19, 1, -1)
    prism(d, W - 19, H - 19, -1, -1)
    sparkle(d, 48, 72, 14, LIME, AMBER)
    sparkle(d, W - 52, 118, 10, MAGENTA, CYAN)
    sparkle(d, 70, H - 78, 12, CYAN, LIME)
    sparkle(d, W - 64, H - 48, 8, AMBER, MAGENTA)
    for i in range(5):
        x0, y0 = 36 + i * 18, 54 + i * 28
        d.line((x0, y0, x0 + 28, y0 + 10), fill=(LIME, CYAN, MAGENTA, AMBER, GOLD)[i], width=3)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
