#!/usr/bin/env bash
# Builds NebulaOS inside a disposable Debian Trixie builder container.
# Must run as root in the builder environment (GitHub Actions workflow does this).
set -Eeuo pipefail

PROFILE="${1:-gaming}"
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

case "$PROFILE" in
  gaming)
    cp config/package-lists/nebula-gaming.list.chroot.in config/package-lists/nebula-gaming.list.chroot
    ;;
  minimal)
    rm -f config/package-lists/nebula-gaming.list.chroot
    ;;
  *)
    echo "Perfil inválido: $PROFILE (usa gaming o minimal)." >&2
    exit 2
    ;;
esac

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Este script debe ejecutarse como root dentro del entorno de construcción." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  live-build debootstrap ca-certificates debian-archive-keyring \
  xorriso isolinux syslinux-common grub-pc-bin grub-efi-amd64-bin grub-efi-ia32-bin \
  mtools dosfstools squashfs-tools xz-utils rsync cpio wget curl gnupg apt-utils file

# Rebuild from a clean live-build configuration. Only generated build files are removed.
lb clean --purge || true
rm -f config/binary config/bootstrap config/chroot config/common config/source
rm -f binary.iso binary.iso.sha256

lb config \
  --distribution trixie \
  --architectures amd64 \
  --binary-image iso-hybrid \
  --archive-areas "main contrib non-free non-free-firmware" \
  --apt-recommends false \
  --apt-secure true \
  --firmware-binary true \
  --firmware-chroot true \
  --uefi-secure-boot auto \
  --iso-application "NebulaOS" \
  --iso-publisher "NebulaOS Project" \
  --iso-volume "NEBULAOS_01" \
  --bootappend-live "boot=live components username=nebula locales=es_ES.UTF-8 keyboard-layouts=es timezone=America/New_York"

lb build

test -s binary.iso || { echo "ERROR: live-build terminó sin crear binary.iso" >&2; exit 1; }
sha256sum binary.iso | tee binary.iso.sha256
ls -lh binary.iso binary.iso.sha256
