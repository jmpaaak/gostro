#!/usr/bin/env python3
"""Project-authored 400x560 소멸 부적 (destroy talisman) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 400, 560, Path("assets/masters/tarot/the-hanged-man-v1.png")
INDIGO, LACQUER = (60, 44, 120, 255), (24, 16, 44, 255)
GOLD, PAPER = (214, 168, 72, 255), (232, 220, 196, 255)
SILK, SHADOW = (36, 24, 72, 255), (12, 8, 24, 255)
PEARL, CRIMSON = (255, 244, 214, 255), (168, 28, 36, 255)
TEAL = (24, 72, 78, 255)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2
    d.rounded_rectangle((18, 22, W - 18, H - 10), 28, fill=SHADOW)
    d.rounded_rectangle((12, 14, W - 12, H - 18), 26, fill=LACQUER, outline=GOLD, width=10)
    d.rounded_rectangle((28, 30, W - 28, H - 34), 18, fill=PAPER, outline=INDIGO, width=8)
    d.polygon([(cx - 70, 14), (cx + 70, 14), (cx + 52, 46), (cx - 52, 46)], fill=GOLD, outline=LACQUER)
    d.ellipse((cx - 10, 22, cx + 10, 42), fill=INDIGO)
    d.rectangle((48, 78, W - 48, 118), fill=SILK)
    d.polygon([(48, 78), (88, 58), (128, 78), (168, 58), (208, 78), (248, 58), (288, 78), (328, 58), (352, 78)], fill=GOLD)
    # Extinguish mark: inverted lantern beam, vanishing flame, ash seal — no people or month art.
    d.rounded_rectangle((92, 168, W - 92, 196), 4, fill=INDIGO, outline=GOLD, width=8)
    d.polygon([(168, 196), (cx, 248), (232, 196)], fill=GOLD)
    d.polygon([(124, 248), (276, 248), (258, 380), (142, 380)], fill=SILK, outline=GOLD)
    d.polygon([(148, 272), (252, 272), (240, 364), (160, 364)], fill=PAPER)
    d.ellipse((cx - 28, 272, cx + 28, 344), fill=CRIMSON)
    d.ellipse((cx - 12, 284, cx + 12, 316), fill=PEARL)
    d.polygon([(188, 336), (cx, 372), (212, 336)], fill=INDIGO)
    d.polygon([(72, 360), (cx, 332), (W - 72, 360), (cx, 402)], fill=INDIGO, outline=GOLD)
    d.polygon([(cx - 90, 430), (cx, 390), (cx + 90, 430), (cx, 470)], fill=SILK, outline=GOLD)
    d.rounded_rectangle((cx + 78, 392, cx + 146, 460), 6, fill=CRIMSON, outline=GOLD, width=6)
    d.line((cx + 90, 410, cx + 134, 410), fill=GOLD, width=6)
    d.line((cx + 90, 428, cx + 134, 428), fill=GOLD, width=6)
    d.line((cx + 90, 444, cx + 134, 444), fill=GOLD, width=6)
    d.ellipse((54, 488, 86, 520), fill=INDIGO)
    d.ellipse((W - 86, 488, W - 54, 520), fill=TEAL)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
