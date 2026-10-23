#!/usr/bin/env bash
# Apply the Lumora theme to an EXISTING GNOME desktop (no ISO needed).
#   bash linux/install-theme.sh          install
#   bash linux/install-theme.sh --undo   restore GNOME defaults for the keys we set
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OV="$ROOT/overlay/includes.chroot"
UUID="lumora-clock@lumora"
EXTDIR="$HOME/.local/share/gnome-shell/extensions"
BGDIR="$HOME/.local/share/backgrounds/lumora"
BACKUP="$HOME/.config/lumora-backup.dconf"

if [ "${1:-}" = "--undo" ]; then
  [ -f "$BACKUP" ] && dconf load / < "$BACKUP" && echo "Restored previous settings."
  rm -rf "$EXTDIR/$UUID" "$BGDIR"
  rm -f "$HOME/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
  echo "Removed Lumora files. Log out and back in."
  exit 0
fi

if [ "$(id -u)" -eq 0 ]; then echo "Run as your normal user, not root."; exit 1; fi

echo "==> Packages"
if command -v apt-get >/dev/null; then
  sudo apt-get install -y papirus-icon-theme fonts-inter gnome-shell-extension-manager \
    gnome-shell-extension-dash-to-dock gnome-shell-extension-blur-my-shell gnome-shell-extension-caffeine || true
elif command -v dnf >/dev/null; then
  sudo dnf install -y papirus-icon-theme rsms-inter-fonts gnome-extensions-app \
    gnome-shell-extension-dash-to-dock gnome-shell-extension-blur-my-shell gnome-shell-extension-caffeine || true
else
  echo "Unknown package manager: install Papirus icons, Inter font, Dash to Dock, Blur my Shell and Caffeine yourself."
fi

echo "==> Backing up current settings to $BACKUP"
dconf dump / > "$BACKUP"

echo "==> Files"
mkdir -p "$EXTDIR" "$BGDIR" "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
cp -r "$OV/usr/share/gnome-shell/extensions/$UUID" "$EXTDIR/"
cp "$OV/usr/share/backgrounds/lumora/lumora.png" "$BGDIR/"
for v in gtk-3.0 gtk-4.0; do
  [ -f "$HOME/.config/$v/gtk.css" ] && cp "$HOME/.config/$v/gtk.css" "$HOME/.config/$v/gtk.css.bak"
  cp "$OV/etc/skel/.config/$v/gtk.css" "$HOME/.config/$v/gtk.css"
done

echo "==> Settings"
sed "s#file:///usr/share/backgrounds/lumora/lumora.png#file://$BGDIR/lumora.png#g" \
  "$OV/etc/dconf/db/local.d/00-lumora" | dconf load /

gnome-extensions enable "$UUID" 2>/dev/null || echo "Log out and back in, then run: gnome-extensions enable $UUID"
echo "Done. Log out and back in for everything to apply."
