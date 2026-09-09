#!/usr/bin/env python3
"""Project-authored 960x540 win overlay master.

Korean hwatu victory burst: gold sunburst, dancheong rays, five geometric
hwatu marks. No people, month names, month numbers, or Latin letters.
"""

from math import cos, pi, sin
from pathlib import Path

from PIL import Image, ImageDraw

W, H = 960, 540
OUT = Path("assets/masters/ui/effect-win-v1.png")


def polar(cx, cy, radius, angle):
    return cx + radius * cos(angle), cy + radius * sin(angle)


def star(draw, cx, cy, outer, inner, points, fill, outline=None, width=1):
    coords = []
    for i in range(points * 2):
        radius = outer if i % 2 == 0 else inner
        angle = -pi / 2 + i * pi / points
        coords.append(polar(cx, cy, radius, angle))
    draw.polygon(coords, fill=fill, outline=outline)
    if outline and width > 1:
        draw.line(coords + [coords[0]], fill=outline, width=width)


def hwatu_marks(draw, cx, cy):
    # Five geometric type marks around the burst, matching play-card grammar
    # without month illustrations or Latin abbreviations.
    gold = (255, 229, 138, 255)
    crimson = (196, 42, 36, 255)
    indigo = (28, 64, 132, 255)
    orchid = (214, 176, 214, 255)
    pine = (46, 122, 74, 255)
    ink = (42, 20, 8, 255)

    # hongdan red flag
    draw.polygon(
        [(cx - 250, cy - 70), (cx - 170, cy - 110), (cx - 170, cy - 30)],
        fill=crimson,
        outline=gold,
    )
    draw.rectangle((cx - 258, cy - 118, cx - 246, cy - 18), fill=ink)

    # cheongdan blue flag
    draw.polygon(
        [(cx + 250, cy - 70), (cx + 170, cy - 110), (cx + 170, cy - 30)],
        fill=indigo,
        outline=gold,
    )
    draw.rectangle((cx + 246, cy - 118, cx + 258, cy - 18), fill=ink)

    # chodan orchid diamond
    draw.polygon(
        [(cx - 220, cy + 96), (cx - 188, cy + 54), (cx - 156, cy + 96), (cx - 188, cy + 138)],
        fill=orchid,
        outline=gold,
    )

    # godori animal diamond
    draw.polygon(
        [(cx + 220, cy + 96), (cx + 188, cy + 54), (cx + 156, cy + 96), (cx + 188, cy + 138)],
        fill=pine,
        outline=gold,
    )
    draw.ellipse((cx + 176, cy + 84, cx + 200, cy + 108), fill=gold)

    # pi stacked bars
    for i, y in enumerate((cy + 150, cy + 168, cy + 186)):
        draw.rounded_rectangle((cx - 28, y, cx + 28, y + 10), radius=3, fill=gold if i != 1 else crimson)


def win_overlay() -> Image.Image:
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im, "RGBA")
    cx, cy = W // 2, H // 2

    draw.ellipse((cx - 430, cy - 210, cx + 430, cy + 210), fill=(18, 10, 6, 150))
    draw.ellipse((cx - 360, cy - 170, cx + 360, cy + 170), fill=(92, 28, 12, 120))

    for i in range(16):
        angle = i * pi / 8
        inner = polar(cx, cy, 48, angle)
        outer_a = polar(cx, cy, 280, angle - 0.07)
        outer_b = polar(cx, cy, 280, angle + 0.07)
        color = (255, 216, 74, 70) if i % 2 == 0 else (240, 120, 36, 55)
        draw.polygon([inner, outer_a, outer_b], fill=color)

    draw.ellipse((cx - 210, cy - 96, cx + 210, cy + 96), fill=(255, 232, 140, 210))
    draw.ellipse((cx - 186, cy - 78, cx + 186, cy + 78), fill=(196, 42, 36, 235))
    draw.ellipse((cx - 158, cy - 58, cx + 158, cy + 58), fill=(42, 16, 8, 240))
    star(draw, cx, cy, 92, 38, 8, (255, 229, 138, 255), outline=(255, 246, 200, 255), width=4)
    star(draw, cx, cy, 48, 18, 8, (255, 248, 210, 255))

    hwatu_marks(draw, cx, cy)

    brass = (214, 176, 74, 255)
    for x, y, dx, dy in (
        (36, 36, 1, 1),
        (W - 36, 36, -1, 1),
        (36, H - 36, 1, -1),
        (W - 36, H - 36, -1, -1),
    ):
        draw.line((x, y, x + dx * 72, y), fill=brass, width=10)
        draw.line((x, y, x, y + dy * 72), fill=brass, width=10)
    return im


def run() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    win_overlay().save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
