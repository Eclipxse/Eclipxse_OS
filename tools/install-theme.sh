#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY=false

usage() {
  cat <<'EOF'
Usage: ./tools/install-theme.sh [--apply]

Installs the MARISHOKU/OS Plasma 6 theme for the current user.
  --apply  Also activate the color, Plasma, and Aurorae themes.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; usage >&2; exit 2 ;;
  esac
done

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
  fi

  if command -v qdbus6 >/dev/null 2>&1; then
    qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
  fi

  printf '%s\n' \
    'MARISHOKU/OS Phase 1A theme installed and selected.' \
    'Log out and back in once to refresh every Plasma component.'
else
  printf '%s\n' \
    'MARISHOKU/OS Phase 1A theme installed for the current user.' \
    'Run again with --apply, or select it in System Settings -> Colors & Themes -> Global Theme.'
fi
