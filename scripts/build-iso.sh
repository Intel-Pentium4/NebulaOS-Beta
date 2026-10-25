#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MODE=gaming
case "${1:-}" in
  "") ;;
  --gaming) MODE=gaming ;;
  --minimal) MODE=minimal ;;
  -h|--help)
    echo "Uso: $0 [--gaming|--minimal]"
    echo "Predeterminado: --gaming"
    exit 0
    ;;
  *) echo "Opción desconocida: $1" >&2; exit 2 ;;
esac

if ! command -v lb >/dev/null 2>&1; then
  echo "Falta live-build. Ejecuta primero ./scripts/install-build-deps.sh" >&2
  exit 1
fi
if [[ $EUID -eq 0 ]]; then
  echo "Ejecuta este script como usuario normal; él mismo usa sudo para live-build." >&2
  exit 1
fi

cd "$ROOT"
GENERATED_LIST="$ROOT/config/package-lists/nebula-gaming.list.chroot"
cleanup() { rm -f "$GENERATED_LIST"; }
trap cleanup EXIT
rm -f "$GENERATED_LIST"
if [[ $MODE == gaming ]]; then
  cp "$ROOT/config/package-lists/nebula-gaming.list.chroot.in" "$GENERATED_LIST"
  echo "Perfil: Gaming"
else
  echo "Perfil: Minimal"
fi

printf '\nSe limpiará el árbol previo de live-build dentro de este proyecto y se reconstruirá desde cero.\n'
read -r -p '¿Continuar? [s/N] ' answer
case "$answer" in [sS]|[sS][iI]) ;; *) echo "Cancelado."; exit 0 ;; esac

sudo lb clean --purge
# live-build documents these generated config files as needing removal before reconfiguration.
sudo rm -f config/binary config/bootstrap config/chroot config/common config/source
sudo lb config \
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

sudo lb build

if [[ ! -s "$ROOT/binary.iso" ]]; then
  echo "live-build terminó, pero no encuentro binary.iso. Revisa los mensajes anteriores." >&2
  exit 1
fi
sudo chown "$(id -u):$(id -g)" "$ROOT/binary.iso"
sha256sum "$ROOT/binary.iso" | tee "$ROOT/binary.iso.sha256"
printf '\nISO generada: %s\n' "$ROOT/binary.iso"
du -h "$ROOT/binary.iso"
printf 'SHA-256: '
sha256sum "$ROOT/binary.iso" | awk '{print $1}'
echo "IMPORTANTE: haber generado la ISO no demuestra que arranque ni que el instalador funcione. Sigue docs/TEST-PLAN.md."
