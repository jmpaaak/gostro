#!/usr/bin/env python3
"""Project-authored 400x560 강화 부적 (enhance talisman) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 400, 560, Path("assets/masters/tarot/the-chariot-v1.png")
AMBER, LACQUER = (196, 92, 28, 255), (44, 20, 12, 255)
GOLD, PAPER = (214, 168, 72, 255), (244, 236, 212, 255)
SILK, SHADOW = (110, 36, 12, 255), (24, 8, 8, 255)
PEARL, CRIMSON = (255, 244, 214, 255), (168, 28, 36, 255)
TEAL = (24, 72, 78, 255)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2
    d.rounded_rectangle((18, 22, W - 18, H - 10), 28, fill=SHADOW)
    d.rounded_rectangle((12, 14, W - 12, H - 18), 26, fill=LACQUER, outline=GOLD, width=10)
    d.rounded_rectangle((28, 30, W - 28, H - 34), 18, fill=PAPER, outline=AMBER, width=8)
    d.polygon([(cx - 70, 14), (cx + 70, 14), (cx + 52, 46), (cx - 52, 46)], fill=GOLD, outline=LACQUER)
    d.ellipse((cx - 10, 22, cx + 10, 42), fill=AMBER)
    d.rectangle((48, 78, W - 48, 118), fill=SILK)
    d.polygon([(48, 78), (88, 58), (128, 78), (168, 58), (208, 78), (248, 58), (288, 78), (328, 58), (352, 78)], fill=GOLD)
    # Enhance mark: palanquin canopy, twin poles, foil diamond — no people or month art.
    d.rectangle((72, 248, W - 72, 264), fill=GOLD)
    d.rounded_rectangle((88, 232, 128, 280), 4, fill=SILK, outline=GOLD, width=6)
    d.rounded_rectangle((272, 232, 312, 280), 4, fill=SILK, outline=GOLD, width=6)
    d.polygon([(124, 176), (276, 176), (292, 248), (108, 248)], fill=AMBER, outline=GOLD)
    d.polygon([(140, 196), (260, 196), (270, 236), (130, 236)], fill=PAPER)
    d.polygon([(168, 176), (cx, 132), (232, 176), (cx, 196)], fill=GOLD)
    d.polygon([(188, 148), (cx, 116), (212, 148)], fill=PEARL)
    d.ellipse((cx - 22, 196, cx + 22, 232), fill=LACQUER)
    d.ellipse((cx - 10, 206, cx + 10, 222), fill=PEARL)
    d.rounded_rectangle((108, 264, 292, 360), 8, fill=SILK, outline=GOLD, width=8)
    d.rectangle((128, 284, 272, 340), fill=AMBER)
    d.polygon([(148, 296), (cx, 268), (252, 296), (cx, 336)], fill=PEARL, outline=GOLD)
    d.polygon([(72, 360), (cx, 332), (W - 72, 360), (cx, 402)], fill=AMBER, outline=GOLD)
    d.polygon([(cx - 90, 430), (cx, 390), (cx + 90, 430), (cx, 470)], fill=SILK, outline=GOLD)
    d.rounded_rectangle((cx + 78, 392, cx + 146, 460), 6, fill=CRIMSON, outline=GOLD, width=6)
    d.line((cx + 90, 410, cx + 134, 410), fill=GOLD, width=6)
    d.line((cx + 90, 428, cx + 134, 428), fill=GOLD, width=6)
    d.line((cx + 90, 444, cx + 134, 444), fill=GOLD, width=6)
    d.ellipse((54, 488, 86, 520), fill=AMBER)
    d.ellipse((W - 86, 488, W - 54, 520), fill=TEAL)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
