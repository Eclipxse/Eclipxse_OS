# V1 VM and release checklist

Use a disposable VM disk. Never test the installer against the Windows host
drive.

## Theme update test

- [ ] Pull `agent/marishoku-v1` with a clean worktree.
- [ ] Run `./tools/install-theme.sh --install-deps --apply --layout`.
- [ ] Log out and back in.
- [ ] Confirm the Phase 1D every-login dialog is gone.
- [ ] Confirm square window chrome, bottom taskbar, left tool rail, cursor, GTK,
      Qt, Konsole, and Fastfetch heart.
- [ ] Run `marishoku-profile omote`, then `marishoku-profile ura`.
- [ ] Lock after each profile and confirm its wallpaper.
- [ ] Open Control Center, Welcome, Storage Care, and each tool-rail shortcut.
- [ ] Confirm Storage Care never offers deletion.
- [ ] Add Mozc in Fcitx and switch EN/JA with Ctrl+Space.

## Live media test

- [ ] Build on Debian 13 from a clean clone.
- [ ] Record the ISO SHA-256 digest and exact commit.
- [ ] Boot one VM with EFI + Secure Boot enabled.
- [ ] Boot one VM in legacy BIOS mode.
- [ ] Confirm the faux BIOS, live boot, Plymouth, SDDM, and Plasma hand-offs.
- [ ] Confirm network, PipeWire audio, clipboard, dynamic resolution, and shared
      folders in the live session.
- [ ] Launch Calamares from the desktop.
- [ ] Confirm the target disk summary before committing partition changes.
- [ ] Install to the disposable VM disk, shut down, and eject the ISO.
- [ ] Boot the installed system twice.
- [ ] Lock/unlock, reboot, shut down, suspend/resume, and switch both profiles.
- [ ] Run `sudo apt update && sudo apt full-upgrade`, reboot, and retest login.

## Visual acceptance at 1920x1080

- [ ] No rounded core controls or glass/blur.
- [ ] No fake windows in either wallpaper.
- [ ] All frame edges land on the 2x pixel grid.
- [ ] Titlebars remain 26 px and text is vertically centered.
- [ ] Japanese glyphs render; no tofu boxes or mojibake.
- [ ] Text remains legible over boot, SDDM, lock, and splash backgrounds.
- [ ] OMOTE reads pearl/violet/pastel; URA reads graphite/pink/cyan.
- [ ] Hearts, stars, blossoms, and scanlines do not cover controls.

## Hardware beta gate

Only after the VM checklist passes twice:

- [ ] Create Windows recovery media and a verified full backup.
- [ ] Test from a USB live boot without installing.
- [ ] Verify Intel display, RTX 3050 detection, Wi-Fi, Bluetooth, speakers,
      microphone, webcam, touchpad, mouse, suspend, battery, and external display.
- [ ] Decide separately whether to install Debian's NVIDIA driver.
- [ ] Do not repartition until recovery and live-hardware results are recorded.

VirtualBox's virtual monitor often exposes only 60 Hz. That does not prove the
installed laptop panel is limited to 60 Hz; 144 Hz belongs to the hardware beta
test, not the VirtualBox visual test.
