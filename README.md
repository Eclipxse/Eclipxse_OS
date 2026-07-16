# 魔理蝕 // MARISHOKU/OS

`MARISHOKU/OS` is an installable Debian 13 remix built around KDE Plasma 6.
Its visual language combines hard-edged 1990s desktop chrome, handheld
messaging interfaces, pixel manga, CRT texture, and a magenta/cyan after-dark
palette.

![MARISHOKU/OS Phase 0 desktop concept](artwork/concepts/desktop-v0.1.png)

## Identity

- Display name: `魔理蝕 // MARISHOKU/OS`
- System code: `MR-10`
- Device identity: `ECLIPXSE`
- Clean profile: `表 / OMOTE`
- After Dark profile: `裏 / URA`
- Primary architecture: `amd64`
- Base: Debian 13 stable
- Desktop: KDE Plasma 6 on Wayland

## Current milestone

Phase 1A is in progress while the final Phase 0 screenshot is reviewed in the
Debian VM. This repository currently contains:

- the approved visual and interaction specification;
- hardware and content-profile requirements;
- a contrast-checked Plasma 6 color system;
- a Global Theme and Aurorae window decoration;
- original Plasma shell SVGs for panels, dialogs, buttons, fields, tasks,
  selections, headings, arrows, separators, and tooltips;
- installation and validation helpers.

The first ISO will be built only after the desktop theme passes visual review
inside a virtual machine.

## Repository map

```text
artwork/              Original source artwork and exports
docs/                 Product, visual, content, and hardware specifications
iso/                  Debian live-build configuration (Phase 2)
packages/             Debian packaging sources (Phase 2)
themes/               Plasma, Qt, GTK, SDDM, boot, icon, and cursor themes
tools/                Developer installation and validation helpers
```

## Test the Phase 1A theme in a Plasma 6 VM

```bash
./tools/install-theme.sh --apply
```

Log out and back in once after the first application. The script installs into
the current user's home directory; it does not modify the base OS.

## Safety rule

Development is VM-first. No repartitioning, dual boot, NVIDIA driver changes,
or bootloader changes are performed on the ECLIPXSE host during theme development.
