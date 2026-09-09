#!/usr/bin/env python3
"""Project-authored 400x560 둔갑 부적 (convert talisman) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 400, 560, Path("assets/masters/tarot/the-magician-v1.png")
VIOLET, LACQUER = (108, 44, 120, 255), (36, 20, 54, 255)
GOLD, PAPER = (214, 168, 72, 255), (244, 232, 200, 255)
SILK, SHADOW = (138, 60, 150, 255), (16, 8, 18, 255)
PEARL, CRIMSON = (255, 244, 214, 255), (168, 28, 36, 255)
TEAL = (24, 72, 78, 255)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2
    d.rounded_rectangle((18, 22, W - 18, H - 10), 28, fill=SHADOW)
    d.rounded_rectangle((12, 14, W - 12, H - 18), 26, fill=LACQUER, outline=GOLD, width=10)
    d.rounded_rectangle((28, 30, W - 28, H - 34), 18, fill=PAPER, outline=VIOLET, width=8)
    d.polygon([(cx - 70, 14), (cx + 70, 14), (cx + 52, 46), (cx - 52, 46)], fill=GOLD, outline=LACQUER)
    d.ellipse((cx - 10, 22, cx + 10, 42), fill=VIOLET)
    d.rectangle((48, 78, W - 48, 118), fill=SILK)
    d.polygon([(48, 78), (88, 58), (128, 78), (168, 58), (208, 78), (248, 58), (288, 78), (328, 58), (352, 78)], fill=GOLD)
    d.polygon([(92, 250), (168, 176), (244, 250), (168, 324)], fill=VIOLET, outline=GOLD)
    d.polygon([(156, 250), (232, 176), (308, 250), (232, 324)], fill=SILK, outline=PEARL)
    d.polygon([(168, 214), (cx, 154), (232, 214), (cx, 246)], fill=GOLD)
    d.polygon([(154, 168), (168, 128), (182, 168)], fill=PEARL)
    d.polygon([(218, 168), (232, 128), (246, 168)], fill=PEARL)
    d.ellipse((cx - 28, 214, cx + 28, 258), fill=LACQUER)
    d.ellipse((cx - 12, 226, cx + 12, 250), fill=PEARL)
    d.polygon([(72, 360), (cx, 332), (W - 72, 360), (cx, 402)], fill=SILK, outline=GOLD)
    d.polygon([(cx - 90, 430), (cx, 390), (cx + 90, 430), (cx, 470)], fill=VIOLET, outline=GOLD)
    d.rounded_rectangle((cx + 78, 392, cx + 146, 460), 6, fill=CRIMSON, outline=GOLD, width=6)
    d.line((cx + 90, 410, cx + 134, 410), fill=GOLD, width=6)
    d.line((cx + 90, 428, cx + 134, 428), fill=GOLD, width=6)
    d.line((cx + 90, 444, cx + 134, 444), fill=GOLD, width=6)
    d.ellipse((54, 488, 86, 520), fill=VIOLET)
    d.ellipse((W - 86, 488, W - 54, 520), fill=TEAL)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
