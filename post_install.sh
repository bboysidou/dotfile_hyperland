# APP NEEDED TO WINDOW MANAGER WORK PROPERLLY
sudo pacman -S rofi dunst firefox chromium neovim zsh tmux ntfs-3g \
  unzip ripgrep gvfs-mtp net-tools mtpfs neofetch usbutils \
  udisks2 udiskie acpi dhcpcd fzf zip ntp ranger w3m fd mpv pacman-contrib cronie brightnessctl\
  xbindkeys thunar starship transmission-gtk nvtop

# HYPRLAND
sudo pacman -S wl-clipboard waybar 

# ENABLE DHCPCD SERVICE
sudo systemctl start dhcpcd.service
sudo systemctl enable dhcpcd.service

# NODE NPM
sudo pacman -S nodejs npm 

# MAKE DOCKER RUN WITHOUT SUDO
sudo pacman -S docker docker-compose 
sudo usermod -aG docker $USER

# BLUETOOTH
sudo pacman -S bluez bluez-utils blueman

# FIRMWARE AND LINUX HEADERS
sudo pacman -S linux-firmware linux-firmware-marvell linux-firmware-qlogic \
  linux linux-headers mesa-utils 

# FOR AMD CPU
sudo pacman -S amd-ucode

# IF GPU IS NVIDIA
sudo pacman -S nvidia nvidia-utils nvidia-settings nvidia-dkms nvidia-prime

# VIDEO AUDIO CODECS
sudo pacman -S alsa-utils alsa-plugins alsa-lib alsa-firmware \
  a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora \
  libvorbis libxv wavpack x264 xvidcore vlc ffmpeg pavucontrol

# STEPS
# 1- INSTALL YAY AND SNAPD
# 2- OH-MY-ZSH
# 3- zsh-autosuggestions
# 4- zsh-syntax-highlighting
# 5- tmux plugin manager (tpm)
# 6- copy FontUsed to ~/.fonts   

yay -S swaylock-effects-git swww swappy-git

# SNAPs 
sudo snap install auto-cpufreq
sudo snap install android-studio --classic
sudo snap install sublime-text --classic
sudo snap install flutter --classic
sudo snap install brave
sudo snap install onlyoffice-desktopeditors

# PACKAGE INSTALLED 
see sidou_arch.txt

# RANGER
# THIS TO COPY ALL CONFIG FILES TO .config
ranger --copy-config=all
# modify rc.conf set preview_image => true

# ADD TO .zshrc
export RANGER_LOAD_DEFAULT_RC=false
alias tmuxa="sh ~/.config/custom_scripts/tmux_add_session.sh"
alias sysupdate="sudo pacman -Syu"
alias sysclean="paccache -r & sudo pacman -R $(pacman -Qtdq)"
bindkey -s '^[c' 'sh ~/.config/custom_scripts/ssh_connection.sh\n'
bindkey -s '^t' 'sh ~/.config/custom_scripts/tmux_recover.sh\n'
eval "$(starship init zsh)"
