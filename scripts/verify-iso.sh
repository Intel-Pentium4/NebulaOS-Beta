#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Uso: $0 archivo.iso [archivo.iso.sha256]" >&2
  exit 2
fi
ISO="$1"
[[ -s "$ISO" ]] || { echo "No existe o está vacío: $ISO" >&2; exit 1; }
if [[ $# -eq 2 ]]; then
  sha256sum --check "$2"
else
  sha256sum "$ISO"
fi
file "$ISO"
du -h "$ISO"
