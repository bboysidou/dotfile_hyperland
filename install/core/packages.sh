linux=(
  # LINUX HEADERS -----------------------------------------------------------
  linux 
  linux-firmware
  linux-headers
)

general=(
  # APP NEEDED TO WINDOW MANAGER WORK PROPERLLY -------------------
  btop
  firefox 
  chromium
  neovim
  zsh
  tmux
  ntfs-3g
  unzip
  ripgrep
  gvfs-mtp
  net-tools
  network-manager-applet
  mtpfs
  fastfetch
  usbutils
  udisks2
  udiskie
  acpi
  dhcpcd
  fzf
  zip
  mpv
  scrcpy
  dpkg
  pacman-contrib
  cronie
  brightnessctl
  thunar
  tumbler
  transmission-gtk
  nvtop
  man-db
  eza
  slurp
  grim
  chafa
  yazi
  p7zip
  7zip
  jq
  poppler
  fd
  fzf
  zoxide
  imagemagick
  unrar
  vi
  fish
  kitty
  papirus-icon-theme
  rsync
  obs-studio
  evince
  feh
  tree
  gcc
  gdb
  make
  valgrind
  clang
  papirus-icon-theme
  curl
  wget
  base-devel
  # gtk-engine-murrine
  sassc
  speedtest-cli
  android-tools
  exfatprogs
  trash-cli

  # FOR OCR ------------------------------------------------------- 
  tesseract
  tesseract-data-eng

  # DEV -----------------------------------------------------------
  cmake 
  ninja 
  clang 
  gtk3 
  pkg-config
  nodejs 
  npm 
  android-udev
  jdk17-openjdk
  jdk21-openjdk
  tree-sitter-cli

  # Docker --------------------------------------------------------
  docker 
  docker-compose 

  # BLUETOOTH -----------------------------------------------------
  bluez
  bluez-utils
  bluez-tools
  blueman

  # AMD CPU -------------------------------------------------------
  amd-ucode
  
  # PERSONALIZATIONS --------------------------------------------------
  noto-fonts
  noto-fonts-cjk
  noto-fonts-emoji
  noto-fonts-extra
  ttf-jetbrains-mono-nerd
  ttf-fira-code
  ttf-dejavu-nerd
  ttf-firacode-nerd
  ttf-iosevka-nerd
  ttf-meslo-nerd
  ttf-fira-sans
  otf-font-awesome
  ttf-nunito
  
  # HARDWARE ACCELERATION -----------------------------------------
  mesa-utils
  libva-mesa-driver
  vdpauinfo
  libva-utils
  # libva-vdpau-driver
  # mesa-vdpau
  
  # FIREWALL
  nftables
  ufw

  # APPLICATION CONFINEMENT (SELINUX, APPARMOR)
  apparmor
  fail2ban
  arch-audit

  # MOUSE MX MASTER -----------------------------------------
  gnome-shell-extensions 
  solaar
)

audio=(
  ffmpeg
  alsa-utils
  alsa-plugins
  alsa-lib
  alsa-firmware
  a52dec
  faac
  faad2
  flac
  jasper
  lame
  libdca
  libdv
  libmad
  libmpeg2
  libtheora
  libvorbis
  libxv
  wavpack
  x264
  xvidcore
  vlc
  pipewire
  wireplumber
  pipewire-audio
  pipewire-alsa
  pipewire-pulse
  sof-firmware
  pavucontrol
  pamixer
)

window_manager=(
  hyprland
  wl-clipboard
  hyprpaper
  hyprlock
  xdg-desktop-portal-hyprland
  qt5-wayland 
  qt6-wayland 
  polkit-kde-agent 
)

quickshell=(
  # SHELL (BAR, LAUNCHER, NOTIFICATIONS, LOCK, POWER MENU) ---------
  quickshell

  # NOTIFICATION CLIENT (quickshell is now the daemon) ------------
  libnotify

  # AUDIO VISUALISER ----------------------------------------------
  cava

  # BATTERY / MOUSE BATTERY (Quickshell.Services.UPower) -----------
  upower

  # NETWORK (Quickshell.Networking + control centre editor) --------
  networkmanager
  nm-connection-editor

  # DASHBOARD MONITOR LAUNCHERS -----------------------------------
  htop
)

aur=(
  brave-bin
  pacseek
  trizen
  nwg-look
  nwg-displays
  zen-browser-bin
  ninja
  gcc
  cmake
  meson
  onlyoffice-bin
  bruno-bin

  # CURSOR THEME (hypr/config/autostart.lua sets Bibata-Modern-Ice) -
  bibata-cursor-theme

  # ICON THEME (quickshell/shell.qml pins FairyWren_Dark_black) ----
  fairywren-icon-theme-git

  # FONTS NOT IN THE OFFICIAL REPOS -------------------------------
  otf-apple-sf-pro
  ttf-orbitron
  ttf-icomoon-feather
)
