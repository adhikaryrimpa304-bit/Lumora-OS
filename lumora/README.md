# Lumora

A dark desktop identity for Linux (GNOME) and Windows: electric purple as the primary color, neon cyan as the secondary, on deep violet. Rounded, friendly shapes.

| Role | Color |
|---|---|
| Background | `#130B20` |
| Surfaces | `#1C1230` `#261A40` `#2C1F4D` |
| Primary (electric purple) | `#B026FF` (dark `#6A1FD0`, light `#D8A6FF`) |
| Secondary (neon cyan) | `#00F0FF` |

Primary fills buttons, toggles and selection; neon cyan is used for highlights: focused-window glow, running-app dots, and close-button hover.

Includes a split purple/cyan desktop clock that follows your 12h/24h setting.

## Linux

**Build the OS (ISO)** on Debian/Ubuntu (~15 GB free, 30-60 min):

    bash linux/build-iso.sh

No Linux machine? Push this folder to GitHub and run the **Build Lumora ISO** workflow (Actions tab); the ISO is attached to the run.

Test in a VM: `qemu-system-x86_64 -m 4096 -enable-kvm -cdrom <iso>`. Live login, if asked: `user` / `live`. Write to USB with balenaEtcher.

**Just theme an existing GNOME desktop:**

    bash linux/install-theme.sh          # settings are backed up first
    bash linux/install-theme.sh --undo

Change 12h/24h: Settings > System > Date & Time, or `gsettings set org.gnome.desktop.interface clock-format '12h'`.

## Windows 10/11

    powershell -ExecutionPolicy Bypass -File .\windows\install.ps1
    powershell -ExecutionPolicy Bypass -File .\windows\uninstall.ps1

Installs dark mode, purple title bars, the wallpaper, and the Rainmeter clock (double-click = 12h, middle-click = 24h). Your previous settings are backed up and restored by the uninstaller. Windows cannot restyle title-bar buttons without third-party tools.

## Status

Written and syntax-checked, but not yet run on real hardware. Expect to adjust a package name or a Rainmeter detail on the first run, and please test the ISO in a VM before writing it to a USB stick.

## Layout

    assets/      wallpaper
    linux/       build-iso.sh, install-theme.sh, overlay/ (theme, extension, package list)
    windows/     install.ps1, uninstall.ps1, Clock.ini
    .github/     ISO build workflow
