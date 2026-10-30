#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
readonly PORTAL_CONFIG="$HOME/.config/xdg-desktop-portal/portals.conf"
readonly FLAMESHOT_CONFIG="$HOME/.config/flameshot/flameshot.ini"

PACMAN_PACKAGES=(
  base-devel git xdg-desktop-portal-kde debugedit
  telegram-desktop vlc vlc-plugin-ffmpeg qbittorrent
  nvm rustup filezilla go anki obsidian neovim
  zathura zathura-pdf-mupdf zathura-djvu zathura-ps zathura-cb
  calc tree mpv gcc fzf ripgrep fd
  flameshot
)

AUR_PACKAGES=(brave-bin tree-sitter-cli)

info() {
  printf '\n\033[1;34m==>\033[0m %s\n' "$*"
}

warn() {
  printf '\n\033[1;33mADVERTENCIA:\033[0m %s\n' "$*" >&2
}

die() {
  printf '\n\033[1;31mERROR:\033[0m %s\n' "$*" >&2
  exit 1
}

on_error() {
  local exit_code=$?
  printf '\n\033[1;31mERROR:\033[0m %s falló en la línea %s (código %s).\n' \
    "$SCRIPT_NAME" "${BASH_LINENO[0]:-desconocida}" "$exit_code" >&2
  exit "$exit_code"
}

trap on_error ERR

install_pacman_packages() {
  info "Actualizando el sistema e instalando los paquetes oficiales"
  sudo pacman -Syu --needed --noconfirm "${PACMAN_PACKAGES[@]}"
}

install_aur_packages() {
  if ! command -v yay >/dev/null 2>&1; then
    warn "No se encontró yay. Se omitirá la instalación AUR: ${AUR_PACKAGES[*]}"
    warn "Instala yay y luego ejecuta: yay -S --needed ${AUR_PACKAGES[*]}"
    return 0
  fi

  info "Instalando los paquetes AUR en un solo comando"
  yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
}

prepare_configuration_paths() {
  info "Preparando carpetas, archivos y respaldos antes de configurar"
  bash "$SCRIPT_DIR/prepare_config_paths.sh" "$TIMESTAMP"
}

write_portal_config() {
  info "Configurando KDE como backend del selector de archivos"
  cat >"$PORTAL_CONFIG" <<'EOF'
[preferred]
default=kde
org.freedesktop.impl.portal.FileChooser=kde
EOF
}

write_flameshot_config() {
  info "Configurando Flameshot para usar capturas X11"
  cat >"$FLAMESHOT_CONFIG" <<'EOF'
[General]
useX11LegacyScreenshot=true
EOF
}

install_node_lts() {
  info "Instalando Node.js LTS con nvm"
  if [[ ! -f /usr/share/nvm/init-nvm.sh ]]; then
    warn "No se encontró /usr/share/nvm/init-nvm.sh; inicializa nvm e instala la LTS manualmente."
    return 0
  fi

  # nvm se carga en una subshell y algunos scripts de nvm no admiten 'set -u'.
  (
    set +u
    source /usr/share/nvm/init-nvm.sh
    nvm install --lts
    nvm alias default 'lts/*'
    nvm use node
  )
}

install_lazyvim() {
  info "Instalando el starter de LazyVim"
  if [[ -d "$HOME/.config/nvim" ]] && [[ -n "$(ls -A "$HOME/.config/nvim")" ]]; then
    warn "Ya existe contenido en ~/.config/nvim; no será reemplazado."
    return 0
  fi

  rmdir "$HOME/.config/nvim" 2>/dev/null || true
  git clone --depth=1 https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
}

print_summary() {
  cat <<EOF

============================================================
Instalación automatizada terminada.
============================================================

Siguientes pasos:

1. Cierra sesión y vuelve a entrar para recargar los portales.
2. Abre Neovim para que LazyVim descargue sus plugins: nvim
3. Completa los pasos manuales de POST_INSTALACION.md.

Las configuraciones anteriores, cuando existían, quedaron respaldadas
con el sufijo: .bak-$TIMESTAMP
EOF
}

main() {
  if ((EUID == 0)); then
    die "No ejecutes este script como root; usará sudo cuando sea necesario."
  fi
  command -v pacman >/dev/null 2>&1 ||
    die "No se encontró pacman. Este script está diseñado para Arch Linux/Archcraft."

  info "Solicitando credenciales de sudo"
  sudo -v

  install_pacman_packages
  install_aur_packages
  prepare_configuration_paths
  write_portal_config
  write_flameshot_config
  install_lazyvim
  install_node_lts
  print_summary
}

main "$@"
