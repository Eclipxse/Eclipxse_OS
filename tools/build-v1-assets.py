#!/usr/bin/env python3
"""Build MARISHOKU/OS V1 raster assets.

Boot controls, cursors, sound, OMOTE, and recovery fallbacks are deterministic.
The canonical URA release path preserves the curated project-owned master art
instead of attempting to redraw detailed character art with Pillow primitives.
"""

from __future__ import annotations

import math
import random
import shutil
import struct
import wave
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
URA_MASTER = ROOT / "artwork/source/ura-v1-master.png"
LOW = (960, 540)
FINAL = (1920, 1080)
INK = "#130D1A"
GRAPHITE = "#211828"
PANEL = "#D8CDD9"
PANEL_HI = "#FFF3FF"
PANEL_SHADOW = "#56445E"
MAGENTA = "#C82E91"
PINK = "#FF4CA7"
VIOLET = "#7141C1"
CYAN = "#62DDE4"
WHITE = "#FFF3FF"


def font(size: int, bold: bool = False) -> ImageFont.ImageFont:
    names = (
        "DejaVuSansMono-Bold.ttf" if bold else "DejaVuSansMono.ttf",
        "LiberationMono-Bold.ttf" if bold else "LiberationMono-Regular.ttf",
        "consolab.ttf" if not bold else "consola.ttf",
    )
    for name in names:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            pass
    return ImageFont.load_default()


def save_2x(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.resize(FINAL, Image.Resampling.NEAREST).save(path, optimize=True)


def pixel_star(draw: ImageDraw.ImageDraw, x: int, y: int, color: str, radius: int = 5) -> None:
    draw.rectangle((x - 1, y - radius, x + 1, y + radius), fill=color)
    draw.rectangle((x - radius, y - 1, x + radius, y + 1), fill=color)
    draw.point((x - 2, y - 2), fill=color)
    draw.point((x + 2, y + 2), fill=color)


def heart(draw: ImageDraw.ImageDraw, x: int, y: int, scale: int, fill: str, outline: str) -> None:
    cells = (
        "01100110",
        "11111111",
        "11111111",
        "01111110",
        "00111100",
        "00011000",
    )
    for row, bits in enumerate(cells):
        for col, bit in enumerate(bits):
            if bit == "1":
                box = (x + col * scale, y + row * scale,
                       x + (col + 1) * scale - 1, y + (row + 1) * scale - 1)
                draw.rectangle(box, fill=fill)
    draw.line((x + scale, y, x, y + scale, x, y + 3 * scale), fill=outline, width=1)


def bevel(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], face: str = PANEL) -> None:
    x0, y0, x1, y1 = box
    draw.rectangle(box, fill=face, outline=INK)
    draw.line((x0 + 1, y0 + 1, x1 - 1, y0 + 1), fill=PANEL_HI)
    draw.line((x0 + 1, y0 + 1, x0 + 1, y1 - 1), fill=PANEL_HI)
    draw.line((x0 + 2, y1 - 1, x1 - 1, y1 - 1), fill=PANEL_SHADOW)
    draw.line((x1 - 1, y0 + 2, x1 - 1, y1 - 1), fill=PANEL_SHADOW)


def window(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], title: str,
           active: str = MAGENTA) -> tuple[int, int, int, int]:
    bevel(draw, box)
    x0, y0, x1, y1 = box
    draw.rectangle((x0 + 3, y0 + 3, x1 - 3, y0 + 17), fill=active)
    draw.text((x0 + 8, y0 + 4), title, font=font(9, True), fill=WHITE)
    for i, glyph in enumerate(("_", "□", "×")):
        bx = x1 - 50 + i * 15
        bevel(draw, (bx, y0 + 4, bx + 13, y0 + 16))
        draw.text((bx + 3, y0 + 3), glyph, font=font(8, True), fill=INK)
    return (x0 + 4, y0 + 20, x1 - 4, y1 - 4)


def grid(draw: ImageDraw.ImageDraw, color: str, step: int = 32) -> None:
    for x in range(0, LOW[0], step):
        draw.line((x, 0, x, LOW[1]), fill=color)
    for y in range(0, LOW[1], step):
        draw.line((0, y, LOW[0], y), fill=color)


def scanlines(draw: ImageDraw.ImageDraw, color: str = "#07040C") -> None:
    for y in range(0, LOW[1], 2):
        draw.line((0, y, LOW[0], y), fill=color)


def yoru_portrait(draw: ImageDraw.ImageDraw) -> None:
    """Draw Yoru, an original soft-goth pixel portrait."""
    # Shoulder silhouette and high collar.
    draw.polygon(((76, 540), (110, 420), (168, 382), (250, 380), (328, 430), (365, 540)),
                 fill="#24122E", outline="#6D2D7C")
    draw.polygon(((164, 406), (205, 466), (246, 405), (266, 522), (140, 522)),
                 fill="#100815", outline=PINK)
    draw.rectangle((184, 340, 228, 410), fill="#B87FAE", outline="#2A142F")

    # Face and asymmetric bob, deliberately blocky at the 2x grid.
    draw.ellipse((78, 58, 332, 418), fill="#24122E", outline="#6D2D7C", width=4)
    draw.ellipse((104, 112, 310, 386), fill="#C991BE", outline="#2A142F", width=4)
    draw.polygon(((98, 176), (110, 102), (168, 74), (257, 82), (306, 126),
                  (302, 184), (267, 151), (252, 215), (220, 136), (195, 208),
                  (161, 139), (128, 222)), fill="#24122E")
    draw.rectangle((91, 191, 123, 350), fill="#2E1739")
    draw.rectangle((286, 181, 321, 344), fill="#2E1739")

    # Split-color eyes and small beauty mark; no source portrait is sampled.
    draw.polygon(((137, 244), (173, 229), (202, 246), (173, 259)), fill="#FFF3FF", outline="#2A142F")
    draw.polygon(((220, 246), (252, 231), (278, 246), (251, 260)), fill="#FFF3FF", outline="#2A142F")
    draw.rectangle((166, 236, 179, 253), fill=PINK)
    draw.rectangle((245, 237, 258, 254), fill=CYAN)
    draw.rectangle((171, 240, 175, 248), fill="#130D1A")
    draw.rectangle((250, 241, 254, 249), fill="#130D1A")
    draw.line((185, 310, 211, 317, 238, 307), fill="#713257", width=3)
    draw.rectangle((271, 285, 275, 289), fill="#56233F")

    # Cross earring and choker are original graphic accents.
    draw.line((304, 286, 304, 344), fill=CYAN, width=4)
    draw.line((291, 316, 317, 316), fill=CYAN, width=4)
    draw.rectangle((166, 385, 245, 400), fill="#130D1A", outline=PINK)


def omote(with_message: bool = False) -> Image.Image:
    im = Image.new("RGB", LOW, "#E8DFF0")
    d = ImageDraw.Draw(im)
    grid(d, "#CBBBD4", 30)
    rng = random.Random(1001)
    for _ in range(70):
        x, y = rng.randrange(10, 950), rng.randrange(10, 530)
        pixel_star(d, x, y, rng.choice(("#FFFFFF", "#EC65AB", "#56C8D8", "#8C63C8")), rng.choice((2, 3, 4)))
    # Original paired heart spirits: Momo (light) and Kuro (dark).
    d.ellipse((710, 315, 800, 405), fill="#F4A5CE", outline="#49314F", width=3)
    d.polygon(((720, 330), (730, 292), (749, 327)), fill="#F4A5CE", outline="#49314F")
    d.ellipse((800, 315, 890, 405), fill="#5A3C70", outline="#281A32", width=3)
    d.polygon(((810, 329), (830, 291), (844, 331)), fill="#5A3C70", outline="#281A32")
    d.arc((738, 340, 765, 368), 10, 160, fill="#49314F", width=3)
    d.arc((826, 340, 853, 368), 20, 170, fill="#FDEAF7", width=3)
    heart(d, 773, 296, 4, "#EC3F9B", "#49314F")
    # Blossom branch.
    d.line((120, 515, 320, 355, 475, 300), fill="#563A60", width=7)
    for x, y in ((170, 470), (225, 420), (285, 375), (350, 345), (430, 312)):
        for angle in range(0, 360, 72):
            px = x + int(11 * math.cos(math.radians(angle)))
            py = y + int(11 * math.sin(math.radians(angle)))
            d.rectangle((px - 5, py - 5, px + 5, py + 5), fill="#F087BC", outline="#72446C")
        d.rectangle((x - 2, y - 2, x + 2, y + 2), fill="#FFF0A0")
    if with_message:
        window(d, (42, 38, 430, 150), "OMOTE // MESSAGE")
        d.text((64, 75), "YOU ARE STILL HERE.", font=font(18, True), fill="#3B2843")
        d.text((64, 104), "THAT COUNTS.  <3", font=font(14), fill="#7141C1")
    return im


def ura(with_message: bool = False) -> Image.Image:
    im = Image.new("RGB", LOW, INK)
    d = ImageDraw.Draw(im)
    grid(d, "#2B1933", 28)
    rng = random.Random(2002)
    for _ in range(85):
        x, y = rng.randrange(8, 952), rng.randrange(8, 532)
        pixel_star(d, x, y, rng.choice((PINK, CYAN, "#7141C1", "#FFF3FF")), rng.choice((2, 3, 5)))
    yoru_portrait(d)
    # Deliberate broken-LCD diagonals.
    for offset in (0, 7, 13):
        d.line((530 + offset, 0, 420 + offset, 160, 570 + offset, 285, 475 + offset, 540),
               fill="#4A1D50", width=2)
    d.line((532, 0, 422, 160, 572, 285, 477, 540), fill=PINK, width=1)
    # Original heart-eye emblem.
    d.ellipse((625, 128, 895, 360), outline="#6D2D7C", width=7)
    d.arc((650, 150, 870, 336), 195, 345, fill=PINK, width=8)
    d.arc((650, 150, 870, 336), 15, 165, fill=CYAN, width=8)
    heart(d, 734, 210, 7, PINK, "#1D0C24")
    d.line((618, 244, 565, 232, 530, 205), fill="#B62886", width=5)
    d.line((902, 244, 944, 220, 959, 187), fill="#4BCDD8", width=5)
    if with_message:
        window(d, (45, 52, 480, 188), "URA // NIGHT MESSAGE")
        d.text((70, 92), "SIGNAL: ALIVE", font=font(20, True), fill="#25172C")
        d.text((70, 127), "NO LUCK REQUIRED.", font=font(14), fill="#8F276F")
        d.text((70, 151), "SHIP THE BUILD.", font=font(14), fill="#8F276F")
    scanlines(d, "#0D0912")
    return im


def boot() -> Image.Image:
    im = Image.new("RGB", LOW, "#07040C")
    d = ImageDraw.Draw(im)
    grid(d, "#160A1C", 24)
    for x, y, c in ((80, 60, PINK), (850, 70, CYAN), (740, 460, VIOLET), (120, 480, WHITE)):
        pixel_star(d, x, y, c, 5)
    content = window(d, (128, 64, 832, 476), "MARISHOKU BIOS v1.0", VIOLET)
    x0, y0, x1, _ = content
    d.rectangle((x0, y0, x1, y0 + 38), fill="#24162B")
    d.text((x0 + 20, y0 + 10), "ECLIPXSE SYSTEMS // MR-10", font=font(16, True), fill=WHITE)
    lines = (
        ("MEMORY MATRIX", "OK"),
        ("GRAPHICS LINK", "OK"),
        ("HEARTBEAT BUS", "OK"),
        ("JAPANESE INPUT", "STANDBY"),
        ("PROFILE", "URA"),
        ("DREAM CACHE", "READY"),
    )
    for i, (key, value) in enumerate(lines):
        y = y0 + 75 + i * 38
        d.text((x0 + 28, y), key, font=font(16), fill="#2A1C30")
        d.line((x0 + 235, y + 12, x1 - 135, y + 12), fill="#806E86", width=1)
        d.text((x1 - 120, y), value, font=font(16, True), fill="#8F276F")
    heart(d, x0 + 30, y1 := y0 + 324, 5, PINK, "#2A1C30")
    d.text((x0 + 90, y1 + 4), "STARTING MARISHOKU/OS...", font=font(16, True), fill="#2A1C30")
    return im


def login() -> Image.Image:
    base = ura()
    d = ImageDraw.Draw(base)
    # Quiet the center so the live QML card remains readable.
    d.rectangle((245, 65, 715, 475), fill="#130D1A", outline="#6D2D7C", width=2)
    grid_area = "#201326"
    for x in range(260, 701, 28):
        d.line((x, 80, x, 460), fill=grid_area)
    for y in range(80, 461, 28):
        d.line((260, y, 700, y), fill=grid_area)
    heart(d, 438, 100, 10, PINK, "#09050D")
    d.text((372, 185), "MARISHOKU/OS", font=font(22, True), fill=WHITE)
    d.text((392, 220), "OMOTE // URA // MR-10", font=font(13), fill=CYAN)
    return base


def plymouth_assets(root: Path) -> None:
    root.mkdir(parents=True, exist_ok=True)
    track = Image.new("RGBA", (404, 18), (0, 0, 0, 0))
    d = ImageDraw.Draw(track)
    d.rectangle((0, 0, 403, 17), fill="#130D1A", outline="#FFF3FF", width=2)
    d.rectangle((3, 3, 400, 14), outline="#56445E", width=1)
    track.save(root / "progress-track.png")

    fill = Image.new("RGBA", (396, 10), (200, 46, 145, 255))
    d = ImageDraw.Draw(fill)
    for x in range(12, 396, 14):
        d.line((x, 0, x, 9), fill="#8F276F", width=2)
    fill.save(root / "progress-fill.png")

    mark = Image.new("RGBA", (64, 52), (0, 0, 0, 0))
    heart(ImageDraw.Draw(mark), 0, 0, 8, PINK, INK)
    mark.save(root / "heart.png")


def chime(path: Path, notes: tuple[tuple[float, float], ...]) -> None:
    rate = 44_100
    samples: list[int] = []
    for frequency, duration in notes:
        count = int(rate * duration)
        for index in range(count):
            time = index / rate
            attack = min(1.0, index / (rate * 0.015))
            release = min(1.0, (count - index) / (rate * 0.08))
            envelope = attack * release
            value = math.sin(2 * math.pi * frequency * time)
            value += 0.22 * math.sin(2 * math.pi * frequency * 2 * time)
            samples.append(int(7_200 * envelope * value))
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "wb") as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(rate)
        output.writeframes(b"".join(struct.pack("<h", sample) for sample in samples))


def sounds(root: Path) -> None:
    stereo = root / "stereo"
    chime(stereo / "desktop-login.wav", ((523.25, 0.11), (659.25, 0.11), (783.99, 0.25)))
    chime(stereo / "complete.wav", ((659.25, 0.10), (880.00, 0.20)))
    chime(stereo / "dialog-warning.wav", ((311.13, 0.12), (233.08, 0.24)))
    chime(stereo / "message-new-instant.wav", ((783.99, 0.08), (1046.50, 0.14)))


def grub_assets(root: Path) -> None:
    root.mkdir(parents=True, exist_ok=True)
    parts = {
        "c": (8, 34), "n": (8, 3), "s": (8, 3), "w": (3, 34), "e": (3, 34),
        "nw": (3, 3), "ne": (3, 3), "sw": (3, 3), "se": (3, 3),
    }
    for name, size in parts.items():
        image = Image.new("RGBA", size, (143, 39, 111, 235))
        draw = ImageDraw.Draw(image)
        if name != "c":
            draw.rectangle((0, 0, size[0] - 1, size[1] - 1), outline=(255, 243, 255, 255))
        image.save(root / f"select_{name}.png")


def installer_assets(root: Path) -> None:
    root.mkdir(parents=True, exist_ok=True)
    logo = Image.new("RGBA", (256, 256), (0, 0, 0, 0))
    heart(ImageDraw.Draw(logo), 32, 48, 24, PINK, INK)
    logo.save(root / "marishoku-logo.png")
    omote(with_message=True).resize((1280, 720), Image.Resampling.NEAREST).save(root / "welcome.png", optimize=True)


def live_boot_assets(root: Path) -> None:
    root.mkdir(parents=True, exist_ok=True)
    boot().resize((640, 480), Image.Resampling.NEAREST).save(root / "splash.png", optimize=True)


def cursor_assets(root: Path) -> None:
    root.mkdir(parents=True, exist_ok=True)

    pointer = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(pointer)
    polygon = ((2, 1), (2, 25), (8, 20), (12, 30), (17, 28), (12, 18), (22, 18))
    draw.polygon(polygon, fill="#201727")
    inner = ((4, 4), (4, 21), (8, 17), (13, 26), (14, 25), (10, 16), (18, 16))
    draw.polygon(inner, fill=PINK)
    pointer.save(root / "left_ptr.png")

    text_cursor = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(text_cursor)
    draw.rectangle((13, 3, 18, 28), fill="#201727")
    draw.rectangle((7, 2, 24, 6), fill="#201727")
    draw.rectangle((7, 26, 24, 30), fill="#201727")
    draw.rectangle((15, 5, 16, 27), fill=CYAN)
    text_cursor.save(root / "xterm.png")

    hand = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(hand)
    draw.rectangle((7, 2, 12, 20), fill="#201727")
    draw.rectangle((12, 9, 24, 24), fill="#201727")
    draw.rectangle((10, 5, 11, 20), fill=PINK)
    draw.rectangle((12, 11, 22, 22), fill=PINK)
    draw.rectangle((10, 22, 24, 27), fill="#201727")
    hand.save(root / "hand2.png")

    for name, offset in (("watch.png", 0), ("watch-2.png", 1)):
        wait = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
        draw = ImageDraw.Draw(wait)
        draw.rectangle((8, 5, 23, 27), fill="#201727")
        draw.rectangle((11, 8, 20, 24), fill="#D8CDD9")
        draw.polygon(((12 + offset, 9), (19, 9), (16, 15)), fill=PINK)
        draw.polygon(((12, 23), (20 - offset, 23), (16, 17)), fill=CYAN)
        wait.save(root / name)


def write_package(
    root: Path,
    name: str,
    image: Image.Image,
    title: str,
    license_id: str = "CC0-1.0",
) -> None:
    save_2x(image, root / name / "contents/images/1920x1080.png")
    metadata = root / name / "metadata.json"
    metadata.parent.mkdir(parents=True, exist_ok=True)
    metadata.write_text(
        '{\n  "KPlugin": {\n'
        f'    "Id": "{name}",\n    "Name": "{title}",\n'
        f'    "License": "{license_id}",\n    "Version": "1.0.0"\n  }}\n}}\n',
        encoding="utf-8",
    )


def install_ura_master(*targets: Path) -> bool:
    """Install the approved high-detail URA artwork without redrawing it.

    The primitive URA renderer remains a deterministic recovery fallback for
    source-only builds. Release builds ship the curated master and must never
    replace it with the old flat placeholder portrait.
    """
    if not URA_MASTER.is_file():
        return False
    for target in targets:
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(URA_MASTER, target)
    return True


def main() -> None:
    wallpaper_root = ROOT / "artwork/wallpapers"
    write_package(wallpaper_root, "MARISHOKU-OMOTE", omote(), "MARISHOKU OMOTE")
    write_package(
        wallpaper_root,
        "MARISHOKU-URA-V1",
        ura(),
        "MARISHOKU URA V1",
        "CC-BY-SA-4.0",
    )
    install_ura_master(
        wallpaper_root / "MARISHOKU-URA-V1/contents/images/1920x1080.png",
    )
    grub_root = ROOT / "themes/boot/grub"
    save_2x(boot(), grub_root / "background.png")
    grub_assets(grub_root)
    plymouth_root = ROOT / "themes/boot/plymouth/marishoku"
    save_2x(boot(), plymouth_root / "background.png")
    plymouth_assets(plymouth_root)
    login_background = ROOT / "themes/sddm/MARISHOKU/background.png"
    splash_background = ROOT / "themes/global/org.marishoku.os/contents/splash/images/background.png"
    if not install_ura_master(login_background, splash_background):
        save_2x(login(), login_background)
        save_2x(login(), splash_background)
    sounds(ROOT / "artwork/sounds/MARISHOKU")
    installer_assets(ROOT / "packages/installer/branding/marishoku")
    install_ura_master(ROOT / "packages/installer/branding/marishoku/welcome.png")
    live_boot_assets(ROOT / "iso/artwork")
    cursor_assets(ROOT / "themes/cursors/MARISHOKU/src")


if __name__ == "__main__":
    main()
