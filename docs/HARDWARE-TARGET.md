# ECLIPXSE hardware target

The first hardware target is a 64-bit laptop with:

- Intel Core i5-12450HX;
- 16 GB RAM;
- NVIDIA GeForce RTX 3050 Laptop GPU with 6 GB VRAM;
- approximately 477 GB internal storage;
- keyboard and pointer input, without touch or pen.

Device IDs and Windows product identifiers are intentionally not stored.

## Graphics assumptions

This class of laptop normally uses hybrid Intel/NVIDIA graphics. The test plan
therefore covers:

- Plasma 6 Wayland on the integrated GPU;
- Debian-packaged proprietary NVIDIA driver;
- PRIME render offload for selected applications;
- X11 recovery session during early releases;
- external display detection;
- suspend/resume and brightness control;
- operation with the discrete GPU powered down when idle.

The distribution will not ship an independently patched kernel or a custom
NVIDIA driver.

## VM budget

- 4 virtual CPU threads;
- 6–8 GB RAM;
- 50 GB dynamically allocated virtual disk;
- UEFI firmware;
- 1920×1080 initial display.

The host currently has limited spare disk capacity. ISO build caches and
multiple virtual disks can consume tens of gigabytes, so the target is at least
120 GB free before full image and dual-boot testing.

## Input

English is the default locale. Japanese input is optional and implemented with
Fcitx 5 plus Mozc. Candidate windows receive the same hard-beveled theme as the
rest of the shell.

