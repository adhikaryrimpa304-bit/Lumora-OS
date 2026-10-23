#!/usr/bin/env bash
# Build the Lumora OS ISO (Debian 13 "trixie", amd64, GNOME).
# Needs a Debian/Ubuntu host, ~15 GB free disk and internet. Takes 30-60 minutes.
#   bash linux/build-iso.sh            (normal user, uses sudo)
#   WORK=/path/to/dir bash linux/build-iso.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="${WORK:-$HOME/lumora-iso}"
if [ "$(id -u)" -eq 0 ]; then SUDO=""; else SUDO="sudo"; fi

echo "==> Installing build tools"
$SUDO apt-get update
$SUDO apt-get install -y live-build debootstrap squashfs-tools xorriso debian-archive-keyring ca-certificates

mkdir -p "$WORK"
cd "$WORK"
$SUDO lb clean --purge 2>/dev/null || true

echo "==> Configuring"
lb config \
  --distribution trixie \
  --architectures amd64 \
  --archive-areas "main contrib non-free-firmware" \
  --debian-installer live \
  --debian-installer-gui true \
  --iso-volume "LUMORA" \
  --iso-application "Lumora OS" \
  --iso-publisher "Lumora" \
  --bootappend-live "boot=live components quiet splash locales=en_US.UTF-8 keyboard-layouts=us"

echo "==> Applying Lumora overlay"
cp -a "$ROOT/overlay/." config/

echo "==> Building ISO"
$SUDO lb build

ISO="$(ls -1 "$WORK"/*.iso | head -n1)"
echo
echo "Done: $ISO"
echo "Test in a VM:  qemu-system-x86_64 -m 4096 -enable-kvm -cdrom \"$ISO\""
echo "Live login (if asked): user 'user', password 'live'"
