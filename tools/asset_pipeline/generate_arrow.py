#!/usr/bin/env python3
from PIL import Image, ImageDraw
import argparse
from pathlib import Path

def draw_arrow(path, points_right):
    width = 624
    height = 432
    
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Draw arrow polygon
    cx, cy = width // 2, height // 2
    direction = 1 if points_right else -1
    
    points = [
        (cx + 150 * direction, cy),
        (cx - 100 * direction, cy - 150),
        (cx - 100 * direction, cy + 150)
    ]
    draw.polygon(points, fill=(255, 230, 160, 255))
    
    # Save
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("left")
    parser.add_argument("right")
    args = parser.parse_args()
    
    draw_arrow(args.left, False)
    draw_arrow(args.right, True)
