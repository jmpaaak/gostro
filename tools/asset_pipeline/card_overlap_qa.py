#!/usr/bin/env python3
"""Build a deterministic overlap capture from a Pixel Perfect contact sheet."""

import argparse
import hashlib
import json
from pathlib import Path

from pixel_perfect import read_rgba, write_rgba


def crop(pixels, width, x, y, crop_width, crop_height):
    result = bytearray()
    for row in range(y, y + crop_height):
        start = (row * width + x) * 4
        result.extend(pixels[start : start + crop_width * 4])
    return bytes(result)


def paste(canvas, canvas_width, image, width, height, x, y):
    for iy in range(height):
        for ix in range(width):
            source = (iy * width + ix) * 4
            alpha = image[source + 3]
            if alpha:
                target = ((y + iy) * canvas_width + x + ix) * 4
                canvas[target : target + 4] = image[source : source + 4]


def fingerprint(image, width, top_height=12):
    colors = {}
    for at in range(0, width * top_height * 4, 4):
        rgba = tuple(image[at : at + 4])
        if rgba[3] and max(rgba[:3]) - min(rgba[:3]) >= 30:
            colors[rgba] = colors.get(rgba, 0) + 1
    prominent = sorted(colors.items(), key=lambda pair: (-pair[1], pair[0]))[:3]
    return hashlib.sha256(bytes(sum((list(color) for color, _ in prominent), []))).hexdigest()[:12]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("sheet")
    parser.add_argument("capture")
    parser.add_argument("report")
    args = parser.parse_args()
    sheet_width, sheet_height, pixels = read_rgba(args.sheet)
    if (sheet_width, sheet_height) != (360, 108):
        raise ValueError("contact sheet must be the 360x108 Pixel Perfect output")
    cards = [crop(pixels, sheet_width, index * 72, 0, 72, 108) for index in range(5)]
    fingerprints = [fingerprint(card, 72, 30) for card in cards]
    if len(set(fingerprints)) != 5:
        raise ValueError("top-edge card marks are not uniquely identifiable")
    step, margin = 30, 2
    capture_width, capture_height = margin * 2 + 72 + step * 4, 112
    canvas = bytearray(capture_width * capture_height * 4)
    for index, card in enumerate(cards):
        paste(canvas, capture_width, card, 72, 108, margin + index * step, 2)
    write_rgba(args.capture, capture_width, capture_height, canvas)
    result = {
        "valid": True,
        "source": args.sheet,
        "capture": args.capture,
        "cardOrder": ["pi", "hongdan", "cheongdan", "chodan", "godori"],
        "cardSize": [72, 108],
        "topVisiblePixels": step,
        "topMarkFingerprints": fingerprints,
        "captureSha256": hashlib.sha256(Path(args.capture).read_bytes()).hexdigest(),
    }
    Path(args.report).write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps(result, sort_keys=True))


if __name__ == "__main__":
    main()