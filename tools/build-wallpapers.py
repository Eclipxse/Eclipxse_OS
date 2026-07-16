#!/usr/bin/env python3
"""Build MARISHOKU wallpaper packages from licensed source photographs.

The untouched inputs stay outside the repository. Only heavily transformed,
credited compositions are shipped. This script is deterministic and uses no
generative image model.
"""

from __future__ import annotations

import argparse
import math
import random
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageEnhance, ImageFilter, ImageFont, ImageOps

Image.MAX_IMAGE_PIXELS = None


SIZE = (1920, 1080)
NAVY = (3, 8, 69)
BLUE = (9, 26, 158)
CYAN = (39, 220, 236)
PINK = (255, 44, 157)
MAGENTA = (162, 12, 112)
PANEL = (194, 194, 202)


def cover(image: Image.Image, size: tuple[int, int], focus_x: float = 0.5, focus_y: float = 0.5) -> Image.Image:
    """Resize and crop an image to fill size around a normalized focal point."""
    image = image.convert("RGB")
    scale = max(size[0] / image.width, size[1] / image.height)
    resized = image.resize((round(image.width * scale), round(image.height * scale)), Image.Resampling.LANCZOS)
    left = round((resized.width - size[0]) * focus_x)
    top = round((resized.height - size[1]) * focus_y)
    left = max(0, min(left, resized.width - size[0]))
    top = max(0, min(top, resized.height - size[1]))
    return resized.crop((left, top, left + size[0], top + size[1]))


def grade_london(image: Image.Image) -> Image.Image:
    base = cover(image, SIZE, focus_x=0.55, focus_y=0.42)
    mono = ImageOps.grayscale(base)
    blue = ImageOps.colorize(mono, black=(0, 3, 28), white=(20, 71, 214))
    original = ImageEnhance.Color(base).enhance(0.35)
    graded = Image.blend(original, blue, 0.80)
    return ImageEnhance.Contrast(graded).enhance(1.35)


def portrait_layer(image: Image.Image, variant: int) -> tuple[Image.Image, Image.Image]:
    width = 910 if variant == 1 else 830
    focus_x = 0.50 if variant == 1 else 0.58
    focus_y = 0.39 if variant == 1 else 0.55
    portrait = cover(image, (width, 1080), focus_x=focus_x, focus_y=focus_y)
    portrait = ImageEnhance.Contrast(portrait).enhance(1.18)
    portrait = ImageEnhance.Color(portrait).enhance(1.22)

    blue = Image.new("RGB", portrait.size, (5, 24, 178))
    pink = Image.new("RGB", portrait.size, (200, 12, 121))
    tint = Image.blend(blue, pink, 0.38)
    portrait = Image.blend(portrait, tint, 0.18)

    mask = Image.new("L", portrait.size, 0)
    draw = ImageDraw.Draw(mask)
    for x in range(width):
        edge = min(1.0, max(0.0, (x - 25) / 260))
        right_fade = min(1.0, max(0.0, (width - x) / 34))
        alpha = round(235 * edge * right_fade)
        draw.line((x, 0, x, 1079), fill=alpha)
    mask = mask.filter(ImageFilter.GaussianBlur(18))
    return portrait, mask


def wave_layer(image: Image.Image) -> tuple[Image.Image, Image.Image]:
    wave = cover(image, (1180, 660), focus_x=0.37, focus_y=0.56)
    mono = ImageOps.grayscale(wave)
    colored = ImageOps.colorize(mono, black=(0, 4, 45), white=(107, 169, 255))
    colored = ImageEnhance.Contrast(colored).enhance(1.55)
    paper = ImageOps.autocontrast(mono)
    ink_mask = ImageOps.invert(paper).point(lambda value: min(220, round(value * 1.55)))
    foam_mask = paper.point(lambda value: max(0, round((value - 160) * 0.75)))
    alpha = ImageChops.lighter(ink_mask, foam_mask)

    # Dissolve the rectangular crop into the scene while retaining the inked crest.
    edge = Image.new("L", alpha.size, 255)
    edge_draw = ImageDraw.Draw(edge)
    for y in range(170):
        edge_draw.line((0, y, edge.width - 1, y), fill=round(255 * y / 170))
    for x in range(edge.width - 180, edge.width):
        edge_draw.line((x, 0, x, edge.height - 1), fill=round(255 * (edge.width - 1 - x) / 179))
    alpha = ImageChops.multiply(alpha, edge).filter(ImageFilter.GaussianBlur(1.2))
    return colored, alpha


def draw_bus(draw: ImageDraw.ImageDraw) -> None:
    x, y = 112, 628
    draw.rectangle((x, y, x + 270, y + 315), fill=(118, 5, 31), outline=PINK, width=5)
    draw.rounded_rectangle((x + 15, y - 25, x + 255, y + 45), radius=28, fill=(139, 5, 33), outline=PINK, width=5)
    for row_y in (y + 38, y + 135):
        for col in range(3):
            wx = x + 20 + col * 79
            draw.rectangle((wx, row_y, wx + 65, row_y + 68), fill=(4, 14, 83), outline=CYAN, width=3)
    draw.rectangle((x + 22, y + 218, x + 246, y + 257), fill=(8, 10, 35), outline=PANEL, width=2)
    font = load_font(20)
    draw.text((x + 42, y + 225), "M1  NIGHT LINE", font=font, fill=(244, 240, 255))
    draw.ellipse((x + 25, y + 275, x + 75, y + 325), fill=(12, 10, 28), outline=PINK, width=5)
    draw.ellipse((x + 195, y + 275, x + 245, y + 325), fill=(12, 10, 28), outline=PINK, width=5)


def draw_roundel(draw: ImageDraw.ImageDraw) -> None:
    cx, cy = 1630, 760
    draw.ellipse((cx - 120, cy - 120, cx + 120, cy + 120), outline=(214, 30, 63), width=38)
    draw.rectangle((cx - 142, cy - 32, cx + 142, cy + 32), fill=(3, 9, 82), outline=PANEL, width=4)
    font = load_font(25)
    draw.text((cx - 89, cy - 17), "NIGHT LINE", font=font, fill=(244, 240, 255))


def draw_cherry_branch(draw: ImageDraw.ImageDraw, seed: int) -> None:
    rng = random.Random(seed)
    points = [(1910, 410), (1725, 570), (1570, 665), (1450, 820), (1340, 1040)]
    draw.line(points, fill=(48, 5, 43), width=24, joint="curve")
    for _ in range(32):
        x = rng.randint(1430, 1900)
        baseline = 1190 - round((x - 1340) * 0.74)
        y = baseline + rng.randint(-90, 90)
        radius = rng.randint(12, 24)
        for angle in range(0, 360, 72):
            ox = round(radius * 0.75 * math.cos(math.radians(angle)))
            oy = round(radius * 0.75 * math.sin(math.radians(angle)))
            draw.ellipse((x + ox - radius // 2, y + oy - radius // 2,
                          x + ox + radius // 2, y + oy + radius // 2),
                         fill=(243, 52 + rng.randint(0, 45), 170), outline=(83, 9, 75))
        draw.ellipse((x - 4, y - 4, x + 4, y + 4), fill=(255, 210, 86))


def load_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for name in ("DejaVuSansMono-Bold.ttf", "LiberationMono-Bold.ttf", "consolab.ttf"):
        try:
            return ImageFont.truetype(name, size=size)
        except OSError:
            pass
    return ImageFont.load_default()


def add_rain_and_crt(image: Image.Image, seed: int) -> Image.Image:
    rng = random.Random(seed)
    fx = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(fx)
    for _ in range(390):
        x = rng.randrange(0, 1980)
        y = rng.randrange(-80, 1080)
        length = rng.randrange(18, 72)
        draw.line((x, y, x - 11, y + length), fill=(132, 191, 255, rng.randrange(35, 100)), width=rng.choice((1, 1, 2)))
    for y in range(0, 1080, 3):
        draw.line((0, y, 1919, y), fill=(0, 0, 15, 28), width=1)
    for _ in range(7800):
        x, y = rng.randrange(1920), rng.randrange(1080)
        value = rng.choice((12, 18, 235))
        draw.point((x, y), fill=(value, value, value, rng.randrange(4, 16)))
    return Image.alpha_composite(image.convert("RGBA"), fx).convert("RGB")


def add_label(image: Image.Image, variant: int) -> None:
    draw = ImageDraw.Draw(image)
    font_small = load_font(20)
    font_large = load_font(38)
    draw.rectangle((52, 43, 660, 145), fill=(1, 5, 39), outline=PANEL, width=4)
    draw.rectangle((60, 51, 652, 137), outline=CYAN, width=2)
    draw.text((84, 64), "MARISHOKU // MR-10", font=font_large, fill=(246, 241, 255))
    subtitle = "ECLIPXSE AFTER DARK" if variant == 1 else "NEON VELVET // 裏"
    draw.text((86, 111), subtitle, font=font_small, fill=PINK)


def build(source_dir: Path, output: Path, portrait_name: str, variant: int) -> None:
    london = Image.open(source_dir / "london-rain.jpg")
    portrait = Image.open(source_dir / portrait_name)
    wave = Image.open(source_dir / "great-wave.jpg")

    canvas = grade_london(london).convert("RGBA")
    portrait_img, portrait_mask = portrait_layer(portrait, variant)
    canvas.paste(portrait_img, (1010 if variant == 1 else 1080, 0), portrait_mask)

    wave_img, wave_mask = wave_layer(wave)
    canvas.paste(wave_img, (-75, 500), wave_mask)

    linework = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(linework)
    draw_bus(draw)
    draw_roundel(draw)
    draw_cherry_branch(draw, 1000 + variant)
    canvas = Image.alpha_composite(canvas, linework)

    composed = add_rain_and_crt(canvas, 8100 + variant)
    add_label(composed, variant)

    # A controlled 96-color palette and nearest-neighbour grid provide the CRT/pixel finish.
    reduced = composed.resize((960, 540), Image.Resampling.LANCZOS)
    reduced = reduced.quantize(colors=96, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.FLOYDSTEINBERG).convert("RGB")
    final = reduced.resize(SIZE, Image.Resampling.NEAREST)
    output.parent.mkdir(parents=True, exist_ok=True)
    final.save(output, format="PNG", optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-dir", type=Path, required=True)
    parser.add_argument("--output-root", type=Path, default=Path("artwork/wallpapers"))
    args = parser.parse_args()

    build(args.source_dir, args.output_root / "MARISHOKU-NightLine/contents/images/1920x1080.png", "woman-neon-01.jpg", 1)
    build(args.source_dir, args.output_root / "MARISHOKU-NeonVelvet/contents/images/1920x1080.png", "woman-neon-02.jpg", 2)


if __name__ == "__main__":
    main()
