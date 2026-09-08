#!/usr/bin/env python3
"""Generate 320×180 wireframe PNGs for Gostro UI screens."""
from PIL import Image, ImageDraw
import os, datetime

OUT = os.path.join(os.path.dirname(__file__), "..", "docs", "wireframes")
os.makedirs(OUT, exist_ok=True)
BG, FG, FILL = (30, 30, 30), (200, 200, 200), (80, 80, 80)

def img():
    im = Image.new("RGB", (320, 180), BG)
    return im, ImageDraw.Draw(im)

def box(d, x, y, w, h, label=""):
    d.rectangle([x, y, x+w, y+h], outline=FG, fill=FILL)
    if label: d.text((x+2, y+2), label, fill=FG)

def save(im, name):
    p = os.path.join(OUT, name)
    im.save(p)
    return p

# (a) Play screen: top gwang slots, center score, bottom hand 8 cards, buttons
im, d = img()
for i in range(5): box(d, 10+i*30, 4, 24, 24, "★" if i==0 else "")  # gwang slots y=4
box(d, 100, 40, 120, 30, "SCORE chips×mult")  # scoreboard y=40
for i in range(8): box(d, 10+i*38, 130, 24, 36, f"C{i+1}")  # hand y=130
box(d, 100, 90, 50, 20, "PLAY"); box(d, 170, 90, 50, 20, "DISCARD")  # buttons y=90
paths = [save(im, "play.png")]

# (b) Shop screen: 3 gwang jokers, reroll/next, money
im, d = img()
for i in range(3): box(d, 60+i*70, 30, 50, 70, f"Gwang{i+1}\n$$$")  # jokers y=30
box(d, 60, 120, 60, 20, "REROLL"); box(d, 200, 120, 60, 20, "NEXT")  # y=120
box(d, 130, 150, 60, 20, "$MONEY")  # y=150
paths.append(save(im, "shop.png"))

# (c) Blind select: small/big/boss cards, ante display
im, d = img()
box(d, 120, 8, 80, 20, "ANTE 1")  # ante y=8
for i, lbl in enumerate(["SMALL","BIG","BOSS"]): box(d, 30+i*100, 50, 60, 90, lbl)
paths.append(save(im, "blind_select.png"))

# (d) Result screen: score + chips×mult breakdown
im, d = img()
box(d, 60, 20, 200, 40, "ROUND RESULT")  # y=20
box(d, 80, 80, 160, 30, "Chips: 120"); box(d, 80, 120, 160, 30, "Mult: x4 = 480")
paths.append(save(im, "result.png"))

ts = datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=9))).strftime("%Y-%m-%dT%H:%M:%S+0900")
log = os.path.join(os.path.dirname(__file__), "..", "docs", "GENERATED_ASSET_LOG.md")
existed = os.path.exists(log)
with open(log, "a") as f:
    if not existed: f.write("# Generated Asset Log\n\n| Timestamp | Path | Description |\n|---|---|---|\n")
    for p in paths:
        rel = os.path.relpath(p, os.path.join(os.path.dirname(__file__), ".."))
        f.write(f"| {ts} | `{rel}` | 320×180 wireframe |\n")
print(f"Generated {len(paths)} wireframes, logged to {log}")
