#!/bin/bash

set -e

# ==============================================
# CONFIGURATION - MODIFY THESE VALUES
# ==============================================
DISK="/dev/nvme0n1"      # Your NVMe disk
HOSTNAME="archlinux"     # Machine name
USERNAME="user"         # Username
USER_PASSWORD="password" # User password
ROOT_PASSWORD="password" # Root password
TIMEZONE="Africa/Algiers"
LOCALE="en_US.UTF-8"
KEYMAP="us"

echo "============================================="
echo "   ARCH LINUX INSTALLATION - Configuration"
echo "============================================="
echo "Disk: $DISK"
echo "Hostname: $HOSTNAME"
echo "User: $USERNAME"
echo "Timezone: $TIMEZONE"
echo "Locale: $LOCALE"
echo "Keyboard: $KEYMAP"
echo "CPU: AMD (specific microcode installed)"
echo ""
echo "WARNING: This installation will ERASE all content on disk $DISK"
echo ""
read -p "Continue? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
  echo "Installation cancelled."
  exit 1
fi

# ==============================================
# 1. SYSTEM PREPARATION
# ==============================================
echo ""
echo "=== 1. System preparation ==="

# US keyboard
loadkeys us

# UEFI verification
if [[ ! -d "/sys/firmware/efi/efivars" ]]; then
  echo "ERROR: UEFI mode required!"
  exit 1
fi
echo "✓ UEFI mode detected"

# Network test
if ! ping -c 1 archlinux.org &>/dev/null; then
  echo "ERROR: No internet connection!"
  exit 1
fi
echo "✓ Internet connection OK"

# Clock synchronization
timedatectl set-ntp true
echo "✓ Clock synchronized"

# ==============================================
# 2. DISK PARTITIONING
# ==============================================
echo ""
echo "=== 2. Disk partitioning ==="

# Disk verification
if [[ ! -b "$DISK" ]]; then
  echo "ERROR: Disk $DISK not found!"
  exit 1
fi

# Complete cleanup
wipefs -af "$DISK"
sgdisk --zap-all "$DISK"

# Partition creation
sgdisk --new=1:0:+2G --typecode=1:ef00 --change-name=1:'EFI' \
  --new=2:0:0 --typecode=2:8300 --change-name=2:'ROOT' \
  "$DISK"

echo "✓ Partitions created"

# ==============================================
# 3. FORMATTING
# ==============================================
echo ""
echo "=== 3. Partition formatting ==="

# EFI formatting
mkfs.fat -F32 -n EFI "${DISK}p1"
echo "✓ EFI partition formatted"

# BTRFS formatting
mkfs.btrfs -f -L ROOT "${DISK}p2"
echo "✓ ROOT partition formatted as BTRFS"

# ==============================================
# 4. BTRFS SUBVOLUMES
# ==============================================
echo ""
echo "=== 4. BTRFS subvolume creation ==="

# Temporary mount
mount "${DISK}p2" /mnt

# Subvolume creation
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@tmp

echo "✓ Subvolumes created"

# Unmount
umount /mnt

# ==============================================
# 5. FINAL MOUNTING
# ==============================================
echo ""
echo "=== 5. Filesystem mounting ==="

# BTRFS mount options
BTRFS_OPTS="noatime,compress=zstd:3,space_cache=v2,discard=async"

# Root mount
mount -o $BTRFS_OPTS,subvol=@ "${DISK}p2" /mnt

# Mount point creation
mkdir -p /mnt/{boot,home,var,tmp}

# Subvolume mounting
mount -o $BTRFS_OPTS,subvol=@home "${DISK}p2" /mnt/home
mount -o $BTRFS_OPTS,subvol=@var "${DISK}p2" /mnt/var
mount -o $BTRFS_OPTS,subvol=@tmp "${DISK}p2" /mnt/tmp

# EFI mount
mount "${DISK}p1" /mnt/boot

echo "✓ Filesystems mounted"

# ==============================================
# 6. BASE SYSTEM INSTALLATION
# ==============================================
echo ""
echo "=== 6. Base system installation ==="

# Key update
pacman-key --init
pacman-key --populate archlinux

# Installation
pacstrap /mnt base base-devel linux linux-firmware linux-headers btrfs-progs

echo "✓ Base system installed"

# ==============================================
# 7. FSTAB GENERATION
# ==============================================
echo ""
echo "=== 7. fstab generation ==="

genfstab -U /mnt >>/mnt/etc/fstab
echo "✓ fstab generated"

# ==============================================
# 8. CHROOT CONFIGURATION
# ==============================================
echo ""
echo "=== 8. Chroot configuration ==="

# Configuration script
cat <<EOF >/mnt/setup.sh
#!/bin/bash
set -e

# Timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc
echo "✓ Timezone configured: $TIMEZONE"

# Locale
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "✓ Locale configured: $LOCALE"

# Keyboard
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf
echo "✓ Keyboard configured: $KEYMAP"

# Hostname
echo "$HOSTNAME" > /etc/hostname
cat << 'HOSTS' > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS
echo "✓ Hostname configured: $HOSTNAME"

# Essential packages installation
sudo sed -i 's/^#Color$/Color/' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' /etc/pacman.conf
sudo sed -i 's/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j\$(nproc)\"/' /etc/makepkg.conf
pacman -Syu --noconfirm
pacman -S --noconfirm \
    networkmanager iwd wpa_supplicant \
    wireless_tools \
    zram-generator \
    vim \
    git fzf ripgrep fd jq exa \
    wget curl \
    htop btop \
    man-db man-pages \
    sudo gvfs trash-cli \
    which \
    unzip \
    openssh \
    amd-ucode \ 
    grub efibootmgr os-prober \ 
    fastfetch \
    zip

echo "✓ Essential packages installed"

# zram configuration
mkdir -p /etc/systemd/zram-generator.conf.d
cat << 'ZRAM' > /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
ZRAM

echo "✓ zram configured"

# User
useradd -m -G wheel,users,storage,power,audio,video,input -s /bin/bash $USERNAME
echo "$USERNAME:$USER_PASSWORD" | chpasswd
echo "✓ User $USERNAME created"

# Root password
echo "root:$ROOT_PASSWORD" | chpasswd
echo "✓ Root password set"

# Sudo
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "✓ Sudo configured"

# Services
systemctl enable NetworkManager
systemctl enable fstrim.timer

echo "✓ Services enabled"

# GRUB Installation
pacman -S --noconfirm grub efibootmgr

# Install GRUB for UEFI
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

# Get root partition UUID
ROOT_UUID=\$(blkid -s UUID -o value ${DISK}p2)

# Configure GRUB
cat << 'GRUBCFG' > /etc/default/grub
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Arch"
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
GRUB_CMDLINE_LINUX="root=UUID=\$ROOT_UUID rootflags=subvol=@"
GRUB_PRELOAD_MODULES="part_gpt part_msdos"
GRUB_ENABLE_CRYPTODISK=n
GRUB_DISABLE_OS_PROBER=false
GRUB_DISABLE_SUBMENU=y
GRUB_TERMINAL_OUTPUT="console"
GRUB_GFXMODE=auto
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_DISABLE_RECOVERY=false
GRUB_BACKGROUND="/usr/share/grub/background.png"
GRUB_THEME="/usr/share/grub/themes/archlinux/theme.txt"
GRUBCFG

# Generate GRUB configuration
grub-mkconfig -o /boot/grub/grub.cfg

echo "✓ GRUB configured"

# mkinitcpio
sed -i 's/^MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf
mkinitcpio -p linux
echo "✓ initramfs generated"

EOF

# Execute configuration script
chmod +x /mnt/setup.sh
arch-chroot /mnt ./setup.sh

# Cleanup
rm /mnt/setup.sh

# ==============================================
# 9. FINALIZATION
# ==============================================
echo ""
echo "========================================="
echo "   INSTALLATION COMPLETED SUCCESSFULLY!"
echo "========================================="
echo ""
echo "Installed configuration:"
echo "• Filesystem: BTRFS with zstd compression"
echo "• Bootloader: GRUB (replaced systemd-boot)"
echo "• Swap: zram (compressed memory)"
echo "• Timezone: $TIMEZONE"
echo "• Locale: $LOCALE"
echo "• Keyboard: $KEYMAP"
echo "• Hostname: $HOSTNAME"
echo "• User: $USERNAME"
echo "• Timeshift: Manual snapshots"
echo ""
echo "Credentials:"
echo "• User: $USERNAME / $USER_PASSWORD"
echo "• Root: root / $ROOT_PASSWORD"
echo ""
echo "Next steps:"
echo "1. umount -R /mnt"
echo "2. reboot"
echo "3. First boot:"
echo "   - zramctl (check zram)"
echo "   - grub-install --version (verify GRUB)"
echo ""
read -p "Press Enter to continue..."
