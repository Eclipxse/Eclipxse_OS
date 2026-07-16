#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY=false
INSTALL_DEPS=false

usage() {
  cat <<'EOF'
Usage: ./tools/install-theme.sh [--apply] [--install-deps]

Installs the MARISHOKU/OS Plasma 6 and Kvantum themes for the current user.
  --apply         Activate the complete theme and MARISHOKU typography.
  --install-deps  Use apt/sudo to install Kvantum and Noto Japanese fonts.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=true ;;
    --install-deps) INSTALL_DEPS=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
  esac
done

if "$INSTALL_DEPS"; then
  if ! command -v apt-get >/dev/null 2>&1; then
    printf '%s\n' 'Dependency installation currently supports Debian/apt only.' >&2
    exit 1
  fi
  sudo apt-get update
  sudo apt-get install -y qt-style-kvantum fonts-noto-core fonts-noto-cjk
fi

install -Dm644 "$ROOT/themes/colors/MARISHOKU.colors" \
  "$HOME/.local/share/color-schemes/MARISHOKU.colors"

rm -rf "$HOME/.local/share/plasma/desktoptheme/org.marishoku.desktop"
mkdir -p "$HOME/.local/share/plasma/desktoptheme"
cp -a "$ROOT/themes/plasma-style/org.marishoku.desktop" \
  "$HOME/.local/share/plasma/desktoptheme/"

rm -rf "$HOME/.local/share/plasma/look-and-feel/org.marishoku.os"
mkdir -p "$HOME/.local/share/plasma/look-and-feel"
cp -a "$ROOT/themes/global/org.marishoku.os" \
  "$HOME/.local/share/plasma/look-and-feel/"

rm -rf "$HOME/.local/share/aurorae/themes/MARISHOKU"
mkdir -p "$HOME/.local/share/aurorae/themes"
cp -a "$ROOT/themes/aurorae/MARISHOKU" \
  "$HOME/.local/share/aurorae/themes/"

rm -rf "$HOME/.config/Kvantum/MARISHOKU"
mkdir -p "$HOME/.config/Kvantum"
cp -a "$ROOT/themes/kvantum/MARISHOKU" \
  "$HOME/.config/Kvantum/"

rm -rf "$HOME/.cache/plasma"* 2>/dev/null || true

if "$APPLY"; then
  if command -v plasma-apply-lookandfeel >/dev/null 2>&1; then
    plasma-apply-lookandfeel -a org.marishoku.os || true
  elif command -v lookandfeeltool >/dev/null 2>&1; then
    lookandfeeltool -a org.marishoku.os || true
  fi

  if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kdeglobals --group General --key ColorScheme MARISHOKU
    kwriteconfig6 --file plasmarc --group Theme --key name org.marishoku.desktop
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme __aurorae__svg__MARISHOKU
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled false

    kwriteconfig6 --file kdeglobals --group General --key font \
      'Noto Sans,10,-1,5,50,0,0,0,0,0'
    kwriteconfig6 --file kdeglobals --group General --key fixed \
      'Noto Sans Mono,10,-1,5,50,0,0,0,0,0'
    kwriteconfig6 --file kdeglobals --group General --key menuFont \
      'Noto Sans Mono,9,-1,5,50,0,0,0,0,0'
    kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont \
      'Noto Sans,8,-1,5,50,0,0,0,0,0'
    kwriteconfig6 --file kdeglobals --group General --key toolBarFont \
      'Noto Sans Mono,9,-1,5,50,0,0,0,0,0'
    kwriteconfig6 --file kdeglobals --group WM --key activeFont \
      'Noto Sans Mono,10,-1,5,50,0,0,0,0,0'

    if command -v kvantummanager >/dev/null 2>&1 \
      || command -v kvantummanager6 >/dev/null 2>&1 \
      || command -v kvantumpreview >/dev/null 2>&1; then
      kwriteconfig6 --file Kvantum/kvantum.kvconfig --group General --key theme MARISHOKU
      kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle kvantum
    else
      printf '%s\n' \
        'Kvantum is not installed, so the Qt application style was not activated.' \
        'Run this script again with --install-deps --apply.' >&2
    fi
  fi

  if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
  fi

  printf '%s\n' \
    'MARISHOKU/OS Phase 1B theme installed and selected.' \
    'Log out and back in once to refresh every Plasma component.'
else
  printf '%s\n' \
    'MARISHOKU/OS Phase 1B theme installed for the current user.' \
    'Run again with --apply, or select it in System Settings -> Colors & Themes -> Global Theme.'
fi
