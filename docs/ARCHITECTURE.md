# MARISHOKU/OS V1 architecture

MARISHOKU/OS V1 is a Debian 13 (Trixie) live image with KDE Plasma 6. Debian
remains the package and hardware foundation; MARISHOKU owns the visual shell,
defaults, profiles, branded utilities, boot hand-off, and installer identity.

## Layers

1. `themes/boot` contains the reversible GRUB and Plymouth faux-BIOS layer.
2. `themes/sddm` and the Look-and-Feel package own sign-in, splash, and lock.
3. Plasma Style, Aurorae, Kvantum, icons, colors, Konsole, and wallpapers form
   one shared 2x pixel system.
4. `profiles` declares OMOTE and URA. `marishoku-profile` applies either as one
   transaction and records the choice in `~/.config/marishoku/profile`.
5. `packages/system-apps` supplies Control Center, Storage Care, Welcome, and
   profile utilities. Destructive cleanup is intentionally excluded from V1.
6. `iso` is a reproducible Debian live-build configuration. Its staging script
   copies versioned repository assets into `config/includes.chroot` before a
   build, so the ISO cannot drift from Git.

## Boot and session flow

```text
UEFI -> GRUB faux BIOS -> Linux/initramfs -> Plymouth -> SDDM
     -> Plasma global theme -> first-run Welcome -> OMOTE or URA
```

## Packaging policy

- System files live under `/usr/share`, `/usr/lib`, and `/etc`.
- User defaults are placed in `/etc/skel`; first-run changes are never written
  into a developer's home while assembling the ISO.
- Upstream Debian repositories remain enabled and unmodified.
- `ID_LIKE=debian` is retained in `os-release` for compatibility.
- Secure Boot is not disabled by the project.

## Development targets

The primary reference is 1920x1080 at 100% scale. VirtualBox is a functional
test target, not the performance reference: its virtual display commonly
reports 60 Hz. Final high-refresh testing belongs on installed hardware or a
KVM/QEMU guest with accelerated display support.
