#!/bin/bash

# Este script debe ejecutarse como usuario normal
if [ "$(whoami)" == "root" ]; then
    echo "❌ No ejecutes este script como root. Usa un usuario normal."
    exit 1
fi

ruta=$(pwd)

echo "🔧 Instalando dependencias del entorno..."
sudo apt update && sudo apt install -y \
  build-essential git vim cmake cmake-data pkg-config \
  python3-sphinx python3-xcbgen xcb-proto \
  libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev \
  libuv1-dev libnl-genl-3-dev libx11-xcb-dev libxcb1-dev \
  libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev \
  libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev \
  libxcb-composite0-dev libxcb-image0-dev libxcb-xrm-dev \
  libxcb-xkb-dev libxcb-cursor-dev libxcb-xtest0-dev \
  libxcb-shape0-dev libxcb-present-dev libxcb-glx0-dev \
  libxcb-render0-dev libxcb-render-util0-dev \
  libconfig-dev libdbus-1-dev libegl-dev libev-dev \
  libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev \
  meson ninja-build uthash-dev

echo "📦 Instalando utilidades adicionales..."
sudo apt install -y kitty feh scrot scrub rofi xclip bat locate ranger neofetch wmname acpi bspwm sxhkd imagemagick cmatrix zsh

echo "📁 Creando carpeta de repositorios..."
mkdir -p ~/github
cd ~/github

echo "🐧 Clonando BSPWM y SXHKD..."
git clone https://github.com/baskerville/bspwm.git
git clone https://github.com/baskerville/sxhkd.git

echo "🧰 Instalando BSPWM..."
cd bspwm
make
sudo make install

echo "🧰 Instalando SXHKD..."
cd ../sxhkd
make
sudo make install

echo "📁 Creando carpetas de configuración..."
mkdir -p ~/.config/{bspwm,sxhkd}

echo "📋 Copiando archivos de configuración..."
cp -p "$ruta/Config/bspwm/bspwmrc" ~/.config/bspwm/
cp -p "$ruta/Config/sxhkd/sxhkdrc" ~/.config/sxhkd/
cp -r "$ruta/Config/bspwm/scripts" ~/.config/bspwm/

echo "🐱 Instalando versión actualizada de kitty..."
cd /opt
sudo rm -rf kitty
sudo mkdir kitty
sudo mv "$ruta/kitty/kitty-0.35.2-x86_64.txz" /opt/
sudo 7z x kitty-0.35.2-x86_64.txz -okit
sudo tar -xf kitty-0.35.2-x86_64.tar -C kitty
sudo rm kitty-0.35.2-x86_64.txz kitty-0.35.2-x86_64.tar

echo "🎨 Configurando kitty..."
mkdir -p ~/.config/kitty
cp -p "$ruta/Config/kitty/color.ini" ~/.config/kitty/
cp -p "$ruta/Config/kitty/kitty.conf" ~/.config/kitty/
sudo cp -r "$ruta/Config/kitty" /root/.config/

echo "🎮 Configurando fondo de pantalla..."
cp -r "$ruta/fondo" ~/fondo
feh --bg-fill ~/fondo/yuji-itadori-1920x1080-9268-222611746.jpg

echo "📦 Instalando y configurando polybar..."
git clone https://github.com/VaughnValle/blue-sky.git ~/github/blue-sky
cp -r ~/github/blue-sky/polybar/* ~/.config/polybar
sudo cp ~/github/blue-sky/fonts/* /usr/share/fonts/truetype/
sudo fc-cache -v

cp "$ruta/Config/polibar/launch.sh" ~/.config/polybar/
cp "$ruta/Config/polibar/current.ini" ~/.config/polybar/
cp "$ruta/Config/polibar/workspace.ini" ~/.config/polybar/

echo "💨 Instalando y configurando picom..."
cd ~/github
git clone https://github.com/yshui/picom
cd picom
meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install
cp -r "$ruta/Config/picom" ~/.config/

echo "⚙️ Configurando ZSH..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc
cp -v "$ruta/.p10k.zsh" ~/
cp -v "$ruta/.zshrc" ~/.zshrc
sudo apt install -y zsh-autocomplete zsh-autosuggestions zsh-syntax-highlighting
sudo usermod --shell /usr/bin/zsh root
sudo usermod --shell /usr/bin/zsh "$USER"

echo "🔧 Corrigiendo permisos..."
sudo chown root:root /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
sudo chown root:root /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

echo "📁 Copiando scripts BSPWM..."
cp -v "$ruta/scrips/"*.sh ~/.config/bspwm/scripts/
chmod +x ~/.config/bspwm/scripts/*.sh

echo "🔍 Instalando fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all

echo "🔧 Instalando Neovim personalizado..."
sudo apt remove -y nvim neovim
git clone https://github.com/NvChad/starter ~/.config/nvim
sudo mkdir -p /opt/nvim
sudo cp "$ruta/nvim-linux64.tar.gz" /opt/nvim
cd /opt/nvim
sudo tar -xf nvim-linux64.tar.gz
sudo rm nvim-linux64.tar.gz
cp "$ruta/nvimfile/init.lua" ~/.config/nvim/

echo "🔍 Actualizando base de datos 'locate'..."
sudo updatedb

echo "🎨 Instalando temas de rofi..."
mkdir -p ~/.config/rofi/themes
sudo git clone https://github.com/newmanls/rofi-themes-collection.git /opt/rofi-themes-collection
sudo cp /opt/rofi-themes-collection/themes/* ~/.config/rofi/themes/

echo "🔐 Instalando i3lock-fancy..."
sudo apt install -y i3lock imagemagick
cd /opt
sudo git clone https://github.com/meskarune/i3lock-fancy.git
cd i3lock-fancy
sudo make install

echo "✅ Instalación completada. Reinicia el sistema o cierra sesión para aplicar cambios."

