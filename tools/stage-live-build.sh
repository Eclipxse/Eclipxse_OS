#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO_ROOT="$ROOT/iso"
INCLUDES="$(realpath -m "$ISO_ROOT/config/includes.chroot")"
PACKAGES="$(realpath -m "$ISO_ROOT/config/packages.chroot")"
BINARY="$(realpath -m "$ISO_ROOT/config/includes.binary")"
BOOTLOADERS="$(realpath -m "$ISO_ROOT/config/bootloaders")"

case "$INCLUDES" in
  "$ISO_ROOT"/config/includes.chroot) ;;
  *) printf 'Unsafe live-build include path: %s\n' "$INCLUDES" >&2; exit 1 ;;
esac
case "$PACKAGES" in
  "$ISO_ROOT"/config/packages.chroot) ;;
  *) printf 'Unsafe live-build package path: %s\n' "$PACKAGES" >&2; exit 1 ;;
esac
case "$BINARY" in
  "$ISO_ROOT"/config/includes.binary) ;;
  *) printf 'Unsafe binary include path: %s\n' "$BINARY" >&2; exit 1 ;;
esac
case "$BOOTLOADERS" in
  "$ISO_ROOT"/config/bootloaders) ;;
  *) printf 'Unsafe bootloader path: %s\n' "$BOOTLOADERS" >&2; exit 1 ;;
esac

rm -rf -- "$INCLUDES" "$PACKAGES" "$BINARY" "$BOOTLOADERS"
mkdir -p "$INCLUDES" "$PACKAGES" "$BINARY/boot/grub/themes"
"$ROOT/tools/stage-rootfs.sh" "$INCLUDES"

if [[ ! -d /usr/share/live/build/bootloaders ]]; then
  printf '%s\n' 'live-build bootloader templates are missing.' >&2
  exit 1
fi
cp -a /usr/share/live/build/bootloaders "$BOOTLOADERS"
if [[ -d "$BOOTLOADERS/isolinux" ]]; then
  rm -f "$BOOTLOADERS/isolinux/splash.svg"
  install -Dm644 "$ROOT/iso/artwork/splash.png" "$BOOTLOADERS/isolinux/splash.png"
fi
cp -a "$ROOT/themes/boot/grub" "$BINARY/boot/grub/themes/marishoku"

for grub_config in "$BOOTLOADERS"/grub-*/grub.cfg; do
  [[ -f $grub_config ]] || continue
  sed -i '1i if [ -f /boot/grub/themes/marishoku/theme.txt ]; then\n  set theme=/boot/grub/themes/marishoku/theme.txt\n  export theme\nfi' "$grub_config"
done

package="$ROOT/build/packages/marishoku-system_1.0.0-1_all.deb"
if [[ ! -f $package ]]; then
  printf 'Missing package. Run tools/build-package.sh first.\n' >&2
  exit 1
fi
cp "$package" "$PACKAGES/"

printf 'live-build staging ready under %s\n' "$ISO_ROOT/config"
