# Guía posterior a la instalación de Archcraft

Esta guía acompaña a `archcraft_postinstall.sh`. **El instalador no instala ni configura i3** y no modifica `~/.config/i3`, `~/.config/i3blocks` ni `~/.xinitrc`. Tampoco desinstala paquetes o elimina configuraciones que ya tengas en el equipo.

## 1. Ejecutar el script

Desde la carpeta `PostInstalation/`:

```bash
bash archcraft_postinstall.sh
```

No lo ejecutes con `sudo`: solicita privilegios solo para `pacman`. Necesitas Arch Linux/Archcraft y conexión a internet. Si no tienes `yay`, consulta la sección 6.

El instalador actualiza el sistema e instala en una operación de `pacman`: `base-devel`, `git`, `xdg-desktop-portal-kde`, `debugedit`, `telegram-desktop`, `vlc`, `vlc-plugin-ffmpeg`, `qbittorrent`, `nvm`, `rustup`, `filezilla`, `go`, `anki`, `obsidian`, `neovim`, `zathura`, `zathura-pdf-mupdf`, `zathura-djvu`, `zathura-ps`, `zathura-cb`, `calc`, `tree`, `mpv`, `gcc`, `fzf`, `ripgrep`, `fd` y `flameshot`. Flameshot se conserva como aplicación independiente para las capturas y su configuración X11, no como dependencia de i3. En AUR instala `brave-bin` y `tree-sitter-cli` con un único comando de `yay`.

Antes de escribir configuraciones, ejecuta `prepare_config_paths.sh`, que crea los archivos faltantes y respalda los existentes. Puedes ejecutarlo solo con `bash prepare_config_paths.sh`; no instala paquetes. El instalador **reemplaza** únicamente `~/.config/xdg-desktop-portal/portals.conf` y `~/.config/flameshot/flameshot.ini`. No reemplaza una configuración de Neovim que ya contenga archivos.

## 2. Reiniciar la sesión gráfica

Para activar el selector de archivos KDE, cierra sesión y vuelve a entrar. La configuración se guarda en `~/.config/xdg-desktop-portal/portals.conf`. También puedes probar:

```bash
systemctl --user restart xdg-desktop-portal.service
```

Reinicia las aplicaciones abiertas antes de volver a probar el selector.

## 3. Terminar la instalación de LazyVim

Abre Neovim y deja que descargue sus plugins:

```bash
nvim
```

Si ya existía contenido en `~/.config/nvim`, el script no lo reemplaza. Si prefieres instalar el starter de LazyVim, respalda o mueve antes tu configuración actual.

## 4. Configurar Node.js y Rust

El script carga `/usr/share/nvm/init-nvm.sh`, instala la LTS de Node.js, la establece como predeterminada y ejecuta `nvm use node` dentro del instalador. Para usar `nvm` en nuevas terminales, añade a tu archivo de inicio de shell (por ejemplo, `~/.bashrc`):

```bash
source /usr/share/nvm/init-nvm.sh
```

Abre una terminal nueva y comprueba `node --version` y `npm --version`. `rustup` instala el gestor, pero si quieres Rust debes ejecutar `rustup default stable`.

## 5. Configurar Brave manualmente

Activa el modo oscuro desde la configuración de Brave. Instala solo las extensiones que necesites:

- OneTab
- Google Translate
- Dark Reader
- YouFocus
- Volume Master
- Web Activity
- Days Until
- Automa
- ChatGPT Bulk Delete
- GoFullPage
- Save Image as Type

Revisa permisos y reputación antes de instalarlas.

## 6. Si `yay` no estaba instalado

El script omitirá AUR y mostrará una advertencia. Una vez instalado `yay`, ejecuta:

```bash
yay -S --needed brave-bin tree-sitter-cli
```

Brave se instala como `brave-bin` desde AUR, en vez de ejecutar `curl | sh`; no instales ambas variantes.

## 7. Recuperación ante errores de firmas o llaves

Usa estos comandos solo si `pacman` muestra errores de firmas o un keyring desactualizado:

```bash
sudo pacman -Sy --needed archlinux-keyring
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syu
```

No uses `pacman -Sy` de forma aislada para instalar paquetes normales: puede producir una actualización parcial.

## 8. Respaldos y comprobaciones

El preparador guarda copias de los dos archivos de configuración existentes con un sufijo como `.bak-20260713-103000`. Revísalas antes de borrarlas.

Comprueba los componentes instalados:

```bash
flameshot --version
nvim --version
zathura --version
node --version
```

Prueba también el selector de archivos desde Brave y Obsidian, y una captura con Flameshot.
