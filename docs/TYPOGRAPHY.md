# Typography

MARISHOKU/OS uses a restrained two-family system so the desktop reads like a
late-1990s Japanese messaging terminal without sacrificing daily usability.

| Role | Family | Size | Purpose |
| --- | --- | ---: | --- |
| Application body | Noto Sans | 10 pt | Dense, readable controls and documents |
| Window titles | Noto Sans Mono | 10 pt | Terminal-like chrome |
| Menus and toolbars | Noto Sans Mono | 9 pt | Compact system UI rhythm |
| Terminal and code | Noto Sans Mono | 10 pt | Stable character grid |
| Small labels | Noto Sans | 8 pt | Secondary metadata only |
| Japanese fallback | Noto Sans CJK JP | automatic | Kana, kanji, and full-width punctuation |

The Debian packages are `fonts-noto-core` and `fonts-noto-cjk`. The latter also
includes `Noto Sans Mono CJK JP`, which keeps mixed Latin/Japanese terminal text
aligned. Phase 1C installs both only when `--install-deps` is requested.

The UI intentionally avoids synthetic italics and excessive bold text. The
pixel character comes primarily from square geometry, two-pixel bevels, sharp
focus frames, and monospaced labels; this preserves legibility at 100% and 125%
display scaling.
