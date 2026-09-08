#!/usr/bin/env python3
"""Convert an RGBA PNG through Asset Studio's real Pixel Perfect endpoint."""

import argparse
import json
import struct
import urllib.request
import zlib
from pathlib import Path

PNG = b"\x89PNG\r\n\x1a\n"


def chunks(data):
    at = 8
    while at < len(data):
        size = struct.unpack(">I", data[at : at + 4])[0]
        kind = data[at + 4 : at + 8]
        yield kind, data[at + 8 : at + 8 + size]
        at += size + 12


def paeth(a, b, c):
    p = a + b - c
    distances = abs(p - a), abs(p - b), abs(p - c)
    return (a, b, c)[distances.index(min(distances))]


def read_rgba(path):
    data = Path(path).read_bytes()
    if not data.startswith(PNG):
        raise ValueError("master must be a PNG")
    parts = list(chunks(data))
    header = next(payload for kind, payload in parts if kind == b"IHDR")
    width, height, depth, color, compression, filtering, interlace = struct.unpack(">IIBBBBB", header)
    if (depth, color, compression, filtering, interlace) != (8, 6, 0, 0, 0):
        raise ValueError("master must be non-interlaced 8-bit RGBA")
    raw = zlib.decompress(b"".join(payload for kind, payload in parts if kind == b"IDAT"))
    stride = width * 4
    rows, previous, at = [], bytearray(stride), 0
    for _ in range(height):
        method, scan = raw[at], bytearray(raw[at + 1 : at + 1 + stride])
        at += stride + 1
        for x in range(stride):
            left = scan[x - 4] if x >= 4 else 0
            up = previous[x]
            upper_left = previous[x - 4] if x >= 4 else 0
            predictor = (0, left, up, (left + up) // 2, paeth(left, up, upper_left))[method]
            scan[x] = (scan[x] + predictor) & 255
        rows.append(scan)
        previous = scan
    return width, height, bytes().join(rows)


def make_chunk(kind, payload):
    body = kind + payload
    return struct.pack(">I", len(payload)) + body + struct.pack(">I", zlib.crc32(body) & 0xFFFFFFFF)


def write_rgba(path, width, height, pixels):
    stride = width * 4
    raw = b"".join(b"\0" + bytes(pixels[y * stride : (y + 1) * stride]) for y in range(height))
    header = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)
    encoded = PNG + make_chunk(b"IHDR", header) + make_chunk(b"IDAT", zlib.compress(raw, 9)) + make_chunk(b"IEND", b"")
    destination = Path(path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(encoded)


def convert(args):
    width, height, pixels = read_rgba(args.master)
    payload = {
        "image": {"width": width, "height": height, "data": list(pixels)},
        "targetWidth": args.width,
        "targetHeight": args.height,
        "pixelBlock": args.pixel_block,
        "backgroundTolerance": args.background_tolerance,
        "paletteLimit": args.palette,
    }
    request = urllib.request.Request(
        args.endpoint,
        data=json.dumps(payload, separators=(",", ":")).encode(),
        headers={"content-type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        result = json.load(response)
    if not result.get("report", {}).get("valid"):
        raise RuntimeError(f"Pixel Perfect validation failed: {result.get('report')}")
    image = result["image"]
    write_rgba(args.output, image["width"], image["height"], image["data"])
    report_path = Path(args.output).with_suffix(".report.json")
    report_path.write_text(json.dumps(result["report"], indent=2, sort_keys=True) + "\n")
    print(json.dumps({"output": args.output, "report": str(report_path), **result["report"]}, sort_keys=True))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("master")
    parser.add_argument("output")
    parser.add_argument("--endpoint", default="http://127.0.0.1:4176/api/pixel-perfect")
    parser.add_argument("--width", type=int, required=True)
    parser.add_argument("--height", type=int, required=True)
    parser.add_argument("--pixel-block", type=int, default=1)
    parser.add_argument("--background-tolerance", type=int, default=0)
    parser.add_argument("--palette", default="original")
    convert(parser.parse_args())


if __name__ == "__main__":
    main()