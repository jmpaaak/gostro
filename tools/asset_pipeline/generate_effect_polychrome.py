#!/usr/bin/env python3
"""Project-authored 192x288 polychrome play-card overlay master.

Korean hwatu nacre sheen: iridescent fan corners and rainbow ticks.
Hard-alpha interior so the 24x36 hwatu face stays identifiable.
No people, month names, month numbers, or Latin letters.
"""

from pathlib import Path

from PIL import Image, ImageDraw

W, H, OUT = 192, 288, Path("assets/masters/effect/polychrome-v1.png")
ROSE, AMBER, LIME = (220, 72, 108, 255), (236, 180, 48, 255), (72, 188, 92, 255)
CYAN, VIOLET, GOLD = (48, 164, 212, 255), (148, 84, 196, 255), (214, 168, 72, 255)
INK = (40, 32, 48, 255)


def fan(draw, box, a, b, fill):
    draw.pieslice(box, a, b, fill=fill, outline=INK, width=2)


def sparkle(draw, cx, cy, r, a, b):
    draw.line((cx, cy - r, cx, cy + r), fill=a, width=4)
    draw.line((cx - r, cy, cx + r, cy), fill=b, width=4)
    draw.line((cx - r // 2, cy - r // 2, cx + r // 2, cy + r // 2), fill=GOLD, width=3)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(im, "RGBA")
    d.rounded_rectangle((4, 4, W - 5, H - 5), radius=16, outline=VIOLET, width=8)
    d.rounded_rectangle((14, 14, W - 15, H - 15), radius=10, outline=CYAN, width=3)
    fan(d, (6, 6, 58, 58), 180, 270, ROSE)
    fan(d, (W - 59, 6, W - 7, 58), 270, 360, AMBER)
    fan(d, (6, H - 59, 58, H - 7), 90, 180, LIME)
    fan(d, (W - 59, H - 59, W - 7, H - 7), 0, 90, CYAN)
    sparkle(d, 52, 86, 12, ROSE, CYAN)
    sparkle(d, W - 56, 128, 10, AMBER, VIOLET)
    sparkle(d, 76, H - 84, 12, LIME, ROSE)
    sparkle(d, W - 68, H - 52, 8, CYAN, GOLD)
    for i, col in enumerate((ROSE, AMBER, LIME, CYAN, VIOLET)):
        x0, y0 = 40 + i * 16, 60 + i * 26
        d.line((x0, y0, x0 + 24, y0 + 8), fill=col, width=3)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
