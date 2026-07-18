#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APPLY=false
INSTALL_DEPS=false
APPLY_LAYOUT=false

usage() {
  cat <<'EOF'
Usage: ./tools/install-theme.sh [--apply] [--layout] [--install-deps]

Installs the MARISHOKU/OS Plasma 6 and Kvantum themes for the current user.
  --apply         Activate the complete theme and MARISHOKU typography.
  --layout        Rebuild the classic taskbar and reapply the default wallpaper.
  --install-deps  Use apt/sudo to install Kvantum, Fastfetch, and Noto fonts.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=true ;;
    --layout) APPLY_LAYOUT=true ;;
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
  sudo apt-get install -y \
    qt-style-kvantum fonts-noto-core fonts-noto-cjk fonts-terminus fastfetch \
    task-japanese-kde-desktop \
    python3-pyqt6 fcitx5 fcitx5-mozc fcitx5-config-qt x11-apps \
    libglib2.0-bin desktop-file-utils xdg-utils
fi

for scheme in "$ROOT"/themes/colors/*.colors; do
  install -Dm644 "$scheme" \
    "$HOME/.local/share/color-schemes/$(basename "$scheme")"
done

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

rm -rf "$HOME/.local/share/icons/MARISHOKU"
mkdir -p "$HOME/.local/share/icons"
cp -a "$ROOT/themes/icons/MARISHOKU" \
  "$HOME/.local/share/icons/"

if command -v xcursorgen >/dev/null 2>&1; then
  "$ROOT/tools/build-cursors.sh"
fi
rm -rf "$HOME/.local/share/icons/MARISHOKU-cursors"
cp -a "$ROOT/themes/cursors/MARISHOKU" \
  "$HOME/.local/share/icons/MARISHOKU-cursors"

rm -rf "$HOME/.local/share/themes/MARISHOKU"
mkdir -p "$HOME/.local/share/themes"
cp -a "$ROOT/themes/gtk/MARISHOKU" "$HOME/.local/share/themes/"

for applet in "$ROOT"/packages/plasma/applets/*; do
  applet_name="$(basename "$applet")"
  applet_target="$HOME/.local/share/plasma/plasmoids/$applet_name"
  if command -v kpackagetool6 >/dev/null 2>&1; then
    # Plasma caches packages by id/version. Remove any registration first,
    # then install the repository payload directly so a successful-but-stale
    # KPackage operation cannot leave an older applet behind.
    kpackagetool6 --type Plasma/Applet --remove "$applet_name" >/dev/null 2>&1 || true
  fi
  rm -rf "$applet_target"
  mkdir -p "$HOME/.local/share/plasma/plasmoids"
  cp -a "$applet" "$applet_target"
  if ! cmp -s "$applet/metadata.json" "$applet_target/metadata.json"; then
    printf 'Applet verification failed: %s\n' "$applet_name" >&2
    exit 1
  fi
done

install -Dm644 "$ROOT/themes/konsole/MARISHOKU.colorscheme" \
  "$HOME/.local/share/konsole/MARISHOKU.colorscheme"
install -Dm644 "$ROOT/themes/konsole/MARISHOKU.profile" \
  "$HOME/.local/share/konsole/MARISHOKU.profile"
mkdir -p "$HOME/.config/fastfetch"
if [[ -f "$HOME/.config/fastfetch/config.jsonc" \
  && ! -f "$HOME/.config/fastfetch/config.jsonc.pre-marishoku.bak" \
  ]] && ! cmp -s "$ROOT/themes/fastfetch/config.jsonc" \
    "$HOME/.config/fastfetch/config.jsonc"; then
  cp -a "$HOME/.config/fastfetch/config.jsonc" \
    "$HOME/.config/fastfetch/config.jsonc.pre-marishoku.bak"
fi
install -Dm644 "$ROOT/themes/fastfetch/config.jsonc" \
  "$HOME/.config/fastfetch/config.jsonc"
install -Dm644 "$ROOT/themes/fastfetch/marishoku-heart.txt" \
  "$HOME/.config/fastfetch/marishoku-heart.txt"
install -Dm755 "$ROOT/tools/marishoku-profile" \
  "$HOME/.local/bin/marishoku-profile"
install -Dm755 "$ROOT/tools/marishoku-first-run" \
  "$HOME/.local/bin/marishoku-first-run"
install -Dm755 "$ROOT/tools/marishoku-launch" \
  "$HOME/.local/bin/marishoku-launch"
install -Dm755 "$ROOT/packages/bin/neofetch" \
  "$HOME/.local/bin/neofetch"
install -Dm755 "$ROOT/packages/system-apps/marishoku_center.py" \
  "$HOME/.local/bin/marishoku-center"
for autostart in "$ROOT"/packages/autostart/*.desktop; do
  install -Dm644 "$autostart" \
    "$HOME/.config/autostart/$(basename "$autostart")"
done
# Remove the Phase 1D every-login prototype dialog.
rm -f "$HOME/.config/autostart/org.marishoku.system-ready.desktop" \
  "$HOME/.local/bin/marishoku-system-ready"
for application in "$ROOT"/packages/applications/*.desktop; do
  install -Dm644 "$application" \
    "$HOME/.local/share/applications/$(basename "$application")"
done
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
fi
if command -v xdg-mime >/dev/null 2>&1; then
  xdg-mime default org.marishoku.url-handler.desktop x-scheme-handler/marishoku
fi

for wallpaper in "$ROOT"/artwork/wallpapers/MARISHOKU-*; do
  wallpaper_name="$(basename "$wallpaper")"
  rm -rf "$HOME/.local/share/wallpapers/$wallpaper_name"
  mkdir -p "$HOME/.local/share/wallpapers"
  cp -a "$wallpaper" "$HOME/.local/share/wallpapers/"
done

rm -rf "$HOME/.local/share/sounds/MARISHOKU"
mkdir -p "$HOME/.local/share/sounds"
cp -a "$ROOT/artwork/sounds/MARISHOKU" "$HOME/.local/share/sounds/"

install -Dm644 "$ROOT/packages/defaults/environment.d/90-marishoku-input.conf" \
  "$HOME/.config/environment.d/90-marishoku-input.conf"
if [[ ! -f "$HOME/.config/fcitx5/profile" ]]; then
  install -Dm644 "$ROOT/packages/defaults/fcitx5/profile" \
    "$HOME/.config/fcitx5/profile"
fi
for gtk_version in 3.0 4.0; do
  settings="$HOME/.config/gtk-$gtk_version/settings.ini"
  if [[ -f $settings && ! -f "$settings.pre-marishoku.bak" ]]; then
    cp -a "$settings" "$settings.pre-marishoku.bak"
  fi
  install -Dm644 "$ROOT/packages/defaults/gtk-$gtk_version/settings.ini" "$settings"
done

rm -rf "$HOME/.cache/plasma"* 2>/dev/null || true
if command -v kbuildsycoca6 >/dev/null 2>&1; then
  kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi

if "$APPLY"; then
  if command -v plasma-apply-lookandfeel >/dev/null 2>&1; then
    plasma-apply-lookandfeel -a org.marishoku.os || true
  elif command -v lookandfeeltool >/dev/null 2>&1; then
    lookandfeeltool -a org.marishoku.os || true
  fi

  if command -v kwriteconfig6 >/dev/null 2>&1; then
    kwriteconfig6 --file kdeglobals --group General --key ColorScheme MARISHOKU
    kwriteconfig6 --file kdeglobals --group Icons --key Theme MARISHOKU
    kwriteconfig6 --file konsolerc --group 'Desktop Entry' --key DefaultProfile MARISHOKU.profile
    kwriteconfig6 --file plasmarc --group Theme --key name org.marishoku.desktop
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key library org.kde.kwin.aurorae
    kwriteconfig6 --file kwinrc --group org.kde.kdecoration2 --key theme __aurorae__svg__MARISHOKU
    kwriteconfig6 --file kwinrc --group Plugins --key blurEnabled false
    kwriteconfig6 --file kcminputrc --group Mouse --key cursorTheme MARISHOKU-cursors
    kwriteconfig6 --file kcminputrc --group Mouse --key cursorSize 32

    kwriteconfig6 --file kdeglobals --group General --key font \
      'Noto Sans,10,-1,5,50,0,0,0,0,0'
    kwriteconfig6 --file kdeglobals --group General --key fixed \
      'Terminus,12,-1,5,50,0,0,0,0,0'
    kwriteconfig6 --file kdeglobals --group General --key menuFont \
      'Terminus,10,-1,5,50,0,0,0,0,0'
    kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont \
      'Noto Sans,8,-1,5,50,0,0,0,0,0'
    kwriteconfig6 --file kdeglobals --group General --key toolBarFont \
      'Terminus,10,-1,5,50,0,0,0,0,0'
    kwriteconfig6 --file kdeglobals --group WM --key activeFont \
      'Terminus,11,-1,5,50,0,0,0,0,0'

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

  if command -v kbuildsycoca6 >/dev/null 2>&1; then
    kbuildsycoca6 >/dev/null 2>&1 || true
  fi

  layout_marker="$HOME/.config/marishoku/layout-v1.3.applied"
  if [[ ! -f "$layout_marker" ]] || "$APPLY_LAYOUT"; then
    applet_config="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
    if [[ -f "$applet_config" && ! -f "${applet_config}.pre-phase1d.bak" ]]; then
      cp -a "$applet_config" "${applet_config}.pre-phase1d.bak"
    fi

    wallpaper_uri="file://$HOME/.local/share/wallpapers/MARISHOKU-URA-V1/contents/images/1920x1080.png"
    layout_script="$(sed "s|@WALLPAPER_URI@|$wallpaper_uri|g" "$ROOT/tools/apply-desktop-layout.js")"
    layout_applied=false
    if command -v qdbus6 >/dev/null 2>&1; then
      if qdbus6 org.kde.plasmashell /PlasmaShell \
        org.kde.PlasmaShell.evaluateScript "$layout_script" >/dev/null; then
        layout_applied=true
      fi
    elif command -v qdbus >/dev/null 2>&1; then
      if qdbus org.kde.plasmashell /PlasmaShell \
        org.kde.PlasmaShell.evaluateScript "$layout_script" >/dev/null; then
        layout_applied=true
      fi
    fi

    if "$layout_applied"; then
      mkdir -p "$(dirname "$layout_marker")"
      touch "$layout_marker"
    else
      printf '%s\n' \
        'Plasma layout application failed. The applets were installed, but the shell did not accept the V1.3 layout.' \
        'Run this command from an active Plasma desktop session, not a TTY or SSH session.' >&2
      exit 1
    fi
  fi

  "$HOME/.local/bin/marishoku-profile" ura || true

  if "$APPLY_LAYOUT" && command -v systemctl >/dev/null 2>&1; then
    systemctl --user restart plasma-plasmashell.service >/dev/null 2>&1 || true
  fi

  printf '%s\n' \
    'MARISHOKU/OS V1.3 desktop installed.' \
    'Log out and back in once to refresh the shell and input method.'
else
  printf '%s\n' \
    'MARISHOKU/OS V1.3 desktop installed for the current user.' \
    'Run again with --apply, or select it in System Settings -> Colors & Themes -> Global Theme.'
fi
