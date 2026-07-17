#!/usr/bin/env python3
"""Build the Phase 1D wallpaper from the approved desktop concept.

No generative model is used. The clean right-hand character/city crop comes
from the project-owned concept; the obscured left side is rebuilt from the
same credited rainy-London source used by the Phase 1C wallpaper set.
"""

from __future__ import annotations

import argparse
import random
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageOps

Image.MAX_IMAGE_PIXELS = None

SIZE = (1920, 1080)


def cover(image: Image.Image, size: tuple[int, int], focus_x: float, focus_y: float) -> Image.Image:
    image = image.convert("RGB")
    scale = max(size[0] / image.width, size[1] / image.height)
    resized = image.resize((round(image.width * scale), round(image.height * scale)), Image.Resampling.LANCZOS)
    left = max(0, min(round((resized.width - size[0]) * focus_x), resized.width - size[0]))
    top = max(0, min(round((resized.height - size[1]) * focus_y), resized.height - size[1]))
    return resized.crop((left, top, left + size[0], top + size[1]))


def city_base(london: Image.Image) -> Image.Image:
    base = cover(london, SIZE, focus_x=0.58, focus_y=0.42)
    mono = ImageOps.grayscale(base)
    violet = ImageOps.colorize(mono, black=(5, 2, 28), white=(74, 37, 132))
    blue = ImageOps.colorize(mono, black=(0, 4, 28), white=(16, 111, 177))
    base = Image.blend(violet, blue, 0.24)
    base = ImageEnhance.Contrast(base).enhance(1.42)

    glow = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow)
    for x, y, radius, color in (
        (510, 420, 220, (220, 22, 155, 70)),
        (830, 720, 260, (24, 214, 231, 46)),
        (220, 780, 170, (225, 24, 137, 55)),
    ):
        draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill=color)
    glow = glow.filter(ImageFilter.GaussianBlur(90))
    return Image.alpha_composite(base.convert("RGBA"), glow)


def concept_layer(concept: Image.Image) -> tuple[Image.Image, Image.Image]:
    # Start immediately after the concept's baked SYSTEM READY dialog and end
    # before its taskbar. This keeps the approved character/signage untouched
    # while ensuring no fake windows survive in the real desktop wallpaper.
    source = concept.convert("RGB").crop((1049, 0, 1672, 870))
    scale = 1080 / source.height
    layer = source.resize((round(source.width * scale), 1080), Image.Resampling.LANCZOS)

    mask = Image.new("L", layer.size, 255)
    draw = ImageDraw.Draw(mask)
    for x in range(110):
        draw.line((x, 0, x, layer.height), fill=round(255 * x / 109))
    return layer, mask


def finish(image: Image.Image) -> Image.Image:
    rng = random.Random(10401)
    effects = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    draw = ImageDraw.Draw(effects)
    for _ in range(430):
        x = rng.randrange(0, 1970)
        y = rng.randrange(-100, 1080)
        length = rng.randrange(18, 82)
        draw.line((x, y, x - 10, y + length), fill=(145, 184, 255, rng.randrange(24, 80)), width=1)
    for y in range(0, 1080, 3):
        draw.line((0, y, 1919, y), fill=(0, 0, 12, 34), width=1)
    image = Image.alpha_composite(image.convert("RGBA"), effects).convert("RGB")

    reduced = image.resize((960, 540), Image.Resampling.LANCZOS)
    reduced = reduced.quantize(
        colors=128,
        method=Image.Quantize.MEDIANCUT,
        dither=Image.Dither.FLOYDSTEINBERG,
    ).convert("RGB")
    return reduced.resize(SIZE, Image.Resampling.NEAREST)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--concept", type=Path, default=Path("artwork/concepts/desktop-v0.1.png"))
    parser.add_argument("--source-dir", type=Path, required=True)
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("artwork/wallpapers/MARISHOKU-URA/contents/images/1920x1080.png"),
    )
    args = parser.parse_args()

    canvas = city_base(Image.open(args.source_dir / "london-rain.jpg"))
    character, character_mask = concept_layer(Image.open(args.concept))
    canvas.paste(character, (SIZE[0] - character.width, 0), character_mask)
    final = finish(canvas)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    final.save(args.output, format="PNG", optimize=True)


if __name__ == "__main__":
    main()
