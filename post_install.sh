# APP NEEDED TO WINDOW MANAGER WORK PROPERLLY -----------------------
sudo pacman -S dunst firefox chromium neovim zsh tmux ntfs-3g \
  unzip ripgrep gvfs-mtp net-tools mtpfs fastfetch usbutils \
  udisks2 udiskie acpi dhcpcd fzf zip mpv pacman-contrib cronie brightnessctl\
  thunar tumbler transmission-gtk nvtop man-db eza slurp grim chafa \
  yazi ffmpeg p7zip 7zip jq poppler fd fzf zoxide imagemagick \
  unrar vi fish kitty papirus-icon-theme rsync obs-studio evince \
  feh tree gcc gdb make valgrind clang papirus-icon-theme curl \
  gtk-engine-murrine sassc speedtest-cli android-tools exfatprogs uwsm trash-cli

# FOR OCR ------------------------------------------------------- 
sudo pacman -S tesseract-data

# FOR DUAL BOOT (OPTIONAL) -------------------------------------------------------
sudo pacman -S efibootmgr dosfstools mtools os-prober 
# EMAIL CLIENT -------------------------------------------------------
sudo pacman -S thunderbird

# HYPRLAND -----------------------------------------------------------
sudo pacman -S wl-clipboard waybar hyprpaper hyprlock 

# ENABLE DHCPCD SERVICE ----------------------------------------------
sudo systemctl start dhcpcd.service
sudo systemctl enable dhcpcd.service

# NODE NPM -----------------------------------------------------------
sudo pacman -S nodejs npm 

# MAKE DOCKER RUN WITHOUT SUDO ---------------------------------------
sudo pacman -S docker docker-compose 
sudo usermod -aG docker $USER

# BLUETOOTH -----------------------------------------------------------
sudo pacman -S bluez bluez-utils blueberry

# FIRMWARE AND LINUX HEADERS ------------------------------------------
sudo pacman -S linux-firmware linux-firmware-marvell linux-firmware-qlogic \
  linux linux-headers 

# FOR AMD CPU ----------------------------------------------------------
sudo pacman -S amd-ucode

# IF GPU IS NVIDIA ------------------------------------------------------
sudo pacman -S nvidia nvidia-utils nvidia-settings nvidia-dkms

# VIDEO AUDIO CODECS ----------------------------------------------------
sudo pacman -S alsa-utils alsa-plugins alsa-lib alsa-firmware \
  a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora \
  libvorbis libxv wavpack x264 xvidcore vlc pavucontrol pamixer

# STEPS ------------------------------------------------------------------
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

# SHELL -----------------------------------------------------------------
# ZSH
# oh-my-zsh
# powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# in .zshrc replace ZSH_THEME with ZSH_THEME="powerlevel10k/powerlevel10k"

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# in .zshrc replace plugins withplugins=(git zsh-syntax-highlighting zsh-autosuggestions)

# FISH
# make fish the default shell one of the following commands
sudo chsh -s /bin/fish
sudo chsh -s /usr/bin/fish
chsh -s /usr/bin/fish
chsh -s /bin/fish
# install fisher
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
# install tide prompt
fisher install jethrokuan/tide
# configuration
tide configure

# TMUX --------------------------------------------------
# install tmux plugin manager (tpm)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# PERSONALIZATIONS --------------------------------------------------
# copy FontUsed to ~/.fonts   
sudo pacman -S noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd ttf-fira-code
cp -r Fonts_used ~/.fonts
sudo cp .config/fontconfig/fonts.conf /etc/fonts/local.conf
sudo fc-cache -fv
fc-cache -fv

# copy Juno-ocean to /usr/share/themes/   
mkdir ~/.themes
sudo cp -r Juno-ocean /usr/share/themes/
# copy kora-green to /usr/share/icons/
sudo cp -r kora-green /usr/share/icons/

# mkdir -p ~/Pictures/wallpaper/
mkdir -p ~/Pictures/wallpaper/
cp -r Wallpaper/* ~/Pictures/wallpaper/

# SDDM
# install the theme sddm-astronaut-theme

# GTK THEME
git clone https://github.com/vinceliuice/Graphite-gtk-theme.git
cd Graphite-gtk-theme
./install.sh -d ~/.themes -t teal -c dark -s standard -l --tweaks black rimless normal

# YAY ----------------------------------------------------------- 
yay -S brave-bin rofi-lbonn-wayland-git pacseek trizen nwg-look

# SNAPs ---------------------------------------------------------
sudo snap install android-studio --classic
sudo snap install sublime-text --classic
sudo snap install flutter --classic
sudo snap install onlyoffice-desktopeditors

# ADD TO .zshrc -------------------------------------------------
alias tmuxa="sh ~/.config/custom_scripts/tmux_add_session.sh"
alias sysupdate="sudo pacman -Syu"
alias sysclean="paccache -r & sudo pacman -R $(pacman -Qtdq)"
bindkey -s '^[c' 'sh ~/.config/custom_scripts/ssh_connection.sh\n'
bindkey -s '^t' 'sh ~/.config/custom_scripts/tmux_recover.sh\n'

# HARDWARE ACCELERATION -----------------------------------------

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

# SECURITY -----------------------------------------
# FIREWALL
sudo pacman -S ufw
sudo systemctl enable --now ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp  # Allow SSH if needed
sudo ufw enable

# APPLICATION CONFINEMENT (SELINUX, APPARMOR)
sudo pacman -S apparmor
sudo systemctl enable --now apparmor

# OPTIONAL (fail2ban , aide, firejail)
# fail2ban for bans IP addresses conducting too many failed login attempts
sudo pacman -S fail2ban
sudo systemctl enable --now fail2ban

# aide for checking filesystem integrity
sudo pacman -S aide
sudo aide --init
sudo systemctl enable --now aide.timer

# firejail for sandboxing applications restricts what applications can access
sudo pacman -S firejail
sudo systemctl enable --now firejail

# OPTIMIZATION -----------------------------------------
# CPU FREQUENCY SCALING auto-cpufreq
git clone https://github.com/AdnanHodzic/auto-cpufreq.git && cd auto-cpufreq && sudo ./auto-cpufreq-installer
sudo auto-cpufreq --install

# APP CACHING
sudo pacman -S preload
sudo systemctl enable --now preload

# SWAP ZRAM
sudo vim /etc/systemd/zram-generator.conf
# add
# [zram0]
# zram-size=ram

# KVM -----------------------------------------
sudo pacman -S --needed qemu-full libvirt virt-manager dnsmasq iptables-nft edk2-ovmf swtpm bridge-utils vde2 openbsd-netcat dmidecode
sudo usermod -aG libvirt,kvm $USER
newgrp libvirt
sudo virsh net-list --all
sudo virsh net-start default
sudo virsh net-autostart default
sudo systemctl enable --now libvirtd
# add this to the bottom of /etc/libvirt/qemu.conf
sudo vim /etc/libvirt/qemu.conf
user = "sidouxp3" # replace with your username
group = "kvm"
sevurity_driver = "none"

# uncomment /etc/libvirt/libvirtd.conf
sudo vim /etc/libvirt/libvirtd.conf
unix_sock_group = "libvirt"
unix_sock_rw_perms = "0770"
auth_unix_ro = "none"
auth_unix_rw = "none"
sudo systemctl restart --now libvirtd


# MISELINEOUS -----------------------------------------
# Config Keyboard using https://www.usevia.app/
# in a chromium base browser go to the flags 
# chrome://flags/
# search for web hid and enable it then restart the browser
# check if the keyboard is connected
ls -l /dev/hidraw3   
# change the permissions
sudo chmod a+rw /dev/hidraw*
# go to https://www.usevia.app/ and start editing the keyboard
# after finishing 
sudo chmod 600 /dev/hidraw*

# UDEV RULES -----------------------------------------
sudo cp ~/.config/custom_scripts/power_event_handler.sh /usr/local/bin/power_event_handler.sh 
sudo cp power-events.service /etc/systemd/system
sudo 99-power-events.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules

# MOUSE MX MASTER -----------------------------------------
sudo pacman -S gnome-shell-extensions solaar
sudo usermod -a -G input $USER
echo 'KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-solaar.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
# and reboot
