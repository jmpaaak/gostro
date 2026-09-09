#!/usr/bin/env python3
"""Project-authored 400x560 쌍둥이 부적 (copy talisman) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 400, 560, Path("assets/masters/tarot/the-lovers-v1.png")
ROSE, LACQUER = (168, 48, 72, 255), (48, 16, 24, 255)
GOLD, PAPER = (214, 168, 72, 255), (244, 228, 208, 255)
SILK, SHADOW = (120, 32, 56, 255), (24, 8, 12, 255)
PEARL, CRIMSON = (255, 244, 214, 255), (168, 28, 36, 255)
TEAL = (24, 72, 78, 255)


def fan(d, cx, cy):
    d.polygon([(cx - 56, cy + 54), (cx, cy - 72), (cx + 56, cy + 54)], fill=ROSE, outline=GOLD)
    d.polygon([(cx - 28, cy + 28), (cx, cy - 36), (cx + 28, cy + 28)], fill=PAPER)
    d.ellipse((cx - 16, cy - 8, cx + 16, cy + 24), fill=LACQUER)
    d.ellipse((cx - 7, cy, cx + 7, cy + 14), fill=PEARL)


def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2
    d.rounded_rectangle((18, 22, W - 18, H - 10), 28, fill=SHADOW)
    d.rounded_rectangle((12, 14, W - 12, H - 18), 26, fill=LACQUER, outline=GOLD, width=10)
    d.rounded_rectangle((28, 30, W - 28, H - 34), 18, fill=PAPER, outline=ROSE, width=8)
    d.polygon([(cx - 70, 14), (cx + 70, 14), (cx + 52, 46), (cx - 52, 46)], fill=GOLD, outline=LACQUER)
    d.ellipse((cx - 10, 22, cx + 10, 42), fill=ROSE)
    d.rectangle((48, 78, W - 48, 118), fill=SILK)
    d.polygon([(48, 78), (88, 58), (128, 78), (168, 58), (208, 78), (248, 58), (288, 78), (328, 58), (352, 78)], fill=GOLD)
    # Copy mark: twin hwatu fans and a linking bar. No people or month art.
    fan(d, 148, 236)
    fan(d, 252, 236)
    d.rectangle((168, 248, 232, 264), fill=GOLD)
    d.polygon([(72, 360), (cx, 332), (W - 72, 360), (cx, 402)], fill=ROSE, outline=GOLD)
    d.polygon([(cx - 90, 430), (cx, 390), (cx + 90, 430), (cx, 470)], fill=SILK, outline=GOLD)
    d.rounded_rectangle((cx + 78, 392, cx + 146, 460), 6, fill=CRIMSON, outline=GOLD, width=6)
    d.line((cx + 90, 410, cx + 134, 410), fill=GOLD, width=6)
    d.line((cx + 90, 428, cx + 134, 428), fill=GOLD, width=6)
    d.line((cx + 90, 444, cx + 134, 444), fill=GOLD, width=6)
    d.ellipse((54, 488, 86, 520), fill=ROSE)
    d.ellipse((W - 86, 488, W - 54, 520), fill=TEAL)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
