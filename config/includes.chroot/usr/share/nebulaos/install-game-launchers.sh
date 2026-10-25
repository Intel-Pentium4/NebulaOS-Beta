#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  echo "Ejecuta este programa como usuario normal; pedirá privilegios con sudo cuando haga falta." >&2
  exit 1
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "No encuentro sudo. Inicia sesión con una cuenta administradora y consulta la documentación." >&2
  exit 1
fi

printf '\nNebulaOS: se instalarán herramientas de juego desde repositorios oficiales y Flathub.\n'
printf 'Necesitas conexión a Internet. Revisa las licencias y los cambios antes de continuar.\n\n'
read -r -p '¿Continuar? [s/N] ' answer
case "$answer" in [sS]|[sS][iI]) ;; *) echo "Cancelado."; exit 0 ;; esac

sudo -v
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install --no-install-recommends -y \
  steam-installer lutris wine winetricks gamemode mangohud \
  vulkan-tools mesa-utils flatpak libgl1-mesa-dri:i386

flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
printf '\nSe van a descargar Heroic Games Launcher y Prism Launcher desde Flathub.\n'
flatpak install --user --assumeyes flathub com.heroicgameslauncher.hgl org.prismlauncher.PrismLauncher

cat <<'MSG'

Instalación solicitada completada. Cierra sesión y vuelve a entrar si una herramienta lo necesita.
Si un juego no inicia, consulta la compatibilidad del juego concreto y los registros; no todos los títulos son compatibles con Linux.
MSG
