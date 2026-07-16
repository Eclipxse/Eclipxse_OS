# MARISHOKU/OS visual system v0.1

## Brand construction

The public mark is `魔理蝕` and the Roman lockup is `MARISHOKU/OS`.

- `魔` supplies the occult/gothic reading and the sound *ma*.
- `理` supplies system logic and the sound *ri*.
- `蝕` supplies eclipse, erosion, and being consumed.
- The `O` in `/OS` completes the hidden `MA-RI-O` construction.
- `MR-10` is the secondary machine code and another hidden Mario reference.

The construction is intentionally stylized branding, not claimed to be a
standard Japanese dictionary word.

## Visual thesis

MARISHOKU/OS should feel like forbidden Japanese communication software found
on a machine in a rainy city at 02:13. It is functional software first: CRT,
halftone, and distressed textures belong in wallpaper and transitional media,
not over long passages of text.

### Primary palette

| Token | Hex | Use |
|---|---:|---|
| `ink-950` | `#15101F` | Desktop darkness, outlines |
| `night-900` | `#24162B` | Dark surfaces |
| `panel-200` | `#D8CDD9` | Window and control faces |
| `panel-050` | `#FFF3FF` | Bevel highlights, active text |
| `panel-600` | `#56445E` | Bevel shadows, inactive chrome |
| `pink-500` | `#D63BAC` | Hot bevels, hover, attention |
| `magenta-700` | `#8F276F` | Title bars, selection, pressed states |
| `violet-500` | `#7241B8` | Secondary state and depth |
| `cyan-400` | `#62DDE4` | Connected, focus, informational state |
| `error-400` | `#FF4C91` | Destructive and URA emphasis |

### Geometry

- Zero-radius windows and controls.
- One-pixel ink outline around interactive objects.
- Two-stage bevel: light on top/left, shadow on bottom/right.
- Title bars are 26 px at 100% scale and must pixel-snap.
- Default desktop panel is 36 px at 100% scale.
- Icons are authored on 16, 24, 32, and 48 px grids.
- Blur, glass, floating cards, and soft shadows are disabled by default.

### Contrast floor

- Normal-size interface text must meet WCAG AA `4.5:1` contrast.
- White title-bar and selection text sits on `magenta-700` (`7.26:1`).
- `pink-500` remains a non-text accent unless paired with a compliant ink color
  at an approved size.

### Typography

- Pixel/Japanese display font for title bars, launchers, status labels, and OSD.
- Noto Sans and Noto Sans CJK fallback for documents and long UI strings.
- Pixel fonts render only at tested integer sizes.
- Readable Mode replaces display typography in long or accessibility-sensitive
  surfaces while preserving color and geometry.

### Motion

- Button response: immediate.
- Popup open/close: 80–120 ms.
- Window transition ceiling: 140 ms.
- No elastic motion, background blur, or slow fades.
- Boot animation may use scanline and phosphor effects.

## Interface personality

System copy is short, confrontational, and machine-like. It must never obscure
the real consequence of a destructive action.

Examples:

- `SYSTEM READY.`
- `CONNECTION LOST.`
- `NO LUCK REQUIRED.`
- `WORK.`
- `URA MODE ACTIVE.`

Confirmation dialogs still use explicit verbs such as **Delete**, **Restart**,
and **Erase Disk** rather than joke labels.

## Originality rule

Reference images guide palette, texture, and emotional direction only. Shipped
art must not contain Nintendo graphics, recognizable copyrighted characters,
album artwork, third-party photography, or copied interface assets.
