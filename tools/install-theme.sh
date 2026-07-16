#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

printf '%s\n' \
  'MARISHOKU/OS Phase 0 theme installed for the current user.' \
  'Open System Settings -> Colors & Themes -> Global Theme.'
