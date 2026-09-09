#!/usr/bin/env python3
"""Project-authored 960x540 background masters."""

import math
from pathlib import Path
from PIL import Image, ImageDraw

W, H = 960, 540
OUT_DIR = Path("assets/masters/ui")

def menu_bg() -> Image.Image:
    """Dark teal background with red and yellow circles (plum blossom motif)."""
    im = Image.new("RGBA", (W, H), (10, 46, 46, 255))
    draw = ImageDraw.Draw(im, "RGBA")
    
    # Red circles
    # At 3x scale: 30,27 r=16 -> 90, 81 r=48
    draw.ellipse((90 - 48, 81 - 48, 90 + 48, 81 + 48), fill=(184, 31, 41, 71))
    
    # 290, 153 r=19 -> 870, 459 r=57
    draw.ellipse((870 - 57, 459 - 57, 870 + 57, 459 + 57), fill=(184, 31, 41, 71))
    
    # Yellow circles (plum blossoms)
    # 30, 27 center
    # distance 8 -> 24
    # radius 4 -> 12
    yellow_fill = (240, 184, 56, 87)
    for i in range(5):
        angle = i * math.pi * 2 / 5
        cx = 90 + math.cos(angle) * 24
        cy = 81 + math.sin(angle) * 24
        draw.ellipse((cx - 12, cy - 12, cx + 12, cy + 12), fill=yellow_fill)
        
    # Center dot
    # radius 3 -> 9
    draw.ellipse((90 - 9, 81 - 9, 90 + 9, 81 + 9), fill=yellow_fill)
    
    return im

def run() -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    menu_path = OUT_DIR / "menu-bg-v1.png"
    menu_bg().save(menu_path)
    print(f"Saved {menu_path}")

if __name__ == "__main__":
    run()
