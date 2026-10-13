#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo 'Ejecuta este script con tu usuario normal, no con sudo.' >&2
  exit 1
fi

sudo pacman -Syu --needed -- \
  base-devel git \
  libx11 libxinerama libxft \
  xorg-server xorg-xinit xorg-xsetroot xorg-xrdb \
  alacritty rofi feh flameshot brightnessctl wireplumber \
  ttf-dejavu

mkdir -p "$HOME/src"
if [[ ! -d "$HOME/src/dwm/.git" ]]; then
  if [[ -e "$HOME/src/dwm" ]]; then
    echo "Ya existe $HOME/src/dwm, pero no es un repositorio Git. Revisa esa carpeta." >&2
    exit 1
  fi
  git clone https://git.suckless.org/dwm "$HOME/src/dwm"
fi

# Evita incompatibilidades con cambios futuros en el codigo de dwm.
if git -C "$HOME/src/dwm" rev-parse -q --verify 'refs/tags/6.8' >/dev/null; then
  echo 'Etiqueta dwm 6.8 disponible.'
else
  git -C "$HOME/src/dwm" fetch --tags origin
fi

echo 'Dependencias instaladas y repositorio disponible. Ejecuta 02-configurar.sh.'
