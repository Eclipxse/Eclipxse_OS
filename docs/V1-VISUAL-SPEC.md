# MARISHOKU/OS V1 visual specification

MARISHOKU/OS is a Japanese Y2K computer interface rebuilt as a coherent
desktop, not a wallpaper collage. Its grammar is Windows 9x pixel chrome,
handheld messaging UI, cyber-kawaii color, soft goth contrast, and deliberate
CRT/LCD imperfection.

## Non-negotiable rules

- Author at 960x540 and scale exactly 2x for the 1920x1080 target.
- Use hard pixel edges. Never use fractional placement, blur, glass, or rounded
  cards in the core shell.
- Window corners are square. Frames use a two-stage bevel: one light edge and
  one dark edge around a flat panel face.
- The active titlebar is 26 px at final size. It is magenta in URA and violet
  in OMOTE. Inactive titlebars are muted mauve-grey.
- Body text is Noto Sans 10. System labels, titlebars, clocks, boot text, and
  terminal text use Noto Sans Mono. Japanese falls back to Noto Sans CJK JP.
- Hearts, stars, blossoms, moons, and wings are punctuation. They must never
  reduce legibility or cover application content.
- Scanlines, dithering, glow, and broken-LCD marks belong to wallpaper, boot,
  lock, recovery, and media surfaces. Application content stays crisp.
- Fake application windows are never baked into the desktop wallpaper.
- Text must be intentional and proofread. No AI gibberish or fake Japanese.

## Profiles

### OMOTE / 表

The public-facing profile. Pearl panels, cherry pink, lavender, pale cyan,
small blossoms, and restrained rainbow pixels. It references the pastel CRT,
angel-window, and handheld-message images without copying their artwork.

### URA / 裏

The after-dark profile. Graphite, bruised purple, hot pink, cyan signal pixels,
broken-LCD diagonals, and an original heart-eye motif. It references the hot
pink phone, cracked display, and manga-eye images without copying them.

Both profiles share geometry, icon silhouettes, and interaction states. A
profile changes palette, wallpaper, terminal colors, boot copy, and optional
content level; it does not become a different operating system.

## Surface map

| Reference trait | MARISHOKU surface |
| --- | --- |
| Layered 9x dialog boxes | notifications, welcome, recovery, progress |
| Soft CRT BIOS copy | faux BIOS and Plymouth hand-off |
| Pastel disk-cleanup window | safe Storage Care utility |
| Hot-pink phone display | URA lock screen and quick-message card |
| Handheld star-message UI | tips, notifications, Japanese input hint |
| Pink manga eyes | original heart-eye lock/login emblem |
| Cat sleeping under a hand | original sleep sprite |
| Broken LCD | recovery mode and URA diagnostics |
| Cute opposing creatures | original Momo/Kuro heart-spirit mascots |

## Canonical palette

| Token | URA | OMOTE |
| --- | --- | --- |
| desktop | `#130D1A` | `#E8DFF0` |
| panel | `#D8CDD9` | `#F3EAF4` |
| panel highlight | `#FFF3FF` | `#FFF9FF` |
| panel shadow | `#56445E` | `#806E86` |
| active title | `#C82E91` | `#7141C1` |
| active title text | `#FFF3FF` | `#FFFFFF` |
| accent pink | `#FF4CA7` | `#EC65AB` |
| signal cyan | `#62DDE4` | `#56C8D8` |
| error | `#FF4C91` | `#C72F70` |

## Boot boundary

MARISHOKU does not flash or replace motherboard firmware. The firmware-safe
experience is GRUB followed by Plymouth, both styled as a faux BIOS. It starts
after the vendor firmware and remains removable through the Debian package.

## Asset policy

The supplied images are visual references. Recognizable characters and images
without redistribution permission are not shipped in the public repository or
ISO. V1 uses deterministic code-native artwork and original Momo/Kuro sprites.
Privately owned artwork can be installed later through a local-only asset pack.
