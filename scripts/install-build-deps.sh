#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $EUID -eq 0 ]]; then
  echo "No ejecutes este script como root; se usará sudo cuando sea necesario." >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "No puedo identificar la distribución del sistema anfitrión." >&2
  exit 1
fi
# shellcheck disable=SC1091
. /etc/os-release
if [[ ${ID:-} != debian || ${VERSION_CODENAME:-} != trixie ]]; then
  echo "Aviso: se recomienda Debian 13 Trixie amd64 como anfitrión de construcción." >&2
  read -r -p "¿Intentar instalar herramientas en ${PRETTY_NAME:-este sistema}? [s/N] " answer
  case "$answer" in [sS]|[sS][iI]) ;; *) exit 1 ;; esac
fi

sudo apt-get update
sudo apt-get install --no-install-recommends -y \
  live-build debootstrap squashfs-tools xorriso isolinux syslinux-common \
  grub-pc-bin grub-efi-amd64-bin dosfstools mtools rsync ca-certificates

printf '\nHerramientas instaladas. Recomendado: comprueba que `lb --version` funciona.\n'
