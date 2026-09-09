#!/usr/bin/env python3
"""Project-authored 256x384 거상 패찰 (investment tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/investment-v1.png")
WOOD = (148, 92, 44, 255)
DARK_WOOD = (84, 42, 16, 255)
GOLD = (214, 168, 72, 255)
PAPER = (244, 228, 208, 255)
COIN = (196, 140, 48, 255)
COIN_CORE = (255, 220, 120, 255)
INK = (72, 28, 12, 255)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2

    # Hanging rope
    d.line((cx, 20, cx - 40, 80), fill=GOLD, width=12)
    d.line((cx, 20, cx + 40, 80), fill=GOLD, width=12)
    d.ellipse((cx - 16, 8, cx + 16, 40), fill=GOLD)

    # Wooden plaque body
    d.polygon(
        [
            (cx - 80, 60),
            (cx + 80, 60),
            (cx + 100, 90),
            (cx + 100, H - 40),
            (cx - 100, H - 40),
            (cx - 100, 90),
        ],
        fill=DARK_WOOD,
    )
    d.polygon(
        [
            (cx - 70, 70),
            (cx + 70, 70),
            (cx + 88, 96),
            (cx + 88, H - 52),
            (cx - 88, H - 52),
            (cx - 88, 96),
        ],
        fill=WOOD,
    )

    # Paper inside
    d.rectangle((cx - 60, 110, cx + 60, H - 70), fill=PAPER, outline=DARK_WOOD, width=4)

    # Merchant coin stack: extra-money skip tag. No text, people, or month art.
    d.ellipse((cx - 36, 148, cx + 36, 220), fill=COIN, outline=GOLD, width=6)
    d.ellipse((cx - 20, 164, cx + 20, 204), fill=COIN_CORE)
    d.rectangle((cx - 6, 176, cx + 6, 192), fill=INK)
    d.ellipse((cx - 28, 212, cx + 28, 248), fill=GOLD, outline=DARK_WOOD, width=4)
    d.ellipse((cx - 22, 232, cx + 22, 266), fill=COIN, outline=GOLD, width=4)

    # Decorative bottom fringe in gold (merchant wealth)
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=GOLD, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=GOLD, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=GOLD, width=8)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
