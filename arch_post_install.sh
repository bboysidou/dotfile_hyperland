#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Function to check if a package is installed
is_installed() {
    pacman -Qi "$1" &> /dev/null
}

# Install necessary packages
install_packages() {
    sudo pacman -S --needed --noconfirm "$@"
}

# Install core packages
CORE_PACKAGES=(
    dunst firefox chromium neovim zsh tmux ntfs-3g unzip ripgrep gvfs-mtp 
    net-tools mtpfs fastfetch usbutils udisks2 udiskie acpi dhcpcd fzf zip 
    mpv pacman-contrib cronie brightnessctl thunar tumbler transmission-gtk 
    nvtop man-db eza slurp grim chafa yazi ffmpeg p7zip jq poppler fd fzf 
    zoxide imagemagick unrar vi fish kitty papirus-icon-theme rsync obs-studio 
    feh tree gcc gdb make valgrind clang curl
)
install_packages "${CORE_PACKAGES[@]}"

# Email client
install_packages thunderbird

# Hyprland components
install_packages wl-clipboard waybar hyprpaper hyprlock

# Enable networking services
sudo systemctl enable --now dhcpcd.service

# Install Node.js and NPM
install_packages nodejs npm

# Install Docker and allow non-root user to run it
install_packages docker docker-compose
sudo usermod -aG docker $USER

# Install Bluetooth components
install_packages bluez bluez-utils blueberry

# Install firmware and headers
install_packages linux-firmware linux-firmware-marvell linux-firmware-qlogic linux linux-headers
install_packages amd-ucode  # AMD microcode

# Install NVIDIA drivers if applicable
install_packages nvidia nvidia-utils nvidia-settings nvidia-dkms

# Install audio and video codecs
CODEC_PACKAGES=(
    alsa-utils alsa-plugins alsa-lib alsa-firmware a52dec faac faad2 flac 
    jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack 
    x264 xvidcore vlc pavucontrol pamixer
)
install_packages "${CODEC_PACKAGES[@]}"

# Configure GRUB for NVIDIA
if lspci | grep -i nvidia; then
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/& nvidia_drm.modeset=1/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# Install and configure AUR helper (yay)
if ! is_installed yay; then
    git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd ..
fi

# Install Snapd
if ! is_installed snapd; then
    git clone https://aur.archlinux.org/snapd.git && cd snapd && makepkg -si --noconfirm && cd ..
    sudo systemctl enable --now snapd.socket
    sudo systemctl enable --now snapd.apparmor.service
    sudo ln -s /var/lib/snapd/snap /snap
fi

# Install and configure Zsh plugins
if [[ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/^plugins=.*/plugins=(git zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

# Set Fish as default shell
chsh -s $(which fish)

# Install Fisher and Tide prompt for Fish
if [[ ! -d ~/.config/fish ]]; then
    curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    fisher install jethrokuan/tide
fi

# Install Tmux plugin manager
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install fonts and themes
install_packages noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-jetbrains-mono-nerd ttf-fira-code
cp -r Fonts_used ~/.fonts

sudo cp -r Juno-ocean /usr/share/themes/
sudo cp -r kora-green /usr/share/icons/
mkdir -p ~/Pictures/wallpaper/
cp -r Wallpaper/* ~/Pictures/wallpaper/

# Install additional AUR and Snap packages
yay -S --noconfirm brave-bin rofi-lbonn-wayland-git pacseek trizen

sudo snap install android-studio --classic
sudo snap install sublime-text --classic
sudo snap install flutter --classic
sudo snap install onlyoffice-desktopeditors

# Add aliases to .zshrc
cat <<EOL >> ~/.zshrc
alias tmuxa="sh ~/.config/custom_scripts/tmux_add_session.sh"
alias sysupdate="sudo pacman -Syu"
alias sysclean="paccache -r & sudo pacman -R \$(pacman -Qtdq)"
bindkey -s '^[c' 'sh ~/.config/custom_scripts/ssh_connection.sh\n'
bindkey -s '^t' 'sh ~/.config/custom_scripts/tmux_recover.sh\n'
EOL

# Enable hardware acceleration
install_packages mesa-utils libva-mesa-driver vdpauinfo libva-vdpau-driver mesa-vdpau libva-utils

# Add environment variables for AMD GPU acceleration
cat <<EOL | sudo tee -a /etc/environment
LIBVA_DRIVER_NAME=radeonsi
VDPAU_DRIVER=radeonsi
MOZ_DISABLE_RDD_SANDBOX=1
EOL

# Enable Pacman color and parallel downloads
sudo sed -i 's/^#Color/Color/' /etc/pacman.conf
sudo sed -i 's/^#CheckSpace/CheckSpace/' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
sudo sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf

# Enable UFW firewall
install_packages ufw
sudo systemctl enable --now ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw enable

# Install and enable security tools
install_packages apparmor fail2ban aide firejail
sudo systemctl enable --now apparmor
sudo systemctl enable --now fail2ban
sudo aide --init
sudo systemctl enable --now aide.timer
sudo systemctl enable --now firejail

# Optimize CPU performance
git clone https://github.com/AdnanHodzic/auto-cpufreq.git && cd auto-cpufreq && sudo ./auto-cpufreq-installer
sudo auto-cpufreq --install

# Enable preload for faster application startup
install_packages preload
sudo systemctl enable --now preload

# Enable ZRAM swap
cat <<EOL | sudo tee /etc/systemd/zram-generator.conf
[zram0]
zram-size=ram
EOL
