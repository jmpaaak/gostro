#!/usr/bin/env python3
"""Project-authored 256x384 알뜰 패찰 (economy tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/economy-v1.png")
WOOD, DARK, GOLD = (92, 108, 148, 255), (36, 48, 84, 255), (214, 168, 72, 255)
PAPER, INK = (232, 236, 244, 255), (28, 36, 64, 255)
COIN, COIN_CORE, STRING = (196, 140, 48, 255), (255, 220, 120, 255), (180, 64, 48, 255)


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
    # String of cash coins: extra-money skip tag. No text, people, or month art.
    d.line((cx, 148, cx, 268), fill=STRING, width=8)
    d.ellipse((cx - 28, 152, cx + 28, 208), fill=COIN, outline=GOLD, width=6)
    d.ellipse((cx - 12, 168, cx + 12, 192), fill=COIN_CORE)
    d.ellipse((cx - 24, 196, cx + 24, 244), fill=GOLD, outline=INK, width=4)
    d.ellipse((cx - 10, 210, cx + 10, 230), fill=INK)
    d.ellipse((cx - 20, 232, cx + 20, 276), fill=COIN, outline=GOLD, width=4)
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=GOLD, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=STRING, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=GOLD, width=8)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
