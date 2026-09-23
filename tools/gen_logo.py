"""Generate all MUSE logo derivatives from the source lockup.

Source: 1254x1254 black + gold M lockup.
Outputs:
  assets/logo/logo.png            full lockup, 1024px, optimized (provenance)
  assets/logo/mark.png            cropped M mark on black, 512px (in-app)
  android mipmap-*/ic_launcher.png 48..192
  android drawable/launch_image.png 512 (splash bitmap)
  ios AppIcon files (overwrite Flutter defaults)
  ios LaunchImage.imageset (Launch screen bitmap, storyboard already refs it)
  web/favicon.png, icons/Icon-*.png, logo.png (loader)
"""
import os
from PIL import Image

ROOT = os.path.join(os.path.dirname(__file__), "..")
SRC = r"C:\Users\gabri\Downloads\ChatGPT Image 23 set 2026, 17_42_11.png"

src = Image.open(SRC).convert("RGB")
W, H = src.size
assert W == H, (W, H)

FULL = src.resize((1024, 1024), Image.LANCZOS)

# M mark crop: fractions tuned to the lockup (M + star, no wordmark).
box = (int(W * 0.285), int(H * 0.185), int(W * 0.715), int(H * 0.565))
mark = src.crop(box)
side = max(mark.size)
square = Image.new("RGB", (side, side), (7, 8, 13))
square.paste(mark, ((side - mark.width) // 2, (side - mark.height) // 2))
MARK = square.resize((256, 256), Image.LANCZOS)


def save(img, rel, size=None, **kw):
    p = os.path.join(ROOT, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    out = img.resize((size, size), Image.LANCZOS) if size else img
    out.save(p, optimize=True, **kw)
    print(f"{rel} {out.size} {os.path.getsize(p)//1024}KB")


save(FULL, "assets/logo/logo.png")
save(MARK, "assets/logo/mark.png")

# Android launcher (full-bleed black: system mask crops cleanly)
for d, s in (("mdpi", 48), ("hdpi", 72), ("xhdpi", 96),
             ("xxhdpi", 144), ("xxxhdpi", 192)):
    save(FULL, f"android/app/src/main/res/mipmap-{d}/ic_launcher.png", s)

# Android splash bitmap
save(FULL, "android/app/src/main/res/drawable/launch_image.png", 512)

# iOS AppIcon (overwrite Flutter defaults, same filenames)
ios = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
for f, s in (("Icon-App-20x20@2x.png", 40), ("Icon-App-20x20@3x.png", 60),
             ("Icon-App-29x29@1x.png", 29), ("Icon-App-29x29@2x.png", 58),
             ("Icon-App-29x29@3x.png", 87), ("Icon-App-40x40@2x.png", 80),
             ("Icon-App-40x40@3x.png", 120), ("Icon-App-60x60@2x.png", 120),
             ("Icon-App-60x60@3x.png", 180), ("Icon-App-20x20@1x.png", 20),
             ("Icon-App-29x29@1x.png", 29), ("Icon-App-40x40@1x.png", 40),
             ("Icon-App-76x76@1x.png", 76), ("Icon-App-76x76@2x.png", 152),
             ("Icon-App-83.5x83.5@2x.png", 167),
             ("Icon-App-1024x1024@1x.png", 1024)):
    save(FULL, f"{ios}/{f}", s)

# iOS launch image set (storyboard imageView, contentMode=center).
# Two scales only: @3x devices upscale @2x cleanly on a black glow.
li = "ios/Runner/Assets.xcassets/LaunchImage.imageset"
save(FULL, f"{li}/LaunchImage.png", 420)
save(FULL, f"{li}/LaunchImage@2x.png", 840)

# Web
save(MARK, "web/favicon.png", 64)
save(FULL, "web/icons/Icon-192.png", 192)
save(FULL, "web/icons/Icon-512.png", 512)
save(FULL, "web/icons/Icon-maskable-192.png", 192)
save(FULL, "web/icons/Icon-maskable-512.png", 512)
save(FULL, "web/logo.png", 512)
print("done")
