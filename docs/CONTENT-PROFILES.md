# Content profiles

MARISHOKU/OS supports two presentation profiles without maintaining two
separate operating systems.

## 表 / OMOTE

OMOTE is safe for public screens, streaming, repair shops, classrooms, and
shared spaces. It retains the complete color and UI identity while using
non-explicit wallpaper, lock-screen art, avatars, and sounds.

## 裏 / URA

URA is the owner-approved After Dark profile. It may contain mature or explicit
wallpapers, lock-screen artwork, visualizer media, and stronger language.

Requirements for all URA assets:

- original work or a documented redistribution license;
- only clearly adult subjects;
- no ambiguous-age characters;
- no non-consensual sexual material;
- no private or leaked imagery;
- provenance recorded in `ASSETS.yml` before packaging.

The ECLIPXSE personal installation may default to URA. A panel shortcut and a
global hotkey will switch to OMOTE before screen sharing without logging out.
The switch changes content assets and selected copy, never security settings.

Planned state files:

```text
~/.config/marishoku/profile.conf
/usr/share/marishoku/profiles/omote/
/usr/share/marishoku/profiles/ura/
```

