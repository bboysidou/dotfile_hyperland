#!/usr/bin/env bash
set -euo pipefail

DOWNLOAD_DIR="${HOME}/Downloads"
REPO="https://github.com/sidouxp3/dotfile_hyperland.git"
REPO_DIR="${DOWNLOAD_DIR}/dotfile_hyperland"

_installPackages() {
  sudo pacman -S --noconfirm --needed "$@"
}

_installPackagesAUR() {
  yay -S --noconfirm --needed "$@"
}

_configureDotfiles() {
  cp -rv "$@" "$HOME/.config"
}

source ./core/packages.sh

source ./core/configuration.sh

echo "============================================="
echo "-----| GENERATE HOME DIR |-----"
echo "============================================="

_installPackages "xdg-user-dirs"
xdg-user-dirs-update

echo "============================================="
echo "-----| INSTALL AUR |-----"
echo "============================================="

if command -v yay &>/dev/null; then
  echo "AUR is installed"
else
  cd $DOWNLOAD_DIR
  git clone https://aur.archlinux.org/yay.git && cd yay/ && makepkg -si
fi

echo "============================================="
echo "-----| INSTALL GENERAL PACKAGES |-----"
echo "============================================="
_installPackages "${general[@]}"

echo "============================================="
echo "-----| INSTALL AUDIO PACKAGES |-----"
echo "============================================="
_installPackages "${audio[@]}"

echo "============================================="
echo "-----| INSTALL WINDOW MANAGER PACKAGES |-----"
echo "============================================="
_installPackages "${window_manager[@]}"

echo "============================================="
echo "-----| INSTALL NVIDIA |-----"
echo "============================================="
./nvidia.sh

echo "============================================="
echo "-----| INSTALL AUR PACKAGES |-----"
echo "============================================="
_installPackagesAUR "${aur[@]}"

echo "============================================="
echo "-----| CLONNING DOTFILES |-----"
echo "============================================="

cd "$DOWNLOAD_DIR"
if [[ ! -d "$REPO_DIR" ]]; then
  git clone "$REPO"
fi
cd "$REPO_DIR"

echo "============================================="
echo "-----| CONFIGURE DOTFILES |-----"
echo "============================================="
_configureDotfiles "${folders[@]}"

echo "============================================="
echo "-----| CONFIGURE DOCKER |-----"
echo "============================================="
sudo usermod -aG docker $USER

echo "============================================="
echo "-----| INSTALLING SNAP |-----"
echo "============================================="
if command -v snap &>/dev/null; then
  echo "Snap is installed"
else
  cd "$DOWNLOAD_DIR"
  git clone https://aur.archlinux.org/snapd.git && cd snapd && makepkg -si
  sudo systemctl enable --now snapd.socket
  sudo systemctl enable --now snapd.apparmor.service
  sudo ln -s /var/lib/snapd/snap /snap
  sleep 5
  sudo snap install hello-world
fi

echo "============================================="
echo "-----| CHANGE SHELL TO FISH |-----"
echo "============================================="
if [[ "$SHELL" != "$(command -v fish)" ]]; then
  sudo chsh -s /bin/fish 
  sudo chsh -s /usr/bin/fish
  chsh -s /usr/bin/fish
  chsh -s /bin/fish
else
  echo "Default shell is fish"
fi

if [[ ! -d "$HOME/.local/bin" ]]; then
  echo "~/.local/bin does not exist"
  mkdir -p "$HOME/.local/bin"
fi
if [[ ! -f "$HOME/.local/bin/env.fish" ]]; then
  echo "env.fish does not exist"
  touch "$HOME/.local/bin/env.fish"
fi

echo "============================================="
echo "-----| INSTALLING FISHER |-----"
echo "============================================="
if [[ "$SHELL" != "$(command -v fish)" ]]; then
  echo "Default shell is not fish"
else
  cd "$DOWNLOAD_DIR"
  fish -c 'curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher'
  fish -c 'fisher install jethrokuan/tide'
  fish -c 'tide configure'
fi

echo "============================================="
echo "-----| CONFIGURE TMUX |-----"
echo "============================================="
rm -rf $HOME/.tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "============================================="
echo "-----| CONFIGURE FONTS |-----"
echo "============================================="
cd $REPO_DIR
cp -r Fonts_used ~/.fonts
sudo cp $HOME/.config/fontconfig/fonts.conf /etc/fonts/local.conf
sudo fc-cache -fv
fc-cache -fv

echo "============================================="
echo "-----| CONFIGURE THEMES |-----"
echo "============================================="
cd $DOWNLOAD_DIR
rm -rf Graphite-gtk-theme
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
cd Graphite-gtk-theme
./install.sh -d ~/.themes -t teal -c dark -s standard -l --tweaks black rimless normal

echo "============================================="
echo "-----| INSTALL WALLPAPERS |-----"
echo "============================================="
cd $REPO_DIR
mkdir -p ~/Pictures/wallpaper/
cp -r Wallpaper/* ~/Pictures/wallpaper/

echo "============================================="
echo "-----| INSTALL SNAP PACKAGES |-----"
echo "============================================="
# sudo snap install android-studio --classic
# sudo snap install flutter --classic
if [[ "$SHELL" != "$(command -v subl)" ]]; then
  sudo snap install sublime-text --classic
fi
if [[ "$SHELL" != "$(command -v onlyoffice-desktopeditors)" ]]; then
  sudo snap install onlyoffice-desktopeditors
fi

echo "============================================="
echo "-----| CONFIGURE HARDWARE ACCELERATION |-----"
echo "============================================="
sudo tee /etc/environment >/dev/null <<'EOF'
LIBVA_DRIVER_NAME=radeonsi
VDPAU_DRIVER=radeonsi
MOZ_DISABLE_RDD_SANDBOX=1
EOF

echo "============================================="
echo "-----| CONFIGURE MX MASTER |-----"
echo "============================================="
sudo usermod -a -G input $USER
echo 'KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-solaar.rules
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "============================================="
echo "-----| CONFIGURE APP ARMOR |-----"
echo "============================================="
sudo systemctl enable --now apparmor

echo "============================================="
echo "-----| CONFIGURE FIREWALL |-----"
echo "============================================="
sudo systemctl enable --now ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw enable


echo "============================================="
echo "-----| REBOOT PLEASE |-----"
echo "============================================="
