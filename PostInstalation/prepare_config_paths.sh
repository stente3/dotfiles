#!/usr/bin/env bash
# Preparar archivos antes de que archcraft_postinstall.sh escriba la configuración.
set -Eeuo pipefail

stamp="${1:-$(date +%Y%m%d-%H%M%S)}"
[[ "$stamp" =~ ^[0-9]{8}-[0-9]{6}$ ]] || {
  printf 'Marca de tiempo inválida: %s\n' "$stamp" >&2
  exit 1
}

prepare_file() {
  local path="$1" backup="${1}.bak-${stamp}"
  mkdir -p -- "$(dirname -- "$path")"
  if [[ -d "$path" ]]; then
    printf 'Se esperaba un archivo, pero hay un directorio: %s\n' "$path" >&2
    exit 1
  fi
  if [[ -e "$path" || -L "$path" ]]; then
    [[ ! -e "$backup" && ! -L "$backup" ]] || {
      printf 'Ya existe el respaldo: %s\n' "$backup" >&2
      exit 1
    }
    cp -a -- "$path" "$backup"
  else
    touch -- "$path"
  fi
}

prepare_file "$HOME/.config/xdg-desktop-portal/portals.conf"
prepare_file "$HOME/.config/flameshot/flameshot.ini"
