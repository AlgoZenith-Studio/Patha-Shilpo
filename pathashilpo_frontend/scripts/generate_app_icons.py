import os
import pymupdf
from PIL import Image, ImageDraw

def generate_icons():
    frontend_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    svg_path = os.path.join(frontend_dir, 'assets', 'patha-shilpo_logo.svg')
    res_dir = os.path.join(frontend_dir, 'android', 'app', 'src', 'main', 'res')
    web_dir = os.path.join(frontend_dir, 'web')

    print(f"Loading SVG from: {svg_path}")
    doc = pymupdf.open(svg_path)
    page = doc[0]
    # Render at high DPI for ultra-sharp master image
    pix = page.get_pixmap(dpi=400)
    master_img = Image.frombytes("RGB", [pix.width, pix.height], pix.samples).convert("RGBA")
    print(f"Master image size: {master_img.size}")

    # Android densities & icon dimensions
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    def make_round_icon(img, size):
        mask = Image.new('L', (size * 4, size * 4), 0)
        draw = ImageDraw.Draw(mask)
        draw.ellipse((0, 0, size * 4 - 1, size * 4 - 1), fill=255)
        mask = mask.resize((size, size), Image.Resampling.LANCZOS)
        
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        round_img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        round_img.paste(resized, (0, 0), mask=mask)
        return round_img

    for folder, size in android_sizes.items():
        target_dir = os.path.join(res_dir, folder)
        os.makedirs(target_dir, exist_ok=True)

        # Standard square/rounded icon
        standard_icon = master_img.resize((size, size), Image.Resampling.LANCZOS)
        standard_path = os.path.join(target_dir, 'ic_launcher.png')
        standard_icon.save(standard_path, format='PNG')

        # Round icon for Pixel / modern launchers
        round_icon = make_round_icon(master_img, size)
        round_path = os.path.join(target_dir, 'ic_launcher_round.png')
        round_icon.save(round_path, format='PNG')

        # Adaptive icon foreground (centered with safe padding)
        fg_size = size
        pad = int(size * 0.18)
        content_size = size - (pad * 2)
        content_img = master_img.resize((content_size, content_size), Image.Resampling.LANCZOS)
        fg_img = Image.new('RGBA', (fg_size, fg_size), (0, 0, 0, 0))
        fg_img.paste(content_img, (pad, pad))
        fg_path = os.path.join(target_dir, 'ic_launcher_foreground.png')
        fg_img.save(fg_path, format='PNG')

        print(f"Generated {folder}: {size}x{size}")

    # Create mipmap-anydpi-v26 for Android 8.0+ adaptive icons
    anydpi_dir = os.path.join(res_dir, 'mipmap-anydpi-v26')
    os.makedirs(anydpi_dir, exist_ok=True)

    adaptive_xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@android:color/white"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
'''
    with open(os.path.join(anydpi_dir, 'ic_launcher.xml'), 'w') as f:
        f.write(adaptive_xml)
    with open(os.path.join(anydpi_dir, 'ic_launcher_round.xml'), 'w') as f:
        f.write(adaptive_xml)
    print("Generated mipmap-anydpi-v26 adaptive XMLs")

    # Web Icons
    web_sizes = {
        'favicon.png': 64,
        os.path.join('icons', 'Icon-192.png'): 192,
        os.path.join('icons', 'Icon-512.png'): 512,
        os.path.join('icons', 'Icon-maskable-192.png'): 192,
        os.path.join('icons', 'Icon-maskable-512.png'): 512,
    }
    for rel_path, size in web_sizes.items():
        out_path = os.path.join(web_dir, rel_path)
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        web_icon = master_img.resize((size, size), Image.Resampling.LANCZOS)
        web_icon.save(out_path, format='PNG')
        print(f"Generated web icon: {rel_path} ({size}x{size})")

    print("All app icons successfully generated!")

if __name__ == '__main__':
    generate_icons()
