# APP NEEDED TO WINDOW MANAGER WORK PROPERLLY -----------------------------------------------------------
sudo pacman -S dunst firefox chromium neovim zsh tmux ntfs-3g \
  unzip ripgrep gvfs-mtp net-tools mtpfs neofetch usbutils \
  udisks2 udiskie acpi dhcpcd fzf zip mpv pacman-contrib cronie brightnessctl\
  thunar tumbler transmission-gtk nvtop man-db eza slurp grim

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
  linux linux-headers 

# FOR AMD CPU -----------------------------------------------------------
sudo pacman -S amd-ucode

# IF GPU IS NVIDIA -----------------------------------------------------------
sudo pacman -S nvidia nvidia-utils nvidia-settings nvidia-dkms

# VIDEO AUDIO CODECS -----------------------------------------------------------
sudo pacman -S alsa-utils alsa-plugins alsa-lib alsa-firmware \
  a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora \
  libvorbis libxv wavpack x264 xvidcore vlc ffmpeg pavucontrol

# STEPS -----------------------------------------------------------
# ACTIVATE MONITORS
sudo vim /etc/default/grub
# in GRUB_CMDLINE_LINUX_DEFAULT add in the end of the line inside double quotes "nvidia_drm.modeset=1"
# see https://wiki.hyprland.org/Nvidia/
sudo grub-mkconfig -o /boot/grub/grub.cfg
# 1- INSTALL YAY AND SNAPD
git clone https://aur.archlinux.org/yay.git && cd yay/ && makepkg -si
git clone https://aur.archlinux.org/snapd.git && cd snapd && makepkg -si
sudo systemctl enable --now snapd.socket
sudo systemctl enable --now snapd.apparmor.service
sudo ln -s /var/lib/snapd/snap /snap
# to check snap is installed try see https://snapcraft.io/docs/installing-snap-on-arch-linux
sudo snap install hello-world
# 2- OH-MY-ZSH
# 3- powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# in .zshrc replace ZSH_THEME with ZSH_THEME="powerlevel10k/powerlevel10k"

# 4- zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# 5- zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# in .zshrc replace plugins withplugins=(git zsh-syntax-highlighting zsh-autosuggestions)

# 6- install tmux plugin manager (tpm)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# 7- copy FontUsed to ~/.fonts   
cp -r Fonts_used ~/.fonts
# 8- copy Juno-ocean to /usr/share/themes/   
sudo cp -r Juno-ocean /usr/share/themes/
# 9- copy kora-green to /usr/share/icons/
sudo cp -r kora-green /usr/share/icons/
# 10- mkdir -p ~/Pictures/wallpaper/
# 11- copy Wallpaper in ~/Pictures/wallpaper/

# YAY ----------------------------------------------------------- 
yay -S brave-bin rofi-lbonn-wayland-git pacseek trizen 

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

# MANUAL INSTALL auto-cpufreq----------------------------------------------------------
git clone https://github.com/AdnanHodzic/auto-cpufreq.git && cd auto-cpufreq && sudo ./auto-cpufreq-installer
sudo auto-cpufreq --install


# HARDWARE ACCELERATION -----------------------------------------------------------

# FOR AMD APU OR GPU
sudo pacman -S mesa-utils libva-mesa-driver vdpauinfo libva-vdpau-driver mesa-vdpau libva-utils

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
