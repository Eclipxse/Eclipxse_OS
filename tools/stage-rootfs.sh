#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $# -ne 1 ]]; then
  printf 'Usage: %s ROOTFS-DIRECTORY\n' "$0" >&2
  exit 2
fi

DEST="$(realpath -m "$1")"
if [[ $DEST == / || -z $DEST ]]; then
  printf '%s\n' 'Refusing to stage into the host root.' >&2
  exit 1
fi
mkdir -p "$DEST"

copy_tree() {
  local source=$1 target=$2
  mkdir -p "$DEST/$target"
  cp -a "$ROOT/$source/." "$DEST/$target/"
}

copy_tree themes/colors usr/share/color-schemes
copy_tree themes/plasma-style usr/share/plasma/desktoptheme
copy_tree themes/global usr/share/plasma/look-and-feel
copy_tree themes/aurorae usr/share/aurorae/themes
copy_tree themes/icons usr/share/icons
copy_tree themes/cursors/MARISHOKU usr/share/icons/MARISHOKU-cursors
copy_tree themes/gtk/MARISHOKU usr/share/themes/MARISHOKU
copy_tree themes/konsole usr/share/konsole
copy_tree artwork/wallpapers usr/share/wallpapers
copy_tree artwork/sounds usr/share/sounds
copy_tree packages/plasma/applets usr/share/plasma/plasmoids
copy_tree themes/sddm usr/share/sddm/themes
copy_tree themes/boot/grub usr/share/grub/themes/marishoku
copy_tree themes/boot/plymouth/marishoku usr/share/plymouth/themes/marishoku
copy_tree packages/installer/branding/marishoku etc/calamares/branding/marishoku

install -Dm644 "$ROOT/themes/kvantum/MARISHOKU/MARISHOKU.kvconfig" \
  "$DEST/usr/share/Kvantum/MARISHOKU/MARISHOKU.kvconfig"
install -Dm644 "$ROOT/themes/kvantum/MARISHOKU/MARISHOKU.svg" \
  "$DEST/usr/share/Kvantum/MARISHOKU/MARISHOKU.svg"
install -Dm644 "$ROOT/themes/fastfetch/config.jsonc" \
  "$DEST/etc/skel/.config/fastfetch/config.jsonc"
install -Dm644 "$ROOT/themes/fastfetch/marishoku-heart.txt" \
  "$DEST/etc/skel/.config/fastfetch/marishoku-heart.txt"

install -Dm755 "$ROOT/tools/marishoku-profile" "$DEST/usr/bin/marishoku-profile"
install -Dm755 "$ROOT/packages/system-apps/marishoku_center.py" "$DEST/usr/bin/marishoku-center"
install -Dm755 "$ROOT/tools/marishoku-first-run" "$DEST/usr/bin/marishoku-first-run"

for application in "$ROOT"/packages/applications/*.desktop; do
  install -Dm644 "$application" "$DEST/usr/share/applications/$(basename "$application")"
done
for autostart in "$ROOT"/packages/autostart/*.desktop; do
  install -Dm644 "$autostart" "$DEST/etc/skel/.config/autostart/$(basename "$autostart")"
done

install -Dm644 "$ROOT/packages/defaults/environment.d/90-marishoku-input.conf" \
  "$DEST/etc/skel/.config/environment.d/90-marishoku-input.conf"
install -Dm644 "$ROOT/packages/defaults/fcitx5/profile" \
  "$DEST/etc/skel/.config/fcitx5/profile"
install -Dm644 "$ROOT/packages/defaults/kscreenlockerrc" \
  "$DEST/etc/skel/.config/kscreenlockerrc"
install -Dm644 "$ROOT/packages/defaults/gtk-3.0/settings.ini" \
  "$DEST/etc/skel/.config/gtk-3.0/settings.ini"
install -Dm644 "$ROOT/packages/defaults/gtk-4.0/settings.ini" \
  "$DEST/etc/skel/.config/gtk-4.0/settings.ini"
install -Dm644 "$ROOT/packages/defaults/marishoku/profile" \
  "$DEST/etc/skel/.config/marishoku/profile"

install -Dm644 "$ROOT/packages/config/sddm/10-marishoku.conf" \
  "$DEST/etc/sddm.conf.d/10-marishoku.conf"
install -Dm644 "$ROOT/packages/config/grub/99-marishoku.cfg" \
  "$DEST/etc/default/grub.d/99-marishoku.cfg"
install -Dm644 "$ROOT/packages/branding/os-release" "$DEST/usr/lib/os-release"
install -Dm644 "$ROOT/packages/branding/lsb-release" "$DEST/etc/lsb-release"

printf 'Staged MARISHOKU/OS root filesystem at %s\n' "$DEST"
