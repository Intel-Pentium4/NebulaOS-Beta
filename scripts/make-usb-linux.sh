#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $# -ne 2 ]]; then
  echo "Uso: sudo $0 archivo.iso /dev/DISCO_COMPLETO" >&2
  echo "Ejemplo ilustrativo: sudo $0 binary.iso /dev/sdX" >&2
  exit 2
fi
ISO="$(readlink -f -- "$1")"
DEV="$2"

[[ $EUID -eq 0 ]] || { echo "Necesitas sudo para escribir el USB." >&2; exit 1; }
[[ -f "$ISO" ]] || { echo "No encuentro la ISO: $ISO" >&2; exit 1; }
[[ -b "$DEV" ]] || { echo "No es un dispositivo de bloque: $DEV" >&2; exit 1; }
[[ "$DEV" != "$ISO" ]] || { echo "Dispositivo e ISO no pueden ser el mismo archivo." >&2; exit 1; }

printf 'Dispositivo seleccionado:\n'
lsblk -o NAME,SIZE,MODEL,TRAN,MOUNTPOINTS "$DEV"
echo
printf 'ATENCIÓN: todo el contenido de %s se sobrescribirá.\n' "$DEV"
read -r -p "Escribe BORRAR para confirmar: " confirm
[[ "$confirm" == BORRAR ]] || { echo "Cancelado."; exit 1; }

while read -r part; do
  [[ -n "$part" ]] && umount "$part" 2>/dev/null || true
done < <(lsblk -lnpo NAME,MOUNTPOINTS "$DEV" | awk 'NF >= 2 {print $1}')

dd if="$ISO" of="$DEV" bs=4M status=progress conv=fsync
sync
printf '\nUSB grabado. Retíralo de forma segura y arranca desde el menú de arranque del PC.\n'
