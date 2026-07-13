#!/usr/bin/env bash

set -Eeuo pipefail

readonly SCRIPT_NAME="${0##*/}"
readonly TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

readonly PORTAL_DIR="$HOME/.config/xdg-desktop-portal"
readonly I3_DIR="$HOME/.config/i3"
readonly I3BLOCKS_DIR="$HOME/.config/i3blocks"
readonly FLAMESHOT_DIR="$HOME/.config/flameshot"
readonly WALLPAPER_DIR="$HOME/Pictures/wallpapers"

readonly PORTAL_CONFIG="$PORTAL_DIR/portals.conf"
readonly I3_CONFIG="$I3_DIR/config"
readonly I3BLOCKS_CONFIG="$I3BLOCKS_DIR/config"
readonly I3BLOCKS_VOLUME="$I3BLOCKS_DIR/volume"
readonly I3BLOCKS_BRIGHTNESS="$I3BLOCKS_DIR/brightness"
readonly FLAMESHOT_CONFIG="$FLAMESHOT_DIR/flameshot.ini"
readonly XINITRC="$HOME/.xinitrc"
readonly WALLPAPER_SOURCE="/usr/share/backgrounds/manhattan.jpg"
readonly WALLPAPER_TARGET="$WALLPAPER_DIR/manhattan.jpg"

PACMAN_PACKAGES=(
  base-devel
  git
  xdg-desktop-portal-kde
  telegram-desktop
  obsidian
  neovim
  zathura
  zathura-pdf-mupdf
  calc
  tree
  mpv
  tree-sitter-cli
  fzf
  ripgrep
  fd
  i3-wm
  alacritty
  rofi
  flameshot
  feh
  brightnessctl
  xorg-server
  xorg-xinit
  xorg-xrandr
  ttf-dejavu
  wireplumber
  i3blocks
)

AUR_PACKAGES=(
  brave-bin
)

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

prepare_file() {
  local path="$1"
  local parent

  parent="$(dirname "$path")"
  mkdir -p "$parent"

  if [[ -e "$path" ]]; then
    cp -a -- "$path" "${path}.bak-${TIMESTAMP}"
  else
    touch "$path"
  fi
}

require_normal_user() {
  if ((EUID == 0)); then
    die "No ejecutes este script como root. Ejecútalo con tu usuario normal; el script usará sudo cuando sea necesario."
  fi
}

require_arch_system() {
  command -v pacman >/dev/null 2>&1 ||
    die "No se encontró pacman. Este script está diseñado para Arch Linux/Archcraft."
}

install_pacman_packages() {
  info "Actualizando el sistema e instalando todos los paquetes oficiales"
  sudo pacman -Syu --needed --noconfirm "${PACMAN_PACKAGES[@]}"
}

install_aur_packages() {
  if ! command -v yay >/dev/null 2>&1; then
    warn "No se encontró yay. Se omitirá la instalación AUR: ${AUR_PACKAGES[*]}"
    warn "Instala yay y luego ejecuta: yay -S --needed ${AUR_PACKAGES[*]}"
    return 0
  fi

  info "Instalando todos los paquetes de AUR en un solo comando"
  yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
}

prepare_configuration_paths() {
  info "Creando carpetas y archivos de configuración antes de escribirlos"

  mkdir -p \
    "$PORTAL_DIR" \
    "$I3_DIR" \
    "$I3BLOCKS_DIR" \
    "$FLAMESHOT_DIR" \
    "$WALLPAPER_DIR"

  prepare_file "$PORTAL_CONFIG"
  prepare_file "$I3_CONFIG"
  prepare_file "$I3BLOCKS_CONFIG"
  prepare_file "$I3BLOCKS_VOLUME"
  prepare_file "$I3BLOCKS_BRIGHTNESS"
  prepare_file "$FLAMESHOT_CONFIG"
  prepare_file "$XINITRC"
}

write_portal_config() {
  info "Configurando KDE como backend del selector de archivos"

  cat >"$PORTAL_CONFIG" <<'EOF'
[preferred]
default=kde
org.freedesktop.impl.portal.FileChooser=kde
EOF
}

write_i3_config() {
  info "Escribiendo la configuración de i3"

  cat >"$I3_CONFIG" <<'EOF'
# =========================
# Configuración básica de i3
# =========================

set $mod Mod4
font pango:DejaVu Sans 10

# Quitar la barra de título de las ventanas
default_border pixel 2
default_floating_border pixel 1

# Terminal predeterminada
set $term alacritty

# Colores
client.focused          #4c7899 #285577 #ffffff #2e9ef4 #285577
client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
client.unfocused        #333333 #222222 #888888 #292d2e #222222
client.urgent           #2f343a #900000 #ffffff #900000 #900000

# =========================
# Inicio automático
# =========================

exec_always --no-startup-id feh --bg-scale ~/Pictures/wallpapers/manhattan.jpg
exec --no-startup-id flameshot

# =========================
# Programas principales
# =========================

bindsym $mod+Return exec $term
bindsym $mod+d exec rofi -show drun
bindsym $mod+r exec rofi -show run
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m '¿Salir de i3?' -B 'Sí, salir' 'i3-msg exit'"
bindsym $mod+Tab workspace back_and_forth

# =========================
# Capturas con Flameshot
# =========================

bindsym Print exec flameshot gui
bindsym $mod+Print exec flameshot gui
bindsym Shift+Print exec flameshot full -c

# =========================
# Brillo con brightnessctl
# =========================

bindsym XF86MonBrightnessUp exec --no-startup-id "sh -c 'brightnessctl set +5%; pkill -RTMIN+10 i3blocks 2>/dev/null || true'"
bindsym XF86MonBrightnessDown exec --no-startup-id "sh -c 'brightnessctl set 5%-; pkill -RTMIN+10 i3blocks 2>/dev/null || true'"
bindsym Shift+XF86AudioRaiseVolume exec --no-startup-id "sh -c 'brightnessctl set +5%; pkill -RTMIN+10 i3blocks 2>/dev/null || true'"
bindsym Shift+XF86AudioLowerVolume exec --no-startup-id "sh -c 'brightnessctl set 5%-; pkill -RTMIN+10 i3blocks 2>/dev/null || true'"

# =========================
# Movimiento entre ventanas
# =========================

bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

# =========================
# Diseños
# =========================

bindsym $mod+b split h
bindsym $mod+v split v
bindsym $mod+f fullscreen toggle

bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

bindsym $mod+Shift+space floating toggle
bindsym $mod+space focus mode_toggle

# =========================
# Espacios de trabajo
# =========================

set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"

bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
bindsym $mod+4 workspace number $ws4
bindsym $mod+5 workspace number $ws5
bindsym $mod+6 workspace number $ws6
bindsym $mod+7 workspace number $ws7
bindsym $mod+8 workspace number $ws8
bindsym $mod+9 workspace number $ws9
bindsym $mod+0 workspace number $ws10

bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5
bindsym $mod+Shift+6 move container to workspace number $ws6
bindsym $mod+Shift+7 move container to workspace number $ws7
bindsym $mod+Shift+8 move container to workspace number $ws8
bindsym $mod+Shift+9 move container to workspace number $ws9
bindsym $mod+Shift+0 move container to workspace number $ws10

# =========================
# Redimensionar ventanas
# =========================

mode "resize" {
    bindsym h resize shrink width 10 px or 10 ppt
    bindsym j resize grow height 10 px or 10 ppt
    bindsym k resize shrink height 10 px or 10 ppt
    bindsym l resize grow width 10 px or 10 ppt

    bindsym Left resize shrink width 10 px or 10 ppt
    bindsym Down resize grow height 10 px or 10 ppt
    bindsym Up resize shrink height 10 px or 10 ppt
    bindsym Right resize grow width 10 px or 10 ppt

    bindsym Return mode "default"
    bindsym Escape mode "default"
}

bindsym $mod+Shift+minus mode "resize"

# =========================
# Volumen con wpctl
# =========================

# El límite 1.0 impide superar el 100 %.
bindsym XF86AudioRaiseVolume exec --no-startup-id "sh -c 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.0; pkill -RTMIN+11 i3blocks 2>/dev/null || true'"
bindsym XF86AudioLowerVolume exec --no-startup-id "sh -c 'wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; pkill -RTMIN+11 i3blocks 2>/dev/null || true'"
bindsym XF86AudioMute exec --no-startup-id "sh -c 'wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; pkill -RTMIN+11 i3blocks 2>/dev/null || true'"
bindsym XF86AudioMicMute exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

# =========================
# Barra inferior
# =========================

bar {
    status_command i3blocks -c ~/.config/i3blocks/config

    tray_output primary
    tray_padding 0

    workspace_buttons yes
    binding_mode_indicator no

    font pango:DejaVu Sans Mono 10
}
EOF
}

write_i3blocks_config() {
  info "Escribiendo la configuración y los scripts de i3blocks"

  cat >"$I3BLOCKS_CONFIG" <<'EOF'
# Brillo
[brightness]
command=~/.config/i3blocks/brightness
interval=10
signal=10

# Volumen
[volume]
command=~/.config/i3blocks/volume
interval=once
signal=11

# Fecha y hora
[datetime]
command=date '+%a %d/%m %H:%M'
interval=60
EOF

  cat >"$I3BLOCKS_VOLUME" <<'EOF'
#!/bin/sh

VOLUME_OUTPUT=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || {
    echo "VOL N/A"
    exit 0
}

if printf '%s\n' "$VOLUME_OUTPUT" | grep -q MUTED; then
    echo "VOL muted"
else
    VOLUME=$(printf '%s\n' "$VOLUME_OUTPUT" | awk '{printf "%d%%", $2 * 100}')
    echo "VOL $VOLUME"
fi
EOF

  cat >"$I3BLOCKS_BRIGHTNESS" <<'EOF'
#!/bin/sh

BACKLIGHT_DIR=$(find /sys/class/backlight -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -n 1)

if [ -z "$BACKLIGHT_DIR" ]; then
    echo "BRI N/A"
    exit 0
fi

CURRENT=$(cat "$BACKLIGHT_DIR/brightness")
MAX=$(cat "$BACKLIGHT_DIR/max_brightness")

if [ "$MAX" -le 0 ]; then
    echo "BRI N/A"
    exit 0
fi

PERCENT=$((CURRENT * 100 / MAX))
echo "BRI ${PERCENT}%"
EOF

  chmod +x "$I3BLOCKS_VOLUME" "$I3BLOCKS_BRIGHTNESS"
}

write_flameshot_config() {
  info "Configurando Flameshot para usar capturas X11"

  cat >"$FLAMESHOT_CONFIG" <<'EOF'
[General]
useX11LegacyScreenshot=true
EOF
}

write_xinitrc() {
  info "Configurando ~/.xinitrc"

  cat >"$XINITRC" <<'EOF'
#!/bin/sh
exec i3
EOF

  chmod +x "$XINITRC"
}

copy_wallpaper() {
  info "Preparando el fondo de pantalla"

  if [[ -f "$WALLPAPER_SOURCE" ]]; then
    install -m 0644 "$WALLPAPER_SOURCE" "$WALLPAPER_TARGET"
  elif [[ -f "$WALLPAPER_TARGET" ]]; then
    warn "No existe $WALLPAPER_SOURCE, pero ya hay un fondo en $WALLPAPER_TARGET."
  else
    warn "No existe $WALLPAPER_SOURCE. Copia manualmente una imagen a $WALLPAPER_TARGET."
  fi
}

install_lazyvim() {
  info "Instalando el starter de LazyVim"

  if [[ -f "$HOME/.config/nvim/init.lua" ]]; then
    warn "Ya existe una configuración de Neovim en ~/.config/nvim; no será reemplazada."
    return 0
  fi

  rm -rf "$HOME/.config/nvim"
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
2. Comprueba que exista:
   $WALLPAPER_TARGET
3. Abre Neovim una vez para que LazyVim descargue sus plugins:
   nvim
4. Completa los pasos manuales de POST_INSTALACION.md.

Las configuraciones anteriores, cuando existían, quedaron respaldadas
con el sufijo:
   .bak-$TIMESTAMP
EOF
}

main() {
  require_normal_user
  require_arch_system

  info "Solicitando credenciales de sudo"
  sudo -v

  install_pacman_packages
  install_aur_packages
  prepare_configuration_paths
  write_portal_config
  write_i3_config
  write_i3blocks_config
  write_flameshot_config
  write_xinitrc
  copy_wallpaper
  install_lazyvim
  print_summary
}

main "$@"
