#!/usr/bin/env python3
"""Project-authored 256x384 주령구 패찰 (d6 tag) master."""
from pathlib import Path
from PIL import Image, ImageDraw

W, H, OUT = 256, 384, Path("assets/masters/tag/d6-v1.png")
WOOD, DARK, GOLD = (116, 64, 36, 255), (52, 24, 12, 255), (214, 168, 72, 255)
PAPER, INK = (248, 232, 208, 255), (48, 20, 16, 255)
CELADON, CREAM, CRIMSON = (72, 140, 116, 255), (232, 212, 168, 255), (176, 36, 48, 255)


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
    # Silla 주령구 polyhedron: two free shop rerolls. No people or months.
    d.polygon([(cx, 148), (cx + 38, 172), (cx + 24, 220), (cx - 24, 220), (cx - 38, 172)],
              fill=CELADON, outline=INK, width=4)
    d.polygon([(cx, 156), (cx + 22, 176), (cx, 196), (cx - 22, 176)], fill=CREAM, outline=GOLD, width=2)
    d.polygon([(cx + 8, 188), (cx + 30, 176), (cx + 18, 214), (cx + 4, 208)], fill=GOLD)
    d.ellipse((cx - 8, 198, cx + 8, 214), fill=CRIMSON, outline=INK, width=2)
    d.ellipse((cx - 36, 248, cx - 8, 276), fill=GOLD, outline=INK, width=3)
    d.ellipse((cx + 8, 248, cx + 36, 276), fill=GOLD, outline=INK, width=3)
    d.arc((cx - 28, 254, cx - 16, 270), 200, 340, fill=CRIMSON, width=3)
    d.arc((cx + 16, 254, cx + 28, 270), 200, 340, fill=CRIMSON, width=3)
    d.line((cx - 40, H - 40, cx - 40, H - 10), fill=CELADON, width=8)
    d.line((cx, H - 40, cx, H - 10), fill=GOLD, width=8)
    d.line((cx + 40, H - 40, cx + 40, H - 10), fill=CRIMSON, width=8)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    im.save(OUT)
    print(f"Saved {OUT}")


if __name__ == "__main__":
    run()
