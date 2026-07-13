# Guía posterior a la instalación de Archcraft

Este documento contiene únicamente las acciones que no conviene automatizar o que requieren una decisión manual.

## 1. Ejecutar el script

Desde la carpeta donde guardaste los archivos:

```bash
chmod +x archcraft_postinstall.sh
./archcraft_postinstall.sh
```

No ejecutes el script con `sudo`. El propio script solicita privilegios únicamente cuando los necesita.

## 2. Reiniciar la sesión gráfica

La configuración del selector de archivos se escribe en:

```text
~/.config/xdg-desktop-portal/portals.conf
```

Después de ejecutar el script, cierra sesión y vuelve a entrar. También puedes intentar reiniciar el portal desde una terminal de tu sesión gráfica:

```bash
systemctl --user restart xdg-desktop-portal.service
```

Si una aplicación ya estaba abierta, ciérrala completamente y vuelve a iniciarla antes de probar el selector de archivos.

## 3. Comprobar el fondo de pantalla

El script intenta copiar:

```text
/usr/share/backgrounds/manhattan.jpg
```

hacia:

```text
~/Pictures/wallpapers/manhattan.jpg
```

Si el archivo original no existe, copia manualmente la imagen que quieras usar con ese nombre:

```bash
cp /ruta/a/tu/imagen.jpg ~/Pictures/wallpapers/manhattan.jpg
```

Después puedes recargar i3 con `Super + Shift + C`.

## 4. Iniciar i3

Si utilizas un gestor de inicio de sesión, selecciona la sesión de i3 desde su menú.

Si inicias X11 manualmente, usa:

```bash
startx
```

El archivo `~/.xinitrc` ya contiene `exec i3`.

## 5. Terminar la instalación de LazyVim

Abre Neovim una vez:

```bash
nvim
```

LazyVim descargará sus plugins durante ese primer inicio. Espera a que termine antes de cerrar Neovim.

El script no reemplaza `~/.config/nvim` cuando ya encuentra un archivo `init.lua`.

## 6. Configurar Brave manualmente

### Apariencia

Activa el modo oscuro desde la configuración de Brave.

### Extensiones

Instala manualmente las extensiones que todavía necesites:

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

Conviene revisar la reputación, los permisos y la fecha de actualización de cada extensión antes de instalarla. El nombre de alguna extensión puede cambiar o pueden existir varias con nombres parecidos.

## 7. Si `yay` no estaba instalado

El script omitirá los paquetes AUR y mostrará una advertencia. Después de instalar `yay`, ejecuta:

```bash
yay -S --needed brave-bin
```

Actualmente `tree-sitter-cli` se instala con `pacman`, porque forma parte del repositorio oficial `Extra`.

## 8. Recuperación ante errores de firmas o llaves

No conviene ejecutar estos comandos en cada instalación. Úsalos únicamente cuando `pacman` muestre errores relacionados con firmas, llaves o un keyring desactualizado:

```bash
sudo pacman -Sy --needed archlinux-keyring
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Syu
```

No uses `pacman -Sy` de manera aislada para instalar paquetes normales, porque puede producir una actualización parcial.

## 9. Respaldos de configuraciones

Cuando el script encuentra una configuración existente, crea una copia con un nombre similar a:

```text
config.bak-20260713-103000
```

Revisa esos respaldos antes de eliminarlos.

## 10. Pruebas rápidas

Comprueba el estado de los componentes principales:

```bash
i3 --moreversion
wpctl status
brightnessctl info
flameshot --version
nvim --version
zathura --version
```

Prueba también:

- Abrir el selector de archivos desde Obsidian y Brave.
- Subir y bajar el volumen.
- Subir y bajar el brillo.
- Realizar una captura con `Print`.
- Recargar i3 con `Super + Shift + C`.
