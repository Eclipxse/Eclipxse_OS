# Build roadmap

## Phase 0 — visual proof

- [x] Approve name and system identity.
- [x] Record initial palette, geometry, typography, motion, and content modes.
- [x] Create Plasma 6 color and package skeletons.
- [ ] Approve one 1920×1080 desktop concept.
- [x] Validate color contrast and pixel snapping.

Exit condition: one approved desktop screenshot and a Plasma VM using the
approved colors.

## Phase 1 — complete desktop theme

- [ ] Plasma Style SVGs for panels, dialogs, tooltips, and widgets.
  - [x] Phase 1A core shell frames and interaction states.
  - [ ] Remaining meters, edit-mode controls, and uncommon widget states.
- [x] Aurorae title bars and window buttons.
- [x] Kvantum Qt 5/6 application style.
- [x] Noto-based Latin/Japanese typography integration.
- [ ] GTK 3/4 companion theme.
- [ ] Icon and cursor MVP.
- [ ] Launcher, task switcher, notifications, OSD, and KRunner skin.
- [ ] SDDM, lock screen, and splash screen.
- [ ] OMOTE/URA switcher.

Exit condition: native daily-use applications remain visually consistent.

## Phase 2 — live image

- [ ] Debian 13 live-build configuration.
- [ ] Package lists and system defaults.
- [ ] Calamares installer branding and configuration.
- [ ] Plymouth and GRUB themes.
- [ ] Debian packages for all MARISHOKU components.
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
