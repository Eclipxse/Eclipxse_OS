# Build roadmap

## Phase 0 — visual proof

- [x] Approve name and system identity.
- [x] Record initial palette, geometry, typography, motion, and content modes.
- [x] Create Plasma 6 color and package skeletons.
- [x] Approve and ship the first 1920x1080 wallpaper direction.
- [x] Validate color contrast and pixel snapping.

Exit condition: one approved desktop screenshot and a Plasma VM using the
approved colors.

## Phase 1 — complete desktop theme

- [x] Plasma Style SVGs for panels, dialogs, tooltips, and common widgets.
  - [x] Phase 1A core shell frames and interaction states.
  - [x] V1 common widget and interaction states.
- [x] Aurorae title bars and window buttons.
- [x] Kvantum Qt 5/6 application style.
- [x] Noto-based Latin/Japanese typography integration.
- [x] GTK 3/4 companion theme.
- [x] Icon and cursor MVP.
  - [x] Phase 1C launcher and core-app icon set.
  - [x] Original cursor set with Breeze fallback for uncommon cursor roles.
- [x] Launcher, task switcher, notifications, OSD, and KRunner share the V1 shell.
  - [x] Classic bottom taskbar, launcher identity, and task buttons.
  - [x] Phase 1D left tool rail, status block, and URA greeting dialog.
  - [x] Notification and popup frames inherit the Plasma Style.
- [x] SDDM, profile lock wallpaper, and splash screen.
- [x] OMOTE/URA switcher.

Exit condition: native daily-use applications remain visually consistent.

## Phase 2 — live image

- [x] Debian 13 live-build configuration.
- [x] Package lists and system defaults.
- [x] Calamares installer branding over Debian's maintained settings.
- [x] Plymouth and GRUB themes.
- [x] Atomic V1 Debian package builder.
- [ ] VM boot and installation smoke tests.

Exit condition: a reproducible amd64 ISO installs successfully in UEFI mode.

## Phase 3 — ECLIPXSE hardware beta

- [ ] Back up the host and create recovery media.
- [ ] Validate Intel/NVIDIA hybrid graphics.
- [ ] Validate audio, Wi-Fi, Bluetooth, suspend, and external display.
- [ ] Validate Japanese input in Qt, GTK, Firefox, Electron, and Flatpak apps.
- [ ] Test updates and recovery.

Exit condition: no release-blocking failures on the target laptop.

## Phase 4 — release engineering

- [ ] Signed MARISHOKU package repository.
- [ ] Checksums, SBOM, and asset-license manifest.
- [ ] Clean-room rebuild in CI.
- [ ] User and recovery documentation.
- [ ] Public beta and issue templates.
