#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOWNLOAD_DIR="${HOME}/Downloads"

sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

_installPackages() {
  sudo pacman -S --noconfirm --needed "$@"
}

_installPackagesAUR() {
  yay -S --noconfirm --needed --answerclean All --answerdiff None --answeredit None --removemake "$@"
}

_configureDotfiles() {
  local item
  for item in "$@"; do
    if [[ -d "$item" ]]; then
      mkdir -p "$HOME/.config/${item}"
      cp -rT "$item" "$HOME/.config/${item}"
    else
      cp -v "$item" "$HOME/.config/"
    fi
  done
}

source "${SCRIPT_DIR}/core/packages.sh"

source "${SCRIPT_DIR}/core/configuration.sh"

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
  mkdir -p "$DOWNLOAD_DIR"
  cd "$DOWNLOAD_DIR"
  rm -rf yay
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd "$DOWNLOAD_DIR"
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
echo "-----| INSTALL QUICKSHELL PACKAGES |-----"
echo "============================================="
_installPackages "${quickshell[@]}"

echo "============================================="
echo "-----| INSTALL NVIDIA |-----"
echo "============================================="
"${SCRIPT_DIR}/nvidia.sh"

echo "============================================="
echo "-----| INSTALL AUR PACKAGES |-----"
echo "============================================="
_installPackagesAUR "${aur[@]}"

cd "$REPO_DIR"

echo "============================================="
echo "-----| CONFIGURE DOTFILES |-----"
echo "============================================="
_configureDotfiles "${folders[@]}"

echo "============================================="
echo "-----| INSTALL UNPACKAGED FONTS |-----"
echo "============================================="
mkdir -p "$HOME/.fonts"
cp -v fonts/* "$HOME/.fonts/"
fc-cache -f

echo "============================================="
echo "-----| CONFIGURE DOCKER |-----"
echo "============================================="
sudo usermod -aG docker "$USER"
sudo systemctl enable --now docker

echo "============================================="
echo "-----| CHANGE SHELL TO FISH |-----"
echo "============================================="
FISH_BIN="$(command -v fish)"
grep -qxF "$FISH_BIN" /etc/shells || echo "$FISH_BIN" | sudo tee -a /etc/shells >/dev/null
if [[ "$(getent passwd "$USER" | cut -d: -f7)" != "$FISH_BIN" ]]; then
  sudo chsh -s "$FISH_BIN" "$USER"
else
  echo "Default shell is already fish"
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
FISHER_URL="https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish"
if fish -c 'functions -q fisher'; then
  fish -c 'fisher update' || echo "fisher update failed - vendored plugins already in place, continuing"
else
  fish -c "curl -sL $FISHER_URL | source && fisher install jorgebucaran/fisher"
  fish -c 'fisher install IlanCosman/tide@v6'
fi
fish -c 'tide configure --auto --style=Lean --prompt_colors="True color" --show_time=No --lean_prompt_height="Two lines" --prompt_connection=Disconnected --prompt_spacing=Sparse --icons="Many icons" --transient=No' \
  || echo "tide auto-configure failed - run 'tide configure' by hand once"

echo "============================================="
echo "-----| CONFIGURE TMUX |-----"
echo "============================================="
rm -rf "$HOME/.tmux"
git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

echo "============================================="
echo "-----| CONFIGURE FONTS |-----"
echo "============================================="
cd "$REPO_DIR"
sudo cp "$HOME/.config/fontconfig/fonts.conf" /etc/fonts/local.conf
sudo fc-cache -fv
fc-cache -fv

echo "============================================="
echo "-----| CONFIGURE THEMES |-----"
echo "============================================="
cd "$REPO_DIR"
mkdir -p "$HOME/.themes"

cd $DOWNLOAD_DIR
rm -rf Graphite-gtk-theme
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
cd Graphite-gtk-theme
./install.sh -d ~/.themes -t teal -c dark -s standard -l --tweaks black rimless normal

echo "============================================="
echo "-----| INSTALL WALLPAPERS |-----"
echo "============================================="
cd "$REPO_DIR"
mkdir -p "$HOME/Pictures/wallpaper"
if [[ -d "$REPO_DIR/Wallpaper" ]]; then
  cp -r "$REPO_DIR/Wallpaper/." "$HOME/Pictures/wallpaper/"
else
  echo "No Wallpaper/ in this repo - put your own images in ~/Pictures/wallpaper"
  echo "hypr/hyprpaper.conf and the quickshell picker both read that directory"
fi

echo "============================================="
echo "-----| CONFIGURE HARDWARE ACCELERATION |-----"
echo "============================================="
if lspci | grep -qi nvidia; then
  echo "NVIDIA present - leaving VA-API to nvidia.sh"
  grep -q MOZ_DISABLE_RDD_SANDBOX /etc/environment 2>/dev/null \
    || echo "MOZ_DISABLE_RDD_SANDBOX=1" | sudo tee -a /etc/environment >/dev/null
else
  sudo tee /etc/environment >/dev/null <<'EOF'
LIBVA_DRIVER_NAME=radeonsi
VDPAU_DRIVER=radeonsi
MOZ_DISABLE_RDD_SANDBOX=1
EOF
fi

echo "============================================="
echo "-----| CONFIGURE MX MASTER |-----"
echo "============================================="
sudo usermod -a -G input "$USER"
echo 'KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-solaar.rules
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "============================================="
echo "-----| ENABLE SERVICES |-----"
echo "============================================="
sudo systemctl enable --now bluetooth
sudo systemctl enable --now cronie

echo "============================================="
echo "-----| CONFIGURE APP ARMOR |-----"
echo "============================================="
sudo systemctl enable --now apparmor

echo "============================================="
echo "-----| CONFIGURE FAIL2BAN |-----"
echo "============================================="
sudo tee /etc/fail2ban/jail.local >/dev/null <<'EOF'
[DEFAULT]
bantime  = 1h
findtime = 10m
maxretry = 5
backend  = systemd

[sshd]
enabled = false
EOF
sudo systemctl enable --now fail2ban

echo "============================================="
echo "-----| CONFIGURE FIREWALL |-----"
echo "============================================="
sudo systemctl enable --now ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

echo "============================================="
echo "-----| REBOOT PLEASE |-----"
echo "============================================="
