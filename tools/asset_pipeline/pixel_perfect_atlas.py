#!/usr/bin/env python3
import sys
import json
import urllib.request
from pathlib import Path

# Use the read_rgba and write_rgba from pixel_perfect
import pixel_perfect

def split_atlas(width, height, pixels, cols, rows):
    frames = []
    frame_w = width // cols
    frame_h = height // rows
    for r in range(rows):
        for c in range(cols):
            frame_pixels = bytearray(frame_w * frame_h * 4)
            for y in range(frame_h):
                src_y = r * frame_h + y
                src_x = c * frame_w
                src_idx = (src_y * width + src_x) * 4
                dst_idx = y * frame_w * 4
                frame_pixels[dst_idx:dst_idx + frame_w * 4] = pixels[src_idx:src_idx + frame_w * 4]
            frames.append(frame_pixels)
    return frames, frame_w, frame_h

def merge_atlas(frames, frame_w, frame_h, cols, rows):
    width = frame_w * cols
    height = frame_h * rows
    pixels = bytearray(width * height * 4)
    for i, frame in enumerate(frames):
        r = i // cols
        c = i % cols
        for y in range(frame_h):
            dst_y = r * frame_h + y
            dst_x = c * frame_w
            dst_idx = (dst_y * width + dst_x) * 4
            src_idx = y * frame_w * 4
            pixels[dst_idx:dst_idx + frame_w * 4] = frame[src_idx:src_idx + frame_w * 4]
    return width, height, pixels

def get_session():
    req = urllib.request.Request("http://127.0.0.1:4176/index.html")
    with urllib.request.urlopen(req) as resp:
        cookies = resp.headers.get_all('Set-Cookie')
        if not cookies:
            return "", ""
        cookie_str = "; ".join(c.split(";")[0] for c in cookies)
        csrf = ""
        for c in cookies:
            if "pas_csrf=" in c:
                csrf = c.split("pas_csrf=")[1].split(";")[0]
        return cookie_str, csrf

def process_frame(width, height, pixels, target_w, target_h):
    payload = {
        "image": {"width": width, "height": height, "data": list(pixels)},
        "targetWidth": target_w,
        "targetHeight": target_h,
        "pixelBlock": 1,
        "backgroundTolerance": 0,
        "paletteLimit": "original",
    }
    
    cookie_str, csrf = get_session()
    headers = {
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
        "Referer": "http://127.0.0.1:4176/index.html",
        "Origin": "http://127.0.0.1:4176",
        "Accept": "application/json",
        "Cookie": cookie_str,
        "x-pas-csrf": csrf
    }
    
    request = urllib.request.Request(
        "http://127.0.0.1:4176/api/pixel-perfect",
        data=json.dumps(payload, separators=(",", ":")).encode(),
        headers=headers,
        method="POST",
    )
    with urllib.request.urlopen(request, timeout=30) as response:
        result = json.load(response)
    if not result.get("report", {}).get("valid"):
        raise RuntimeError(f"Pixel Perfect validation failed: {result.get('report')}")
    image = result["image"]
    return image["width"], image["height"], bytearray(image["data"]), result["report"]

def main():
    master = sys.argv[1]
    output = sys.argv[2]
    cols = 4
    rows = 2
    target_frame_w = 56
    target_frame_h = 56

    width, height, pixels = pixel_perfect.read_rgba(master)
    frames, frame_w, frame_h = split_atlas(width, height, pixels, cols, rows)
    
    out_frames = []
    reports = []
    for i, f in enumerate(frames):
        print(f"Processing frame {i}...")
        tw, th, tp, rep = process_frame(frame_w, frame_h, f, target_frame_w, target_frame_h)
        out_frames.append(tp)
        reports.append(rep)
        
    out_w, out_h, out_pixels = merge_atlas(out_frames, target_frame_w, target_frame_h, cols, rows)
    pixel_perfect.write_rgba(output, out_w, out_h, out_pixels)
    
    report_path = Path(output).with_suffix(".report.json")
    report_path.write_text(json.dumps(reports[0], indent=2, sort_keys=True) + "\n")
    print(f"Successfully processed atlas. Output: {output}")

if __name__ == "__main__":
    main()
