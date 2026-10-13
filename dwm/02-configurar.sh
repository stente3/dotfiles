#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -eq 0 ]]; then
  echo 'Ejecuta este script con tu usuario normal, no con sudo.' >&2
  exit 1
fi

DWM_DIR="$HOME/src/dwm"
if [[ ! -d "$DWM_DIR/.git" ]]; then
  echo "No existe $DWM_DIR. Ejecuta primero 01-instalar.sh." >&2
  exit 1
fi

for prog in make cc rofi feh flameshot wpctl brightnessctl xsetroot; do
  if ! command -v "$prog" >/dev/null 2>&1; then
    echo "Falta $prog. Ejecuta primero 01-instalar.sh." >&2
    exit 1
  fi
done

# Comprobar que no se sobreescriban modificaciones de codigo de dwm.
if [[ -n "$(git -C "$DWM_DIR" status --porcelain --untracked-files=no)" ]]; then
  echo 'Hay cambios en archivos rastreados de dwm; no se cambiará su versión.' >&2
  echo 'Haz copia de esos cambios antes de volver a ejecutar este script.' >&2
  exit 1
fi
if ! git -C "$DWM_DIR" rev-parse -q --verify 'refs/tags/6.8' >/dev/null; then
  echo 'No se encontro la etiqueta 6.8 de dwm. Ejecuta 01-instalar.sh nuevamente.' >&2
  exit 1
fi
# Si dwm ya se instalo desde el repositorio, configurar sobre la version 6.8.
git -C "$DWM_DIR" checkout --detach 6.8

backup_if_exists() {
  local path="$1"
  if [[ -e "$path" ]]; then
    cp -a -- "$path" "$path.bak.$(date +%Y%m%d-%H%M%S)"
  fi
}

backup_if_exists "$DWM_DIR/config.h"
cat >"$DWM_DIR/config.h" <<'CONFIG_H'
/* dwm 6.8 sin parches: configuracion parecida a i3 */
/* Configuracion dwm similar a i3 - compatible con dwm sin parches */
#include <X11/XF86keysym.h>

/* Apariencia */
static const unsigned int borderpx = 2;
static const unsigned int snap = 32;
static const int showbar = 1;
static const int topbar = 0;
static const char *fonts[] = { "DejaVu Sans Mono:size=10" };
static const char dmenufont[] = "DejaVu Sans:size=10";
static const char col_gray1[] = "#222222";
static const char col_gray2[] = "#333333";
static const char col_gray3[] = "#888888";
static const char col_white[] = "#ffffff";
static const char col_blue[]  = "#285577";
static const char *colors[][3] = {
    /*                  texto       fondo       borde */
    [SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
    [SchemeSel]  = { col_white, col_blue,  "#4c7899" },
};

/* Etiquetas o escritorios */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" };
static const Rule rules[] = {
    { NULL, NULL, NULL, 0, 0, -1 },
};

/* Layouts */
static const float mfact = 0.55;
static const int nmaster = 1;
static const int resizehints = 0;
static const int lockfullscreen = 1;
static const int refreshrate = 120;
static const Layout layouts[] = {
    { "[]=", tile },
    { "><>", NULL },
    { "[M]", monocle },
};

#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
    { MODKEY,                       KEY, view,       {.ui = 1U << TAG} }, \
    { MODKEY|ControlMask,           KEY, toggleview, {.ui = 1U << TAG} }, \
    { MODKEY|ShiftMask,             KEY, tag,        {.ui = 1U << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY, toggletag,  {.ui = 1U << TAG} },
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

static const char *termcmd[] = { "alacritty", NULL };
static const char *rofidruncmd[] = { "rofi", "-show", "drun", NULL };
static const char *rofiruncmd[] = { "rofi", "-show", "run", NULL };
static const char *flamegui[] = { "flameshot", "gui", NULL };
static const char *flamefull[] = { "flameshot", "full", "-c", NULL };

static char dmenumon[2] = "0";

static const char *dmenucmd[] = {
    "rofi", "-show", "drun", NULL
};

static const Key keys[] = {
    /* Aplicaciones */
    { MODKEY,             XK_Return,        spawn,          {.v = termcmd} },
    { MODKEY,             XK_d,             spawn,          {.v = rofidruncmd} },
    { MODKEY,             XK_r,             spawn,          {.v = rofiruncmd} },
    { MODKEY|ShiftMask,   XK_q,             killclient,     {0} },
    { MODKEY|ShiftMask,   XK_e,             spawn,          SHCMD("printf 'No\\nSi, salir\\n' | rofi -dmenu -p 'Salir de dwm?' | grep -qx 'Si, salir' && pkill -x dwm") },

    /* Volver al escritorio anterior: dwm nativo */
    { MODKEY,             XK_Tab,           view,           {0} },

    /* Capturas */
    { 0,                  XK_Print,         spawn,          {.v = flamegui} },
    { MODKEY,             XK_Print,         spawn,          {.v = flamegui} },
    { ShiftMask,          XK_Print,         spawn,          {.v = flamefull} },

    /* Brillo */
    { MODKEY|ShiftMask,   XK_bracketright,  spawn,          SHCMD("brightnessctl set +5%") },
    { MODKEY|ShiftMask,   XK_bracketleft,   spawn,          SHCMD("brightnessctl set 5%-") },
    { 0,                  XF86XK_MonBrightnessUp,   spawn,   SHCMD("brightnessctl set +5%") },
    { 0,                  XF86XK_MonBrightnessDown, spawn,   SHCMD("brightnessctl set 5%-") },

    /* Volumen */
    { MODKEY,             XK_bracketright,  spawn,          SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") },
    { MODKEY,             XK_bracketleft,   spawn,          SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") },
    { 0,                  XF86XK_AudioRaiseVolume, spawn,   SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") },
    { 0,                  XF86XK_AudioLowerVolume, spawn,   SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") },
    { 0,                  XF86XK_AudioMute,        spawn,   SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle") },
    { 0,                  XF86XK_AudioMicMute,     spawn,   SHCMD("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle") },

    /* En dwm sin parches, foco anterior/siguiente, no direccional */
    { MODKEY,             XK_j,             focusstack,     {.i = +1} },
    { MODKEY,             XK_k,             focusstack,     {.i = -1} },
    { MODKEY,             XK_Down,          focusstack,     {.i = +1} },
    { MODKEY,             XK_Up,            focusstack,     {.i = -1} },
    { MODKEY,             XK_h,             focusstack,     {.i = -1} },
    { MODKEY,             XK_l,             focusstack,     {.i = +1} },
    { MODKEY,             XK_Left,          focusstack,     {.i = -1} },
    { MODKEY,             XK_Right,         focusstack,     {.i = +1} },

    /* Layouts: tile, flotante, monocle */
    { MODKEY,             XK_b,             setlayout,      {.v = &layouts[0]} },
    { MODKEY,             XK_v,             setlayout,      {.v = &layouts[1]} },
    { MODKEY,             XK_s,             setlayout,      {.v = &layouts[2]} },
    { MODKEY,             XK_w,             setlayout,      {.v = &layouts[2]} },
    { MODKEY,             XK_e,             setlayout,      {0} },
    { MODKEY,             XK_space,         setlayout,      {0} },
    { MODKEY|ShiftMask,   XK_space,         togglefloating, {0} },
    { MODKEY|ShiftMask,   XK_Return,        zoom,           {0} },
    { MODKEY,             XK_i,             incnmaster,     {.i = +1} },
    { MODKEY|ShiftMask,   XK_i,             incnmaster,     {.i = -1} },

    /* Redimension de la zona principal del mosaico */
    { MODKEY|ShiftMask,   XK_h,             setmfact,       {.f = -0.05} },
    { MODKEY|ShiftMask,   XK_l,             setmfact,       {.f = +0.05} },
    { MODKEY|ShiftMask,   XK_Left,          setmfact,       {.f = -0.05} },
    { MODKEY|ShiftMask,   XK_Right,         setmfact,       {.f = +0.05} },
    { MODKEY|ShiftMask,   XK_b,             togglebar,      {0} },

    /* Prueba de volumen */
    { MODKEY, XK_F7, spawn, SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-") },
    { MODKEY, XK_F8, spawn, SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+") },

    /* Prueba de brillo */
    { MODKEY, XK_F9,  spawn, SHCMD("brightnessctl set 5%-") },
    { MODKEY, XK_F10, spawn, SHCMD("brightnessctl set +5%") },

    /* Diez escritorios */
    TAGKEYS(XK_1, 0)
    TAGKEYS(XK_2, 1)
    TAGKEYS(XK_3, 2)
    TAGKEYS(XK_4, 3)
    TAGKEYS(XK_5, 4)
    TAGKEYS(XK_6, 5)
    TAGKEYS(XK_7, 6)
    TAGKEYS(XK_8, 7)
    TAGKEYS(XK_9, 8)
    TAGKEYS(XK_0, 9)
};

static const Button buttons[] = {
    /* click          modifiers button   function         argument */
    { ClkLtSymbol,    0,        Button1, setlayout,        {0} },
    { ClkLtSymbol,    0,        Button3, setlayout,        {.v = &layouts[2]} },
    { ClkWinTitle,    0,        Button2, zoom,             {0} },
    { ClkStatusText,  0,        Button2, spawn,            {.v = termcmd} },
    { ClkClientWin,   MODKEY,   Button1, movemouse,        {0} },
    { ClkClientWin,   MODKEY,   Button2, togglefloating,   {0} },
    { ClkClientWin,   MODKEY,   Button3, resizemouse,      {0} },
    { ClkTagBar,      0,        Button1, view,             {0} },
    { ClkTagBar,      0,        Button3, toggleview,       {0} },
    { ClkTagBar,      MODKEY,   Button1, tag,              {0} },
    { ClkTagBar,      MODKEY,   Button3, toggletag,        {0} },
};
CONFIG_H

make -C "$DWM_DIR" clean
make -C "$DWM_DIR"
sudo make -C "$DWM_DIR" install

# Script de arranque utilizable tanto desde el login grafico como con startx.
mkdir -p "$HOME/.local/bin"
START_SCRIPT="$HOME/.local/bin/dwm-start"
backup_if_exists "$START_SCRIPT"
cat >"$START_SCRIPT" <<'START'
#!/bin/sh
# Solo iniciar las utilidades si no estaban ya activas.
if [ -f "$HOME/.Xresources" ] && command -v xrdb >/dev/null 2>&1; then
    xrdb -merge "$HOME/.Xresources"
fi
if [ -f "$HOME/Pictures/wallpapers/manhattan.jpg" ]; then
    feh --bg-scale "$HOME/Pictures/wallpapers/manhattan.jpg" &
fi
pgrep -u "$(id -u)" -x flameshot >/dev/null 2>&1 || flameshot &
(
    while :; do
        xsetroot -name "$(date '+%d/%m/%Y %H:%M')"
        sleep 30
    done
) &
CLOCK_PID=$!
trap 'kill "$CLOCK_PID" 2>/dev/null || true' EXIT
/usr/local/bin/dwm
START
chmod +x "$START_SCRIPT"

# Crear sesion X11 para LightDM, SDDM o gestores compatibles.
SESSION_FILE=/usr/share/xsessions/dwm.desktop
if sudo test -e "$SESSION_FILE"; then
  sudo cp -a "$SESSION_FILE" "$SESSION_FILE.bak.$(date +%Y%m%d-%H%M%S)"
fi
sudo install -d -m 755 /usr/share/xsessions
# Una ruta fija global sirve para cualquier usuario, pero el contenido
# del script es la configuracion de la cuenta actual.
sudo tee /usr/local/bin/dwm-start >/dev/null <<EOF_START_GLOBAL
#!/bin/sh
exec "$START_SCRIPT"
EOF_START_GLOBAL
sudo chmod 755 /usr/local/bin/dwm-start
sudo tee "$SESSION_FILE" >/dev/null <<'SESSION'
[Desktop Entry]
Name=dwm
Comment=Dynamic window manager (X11)
Exec=/usr/local/bin/dwm-start
TryExec=/usr/local/bin/dwm
Type=Application
DesktopNames=dwm
SESSION

# Permite iniciar dwm con startx desde un TTY.
backup_if_exists "$HOME/.xinitrc"
cat >"$HOME/.xinitrc" <<'XINIT'
#!/bin/sh
exec "$HOME/.local/bin/dwm-start"
XINIT
chmod +x "$HOME/.xinitrc"

echo 'Configuracion terminada. Cierra sesion y elige dwm (X11), o usa startx desde una TTY.'
echo 'No se modifica ni se desinstala i3.'
