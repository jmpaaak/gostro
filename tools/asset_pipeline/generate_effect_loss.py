#!/usr/bin/env python3
"""Project-authored 960x540 loss overlay master.

Korean hwatu defeat veil: indigo dusk, broken dancheong rays, extinguished
center mark, and five geometric type marks. No people, month names, month
numbers, or Latin letters.
"""

from math import cos, pi, sin
from pathlib import Path

from PIL import Image, ImageDraw

W, H = 960, 540
OUT = Path("assets/masters/ui/effect-loss-v1.png")


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
    gold = (168, 148, 92, 255)
    crimson = (132, 36, 42, 255)
    indigo = (36, 58, 108, 255)
    orchid = (148, 118, 156, 255)
    pine = (42, 86, 68, 255)
    ink = (18, 10, 14, 255)

    # hongdan red flag, drooping
    draw.polygon(
        [(cx - 250, cy - 42), (cx - 170, cy - 86), (cx - 176, cy - 8)],
        fill=crimson,
        outline=gold,
    )
    draw.rectangle((cx - 258, cy - 96, cx - 246, cy + 8), fill=ink)

    # cheongdan blue flag, drooping
    draw.polygon(
        [(cx + 250, cy - 42), (cx + 170, cy - 86), (cx + 176, cy - 8)],
        fill=indigo,
        outline=gold,
    )
    draw.rectangle((cx + 246, cy - 96, cx + 258, cy + 8), fill=ink)

    # chodan orchid diamond
    draw.polygon(
        [(cx - 220, cy + 108), (cx - 188, cy + 66), (cx - 156, cy + 108), (cx - 188, cy + 150)],
        fill=orchid,
        outline=gold,
    )

    # godori animal diamond
    draw.polygon(
        [(cx + 220, cy + 108), (cx + 188, cy + 66), (cx + 156, cy + 108), (cx + 188, cy + 150)],
        fill=pine,
        outline=gold,
    )
    draw.ellipse((cx + 176, cy + 96, cx + 200, cy + 120), fill=gold)

    # pi stacked bars
    for i, y in enumerate((cy + 158, cy + 176, cy + 194)):
        draw.rounded_rectangle(
            (cx - 28, y, cx + 28, y + 10),
            radius=3,
            fill=gold if i != 1 else crimson,
        )


def loss_overlay() -> Image.Image:
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(im, "RGBA")
    cx, cy = W // 2, H // 2

    draw.ellipse((cx - 430, cy - 210, cx + 430, cy + 210), fill=(8, 6, 16, 170))
    draw.ellipse((cx - 360, cy - 170, cx + 360, cy + 170), fill=(42, 16, 28, 140))

    for i in range(16):
        angle = i * pi / 8 + 0.12
        inner = polar(cx, cy, 40, angle)
        outer_a = polar(cx, cy, 248, angle - 0.05)
        outer_b = polar(cx, cy, 248, angle + 0.05)
        color = (78, 92, 148, 70) if i % 2 == 0 else (118, 42, 54, 55)
        draw.polygon([inner, outer_a, outer_b], fill=color)

    draw.ellipse((cx - 210, cy - 96, cx + 210, cy + 96), fill=(92, 78, 118, 210))
    draw.ellipse((cx - 186, cy - 78, cx + 186, cy + 78), fill=(92, 24, 36, 235))
    draw.ellipse((cx - 158, cy - 58, cx + 158, cy + 58), fill=(16, 8, 14, 240))
    star(draw, cx, cy, 88, 34, 8, (168, 148, 92, 255), outline=(214, 196, 132, 255), width=4)
    star(draw, cx, cy, 36, 12, 8, (42, 18, 22, 255))

    # Broken ray across the extinguished center mark.
    draw.line((cx - 96, cy - 18, cx + 96, cy + 18), fill=(214, 196, 132, 255), width=8)
    draw.line((cx - 92, cy - 22, cx + 100, cy + 14), fill=(16, 8, 14, 180), width=3)

    hwatu_marks(draw, cx, cy)

    brass = (132, 108, 58, 255)
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
    loss_overlay().save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
