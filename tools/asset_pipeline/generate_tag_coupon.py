#!/usr/bin/env python3
"""Project-authored 256x384 단골 패찰 (coupon tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/coupon-v1.png")
WOOD = (160, 100, 60, 255)
DARK_WOOD = (100, 50, 20, 255)
GOLD = (214, 168, 72, 255)
PAPER = (244, 228, 208, 255)
RED = (180, 40, 40, 255)

def run():
    im = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d, cx = ImageDraw.Draw(im, "RGBA"), W // 2
    
    # Hanging rope
    d.line((cx, 20, cx - 40, 80), fill=GOLD, width=12)
    d.line((cx, 20, cx + 40, 80), fill=GOLD, width=12)
    d.ellipse((cx - 16, 8, cx + 16, 40), fill=GOLD)
    
    # Wooden plaque body
    d.polygon([(cx - 80, 60), (cx + 80, 60), (cx + 100, 90), (cx + 100, H - 40), (cx - 100, H - 40), (cx - 100, 90)], fill=DARK_WOOD)
    d.polygon([(cx - 70, 70), (cx + 70, 70), (cx + 88, 96), (cx + 88, H - 52), (cx - 88, H - 52), (cx - 88, 96)], fill=WOOD)
    
    # Paper inside
    d.rectangle((cx - 60, 110, cx + 60, H - 70), fill=PAPER, outline=DARK_WOOD, width=4)
    
    # "Coupon" symbol - red stamp (단골 = regular customer)
    d.ellipse((cx - 40, 140, cx + 40, 220), outline=RED, width=8)
    d.rectangle((cx - 20, 160, cx + 20, 200), fill=RED)
    d.line((cx - 20, 180, cx + 20, 180), fill=PAPER, width=4)
    
    # Decorative bottom fringe
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=RED, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=RED, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=RED, width=8)
    
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")

if __name__ == "__main__":
    run()
