#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  printf '%s\n' 'Run the ISO build with sudo: sudo ./iso/build.sh' >&2
  exit 1
fi

missing=()
for command in lb debootstrap mksquashfs xorriso dpkg-deb python3 xcursorgen \
  grub-mkstandalone mformat mkfs.vfat rsync; do
  command -v "$command" >/dev/null 2>&1 || missing+=("$command")
done
if (( ${#missing[@]} > 0 )); then
  printf 'Missing ISO build tools: %s\n' "${missing[*]}" >&2
  printf '%s\n' 'Install the dependencies listed in iso/README.md and retry.' >&2
  exit 1
fi

if [[ ! -d /usr/lib/grub/x86_64-efi ]]; then
  printf '%s\n' \
    'Missing amd64 UEFI GRUB modules. Install grub-efi-amd64-bin and retry.' >&2
  exit 1
fi

codename="$(. /etc/os-release && printf '%s' "${VERSION_CODENAME:-}")"
if [[ $codename != trixie ]]; then
  printf 'Unsupported build host: %s. Use Debian 13 (trixie).\n' "${codename:-unknown}" >&2
  exit 1
fi

available_kib="$(df -Pk "$ROOT" | awk 'NR == 2 { print $4 }')"
minimum_kib=$((30 * 1024 * 1024))
if (( available_kib < minimum_kib )); then
  printf 'Not enough free disk space: %s GiB available; 30 GiB required.\n' \
    "$((available_kib / 1024 / 1024))" >&2
  exit 1
fi

cd "$ROOT/iso"
./auto/config
./auto/build
