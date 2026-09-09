from PIL import Image, ImageDraw
from pathlib import Path

def create_button(color1, color2, shadow, out_path):
    # size 400x120
    im = Image.new("RGBA", (400, 120), (0,0,0,0))
    draw = ImageDraw.Draw(im)
    
    # shadow rect
    draw.rounded_rectangle((0, 0, 400, 120), radius=30, fill=shadow)
    
    # main rect
    draw.rounded_rectangle((0, 0, 400, 110), radius=30, fill=color1)
    
    # gradient or simple top highlight
    draw.rounded_rectangle((15, 10, 385, 40), radius=15, fill=(255,255,255, 50))
    
    out_path.parent.mkdir(parents=True, exist_ok=True)
    im.save(out_path)
    print(f"Saved {out_path}")

def run():
    out_dir = Path("assets/masters/ui")
    create_button((74, 118, 212, 255), (42, 75, 145, 255), (27, 47, 92, 255), out_dir / "btn-primary-v1.png")
    create_button((85, 173, 102, 255), (42, 102, 55, 255), (24, 61, 33, 255), out_dir / "btn-secondary-v1.png")
    create_button((212, 74, 74, 255), (145, 42, 42, 255), (92, 27, 27, 255), out_dir / "btn-danger-v1.png")
    create_button((77, 77, 77, 255), (45, 45, 45, 255), (45, 45, 45, 255), out_dir / "btn-disabled-v1.png")

if __name__ == "__main__":
    run()
