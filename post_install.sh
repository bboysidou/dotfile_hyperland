# APP NEEDED TO WINDOW MANAGER WORK PROPERLLY -----------------------------------------------------------
sudo pacman -S dunst firefox chromium neovim zsh tmux ntfs-3g \
  unzip ripgrep gvfs-mtp net-tools mtpfs neofetch usbutils \
  udisks2 udiskie acpi dhcpcd fzf zip mpv pacman-contrib cronie brightnessctl\
  thunar tumbler transmission-gtk nvtop man-db

# HYPRLAND -----------------------------------------------------------
sudo pacman -S wl-clipboard waybar hyprpaper hyprlock 

# ENABLE DHCPCD SERVICE -----------------------------------------------------------
sudo systemctl start dhcpcd.service
sudo systemctl enable dhcpcd.service

# NODE NPM -----------------------------------------------------------
sudo pacman -S nodejs npm 

# MAKE DOCKER RUN WITHOUT SUDO -----------------------------------------------------------
sudo pacman -S docker docker-compose 
sudo usermod -aG docker $USER

# BLUETOOTH -----------------------------------------------------------
sudo pacman -S bluez bluez-utils blueberry

# FIRMWARE AND LINUX HEADERS -----------------------------------------------------------
sudo pacman -S linux-firmware linux-firmware-marvell linux-firmware-qlogic \
  linux linux-headers mesa-utils 

# FOR AMD CPU -----------------------------------------------------------
sudo pacman -S amd-ucode

# IF GPU IS NVIDIA -----------------------------------------------------------
sudo pacman -S nvidia nvidia-utils nvidia-settings nvidia-dkms

# VIDEO AUDIO CODECS -----------------------------------------------------------
sudo pacman -S alsa-utils alsa-plugins alsa-lib alsa-firmware \
  a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora \
  libvorbis libxv wavpack x264 xvidcore vlc ffmpeg pavucontrol

# STEPS -----------------------------------------------------------
# 1- INSTALL YAY AND SNAPD
# 2- OH-MY-ZSH
# 3- powerlevel10k
# 4- zsh-autosuggestions
# 5- zsh-syntax-highlighting
# 6- install tmux plugin manager (tpm)
# 7- copy FontUsed to ~/.fonts   
# 7- copy Juno-ocean to /usr/share/themes/   
# 7- copy kora-green to /usr/share/icons/
# 8- mkdir -p ~/Pictures/wallpaper/
# 9- copy Wallpaper in ~/Pictures/wallpaper/

# YAY ----------------------------------------------------------- 
yay -S brave-bin rofi-lbonn-wayland pacseek trizen 

# SNAPs ----------------------------------------------------------- 
sudo snap install android-studio --classic
sudo snap install sublime-text --classic
sudo snap install flutter --classic
sudo snap install onlyoffice-desktopeditors

# ADD TO .zshrc -----------------------------------------------------------
alias tmuxa="sh ~/.config/custom_scripts/tmux_add_session.sh"
alias sysupdate="sudo pacman -Syu"
alias sysclean="paccache -r & sudo pacman -R $(pacman -Qtdq)"
bindkey -s '^[c' 'sh ~/.config/custom_scripts/ssh_connection.sh\n'
bindkey -s '^t' 'sh ~/.config/custom_scripts/tmux_recover.sh\n'

# MANUAL INSTALL -----------------------------------------------------------
auto-cpufreq

# HARDWARE ACCELERATION -----------------------------------------------------------

# FOR AMD APU OR GPU
sudo pacman -S libva-mesa-driver vdpauinfo libva-vdpau-driver mesa-vdpau libva-utils

# ADD THIS TO /etc/environment
LIBVA_DRIVER_NAME=radeonsi
VDPAU_DRIVER=radeonsi
MOZ_DISABLE_RDD_SANDBOX=1

# IN FIREFOX
about:config
media.ffmpeg.vaapi.enabled => true
media.hardware-video-decoding.force-enabled => true

# PACMAN
# in /etc/pacman.conf uncomment
Color
CheckSpace
VerbosePkgLists
ParallelDownloads = 5

# PACKAGE INSTALLED ----------------------------------------------------------- 
see sidou_arch.txt
