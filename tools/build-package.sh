#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD="$ROOT/build/package/marishoku-system"
OUTPUT="$ROOT/build/packages"
PACKAGE_VERSION="$(awk '/^Version:/ { print $2; exit }' "$ROOT/packages/debian/control")"

resolved_build="$(realpath -m "$BUILD")"
case "$resolved_build" in
  "$ROOT"/build/package/*) ;;
  *) printf 'Unsafe package build path: %s\n' "$resolved_build" >&2; exit 1 ;;
esac

rm -rf -- "$resolved_build"
mkdir -p "$resolved_build/DEBIAN" "$OUTPUT"
"$ROOT/tools/build-cursors.sh"
"$ROOT/tools/stage-rootfs.sh" "$resolved_build"
# os-release is owned by Debian's base-files package. The live image overlays
# identity from includes.chroot instead of creating a dpkg file conflict.
rm -f -- "$resolved_build/usr/lib/os-release" "$resolved_build/etc/lsb-release"
install -Dm644 "$ROOT/packages/debian/control" "$resolved_build/DEBIAN/control"
install -Dm755 "$ROOT/packages/debian/postinst" "$resolved_build/DEBIAN/postinst"

dpkg-deb --root-owner-group --build "$resolved_build" \
  "$OUTPUT/marishoku-system_${PACKAGE_VERSION}_all.deb"
printf 'Package ready: %s\n' "$OUTPUT/marishoku-system_${PACKAGE_VERSION}_all.deb"
