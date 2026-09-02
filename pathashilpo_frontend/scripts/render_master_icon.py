import os
import subprocess
from PIL import Image, ImageDraw

def render():
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    svg_file = os.path.join(base_dir, 'assets', 'patha-shilpo_logo.svg')
    html_file = os.path.join(base_dir, 'scripts', 'temp_icon.html')
    master_png = os.path.join(base_dir, 'assets', 'master_icon.png')

    html_code = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  html, body {{
    margin: 0;
    padding: 0;
    width: 1024px;
    height: 1024px;
    overflow: hidden;
    background: transparent;
  }}
  img {{
    width: 1024px;
    height: 1024px;
    object-fit: cover;
    display: block;
  }}
</style>
</head>
<body>
  <img src="{svg_file.replace('\\', '/')}" />
</body>
</html>"""

    with open(html_file, 'w', encoding='utf-8') as f:
        f.write(html_code)

    chrome = r'C:\Program Files\Google\Chrome\Application\chrome.exe'
    html_url = 'file:///' + html_file.replace('\\', '/')
    cmd = [
        chrome,
        '--headless=new',
        '--default-background-color=00000000',
        f'--screenshot={master_png}',
        '--window-size=1024,1024',
        html_url
    ]
    subprocess.run(cmd, check=True)
    print(f"Master PNG rendered: {master_png}")

    img = Image.open(master_png).convert("RGBA")

    res_dir = os.path.join(base_dir, 'android', 'app', 'src', 'main', 'res')
    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }

    # 1. Add colors.xml
    values_dir = os.path.join(res_dir, 'values')
    os.makedirs(values_dir, exist_ok=True)
    colors_xml = """<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#1D3432</color>
</resources>
"""
    with open(os.path.join(values_dir, 'colors.xml'), 'w', encoding='utf-8') as f:
        f.write(colors_xml)

    def make_round(im, size):
        mask = Image.new('L', (size * 4, size * 4), 0)
        d = ImageDraw.Draw(mask)
        d.ellipse((0, 0, size * 4 - 1, size * 4 - 1), fill=255)
        mask = mask.resize((size, size), Image.Resampling.LANCZOS)

        resized = im.resize((size, size), Image.Resampling.LANCZOS)
        res = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        res.paste(resized, (0, 0), mask=mask)
        return res

    for folder, size in android_sizes.items():
        folder_path = os.path.join(res_dir, folder)
        os.makedirs(folder_path, exist_ok=True)

        # Standard launcher icon (legacy)
        std = img.resize((size, size), Image.Resampling.LANCZOS)
        std.save(os.path.join(folder_path, 'ic_launcher.png'), 'PNG')

        # Circular launcher icon (round legacy)
        rnd = make_round(img, size)
        rnd.save(os.path.join(folder_path, 'ic_launcher_round.png'), 'PNG')

        # Foreground for adaptive icon (Android 8.0+)
        # Safe zone in Android adaptive icons is 66% - 72% of the icon canvas
        fg_scale = 0.72
        motif_sz = int(size * fg_scale)
        motif = img.resize((motif_sz, motif_sz), Image.Resampling.LANCZOS)
        
        fg = Image.new('RGBA', (size, size), (0, 0, 0, 0))
        offset = (size - motif_sz) // 2
        fg.paste(motif, (offset, offset))
        fg.save(os.path.join(folder_path, 'ic_launcher_foreground.png'), 'PNG')

        print(f"Generated {folder}: {size}x{size}")

    # 2. Adaptive icon XMLs
    anydpi_dir = os.path.join(res_dir, 'mipmap-anydpi-v26')
    os.makedirs(anydpi_dir, exist_ok=True)
    adaptive_xml = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
"""
    with open(os.path.join(anydpi_dir, 'ic_launcher.xml'), 'w', encoding='utf-8') as f:
        f.write(adaptive_xml)
    with open(os.path.join(anydpi_dir, 'ic_launcher_round.xml'), 'w', encoding='utf-8') as f:
        f.write(adaptive_xml)

    # 3. Web icons
    web_dir = os.path.join(base_dir, 'web')
    web_sizes = {
        'favicon.png': 64,
        os.path.join('icons', 'Icon-192.png'): 192,
        os.path.join('icons', 'Icon-512.png'): 512,
        os.path.join('icons', 'Icon-maskable-192.png'): 192,
        os.path.join('icons', 'Icon-maskable-512.png'): 512,
    }
    for rel_path, sz in web_sizes.items():
        w_path = os.path.join(web_dir, rel_path)
        os.makedirs(os.path.dirname(w_path), exist_ok=True)
        w_icon = img.resize((sz, sz), Image.Resampling.LANCZOS)
        w_icon.save(w_path, 'PNG')

    print("Success: All icons generated properly with brand colors!")

if __name__ == '__main__':
    render()
