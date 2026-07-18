# MARISHOKU system package

V1 builds one bootstrap package, `marishoku-system`, so the live image and the
installed system own the same files. The payload is staged by
`tools/stage-rootfs.sh`; `tools/build-package.sh` compiles the cursor theme and
builds the `.deb` with `dpkg-deb`.

The package contains:

- boot, SDDM, Plasma, Kvantum, GTK, icon, cursor, Konsole, and sound themes;
- OMOTE and URA wallpapers and profile declarations;
- Command Launcher, Control Center, Storage Care, Welcome, and profile commands;
- current-user defaults for Fastfetch, Fcitx/Mozc, lock wallpaper, and GTK;
- Calamares branding and system configuration snippets.

`os-release` is deliberately excluded from the `.deb` because Debian's
`base-files` owns that path. The live image applies the identity file through
`includes.chroot`, avoiding an invalid dpkg file conflict.

Future repository releases may split this bootstrap package into independent
theme, wallpaper, defaults, and application packages. V1 keeps it atomic so a
test installation cannot land between mismatched visual versions.
