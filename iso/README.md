# MARISHOKU/OS live ISO

This directory is a Debian live-build configuration for an amd64 hybrid ISO.
It includes KDE Plasma 6, the MARISHOKU system package, Calamares, VM guest
integration, non-free firmware, Japanese input, and the branded boot/session
path.

## Build host

Use a clean Debian 13 installation or disposable Debian 13 VM with at least
30 GiB free disk space and 8 GiB RAM. Building inside the MARISHOKU development
VM is supported. Windows cannot run live-build directly.

```bash
sudo apt update
sudo apt install --yes live-build debootstrap squashfs-tools xorriso \
  isolinux syslinux-common grub-efi-amd64-bin grub-pc-bin shim-signed \
  mtools dosfstools rsync python3-pil dpkg-dev x11-apps
git clone https://github.com/Eclipxse/Eclipxse_OS.git
cd Eclipxse_OS
git switch main
sudo ./iso/build.sh
```

The result is `iso/marishoku-os-v1.3-amd64.hybrid.iso`. `sudo` is required only
for the chroot/image build. Theme development still uses the unprivileged
`tools/install-theme.sh` workflow.

The wrapper checks that it is running on Debian 13, that required build tools
exist, and that at least 30 GiB is free before downloading packages. On a
retry after a failed live-build run, clean its chroot first:

```bash
cd iso
sudo ./auto/clean
cd ..
sudo ./iso/build.sh
```

The default clean preserves downloaded package caches for a faster retry. Use
`sudo ./auto/clean --purge` only when the cache itself must be discarded.

## Test safely

1. Create a new VM with 8 GiB RAM, 4 vCPUs, 64-80 GiB dynamic disk, EFI, and
   VMSVGA with 128 MiB video memory and 3D acceleration.
2. Boot the ISO and test the live session first.
3. Test Calamares only against the disposable VM disk.
4. Verify boot, login, lock/unlock, both profiles, Japanese input, audio,
   networking, suspend, shutdown, and a second installed-system boot.
5. Never point the installer at the ECLIPXSE Windows disk during development.

## Release gate

V1 is not releasable until the SHA-256 digest is published, both BIOS and UEFI
boot paths pass, Calamares installs successfully twice from a clean image, and
the installed system survives an `apt full-upgrade`.
