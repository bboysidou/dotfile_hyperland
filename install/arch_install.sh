#!/bin/bash

set -e

# ==============================================
# CONFIGURATION - MODIFIEZ CES VALEURS
# ==============================================
DISK="/dev/nvme0n1"      # Votre disque NVMe
HOSTNAME="archlinux"     # Nom de la machine
USERNAME="user"         # Nom utilisateur
USER_PASSWORD="password" # Mot de passe utilisateur
ROOT_PASSWORD="password" # Mot de passe root
TIMEZONE="Africa/Algiers"
LOCALE="en_US.UTF-8"
KEYMAP="us"

echo "============================================="
echo "   INSTALLATION ARCH LINUX - Configuration"
echo "============================================="
echo "Disque: $DISK"
echo "Hostname: $HOSTNAME"
echo "Utilisateur: $USERNAME"
echo "Timezone: $TIMEZONE"
echo "Locale: $LOCALE"
echo "Clavier: $KEYMAP"
echo ""
echo "ATTENTION: Cette installation va EFFACER tout le contenu du disque $DISK"
echo ""
read -p "Continuer? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
  echo "Installation annulée."
  exit 1
fi

# ==============================================
# 1. PRÉPARATION SYSTÈME
# ==============================================
echo ""
echo "=== 1. Préparation du système ==="

# Clavier US
loadkeys us

# Vérification UEFI
if [[ ! -d "/sys/firmware/efi/efivars" ]]; then
  echo "ERREUR: Mode UEFI requis!"
  exit 1
fi
echo "✓ Mode UEFI détecté"

# Test réseau
if ! ping -c 1 archlinux.org &>/dev/null; then
  echo "ERREUR: Pas de connexion internet!"
  exit 1
fi
echo "✓ Connexion internet OK"

# Synchronisation horloge
timedatectl set-ntp true
echo "✓ Horloge synchronisée"

# ==============================================
# 2. PARTITIONNEMENT
# ==============================================
echo ""
echo "=== 2. Partitionnement du disque ==="

# Vérification du disque
if [[ ! -b "$DISK" ]]; then
  echo "ERREUR: Disque $DISK non trouvé!"
  exit 1
fi

# Nettoyage complet
wipefs -af "$DISK"
sgdisk --zap-all "$DISK"

# Création des partitions
sgdisk --new=1:0:+2G --typecode=1:ef00 --change-name=1:'EFI' \
  --new=2:0:0 --typecode=2:8300 --change-name=2:'ROOT' \
  "$DISK"

echo "✓ Partitions créées"

# ==============================================
# 3. FORMATAGE
# ==============================================
echo ""
echo "=== 3. Formatage des partitions ==="

# Formatage EFI
mkfs.fat -F32 -n EFI "${DISK}p1"
echo "✓ Partition EFI formatée"

# Formatage BTRFS
mkfs.btrfs -f -L ROOT "${DISK}p2"
echo "✓ Partition ROOT formatée en BTRFS"

# ==============================================
# 4. SOUS-VOLUMES BTRFS
# ==============================================
echo ""
echo "=== 4. Création des sous-volumes BTRFS ==="

# Montage temporaire
mount "${DISK}p2" /mnt

# Création des sous-volumes
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@tmp

echo "✓ Sous-volumes créés"

# Démontage
umount /mnt

# ==============================================
# 5. MONTAGE FINAL
# ==============================================
echo ""
echo "=== 5. Montage des systèmes de fichiers ==="

# Options de montage BTRFS
BTRFS_OPTS="noatime,compress=zstd:3,space_cache=v2,discard=async"

# Montage racine
mount -o $BTRFS_OPTS,subvol=@ "${DISK}p2" /mnt

# Création des points de montage
mkdir -p /mnt/{boot,home,var,tmp}

# Montage des sous-volumes
mount -o $BTRFS_OPTS,subvol=@home "${DISK}p2" /mnt/home
mount -o $BTRFS_OPTS,subvol=@var "${DISK}p2" /mnt/var
mount -o $BTRFS_OPTS,subvol=@tmp "${DISK}p2" /mnt/tmp

# Montage EFI
mount "${DISK}p1" /mnt/boot

echo "✓ Systèmes de fichiers montés"

# ==============================================
# 6. INSTALLATION SYSTÈME DE BASE
# ==============================================
echo ""
echo "=== 6. Installation du système de base ==="

# Mise à jour des clés
pacman-key --init
pacman-key --populate archlinux

# Installation
pacstrap /mnt base base-devel linux linux-firmware linux-headers btrfs-progs

echo "✓ Système de base installé"

# ==============================================
# 7. GÉNÉRATION FSTAB
# ==============================================
echo ""
echo "=== 7. Génération du fstab ==="

genfstab -U /mnt >>/mnt/etc/fstab
echo "✓ fstab généré"

# ==============================================
# 8. CONFIGURATION CHROOT
# ==============================================
echo ""
echo "=== 8. Configuration dans chroot ==="

# Script de configuration
cat <<EOF >/mnt/setup.sh
#!/bin/bash
set -e

# Timezone
ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
hwclock --systohc
echo "✓ Timezone configuré: $TIMEZONE"

# Locale
echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
echo "✓ Locale configuré: $LOCALE"

# Clavier
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf
echo "✓ Clavier configuré: $KEYMAP"

# Hostname
echo "$HOSTNAME" > /etc/hostname
cat << 'HOSTS' > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS
echo "✓ Hostname configuré: $HOSTNAME"

# Installation des packages essentiels
sudo sed -i 's/^#Color$/Color/' /etc/pacman.conf
sudo sed -i 's/^#CheckSpace$/CheckSpace/' /etc/pacman.conf
sudo sed -i 's/^#VerbosePkgLists$/VerbosePkgLists/' /etc/pacman.conf
sudo sed -i 's/^ParallelDownloads *= *[0-9]\+/ParallelDownloads = 12/' /etc/pacman.conf
sudo sed -i 's/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j\$(nproc)\"/' /etc/makepkg.conf
pacman -Syu --noconfirm
pacman -S --noconfirm \
    networkmanager iwd wpa_supplicant \
    zram-generator \
    vim \
    git \
    wget curl \
    sudo gvfs \
    openssh \
    amd-ucode

echo "✓ Packages essentiels installés"

# Configuration zram
mkdir -p /etc/systemd/zram-generator.conf.d
cat << 'ZRAM' > /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
ZRAM

echo "✓ zram configuré"

# Utilisateur
useradd -m -G wheel,users,storage,power,audio,video,input -s /bin/bash $USERNAME
echo "$USERNAME:$USER_PASSWORD" | chpasswd
echo "✓ Utilisateur $USERNAME créé"

# Root password
echo "root:$ROOT_PASSWORD" | chpasswd
echo "✓ Mot de passe root défini"

# Sudo
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
echo "✓ Sudo configuré"

# Services
systemctl enable NetworkManager
systemctl enable fstrim.timer

echo "✓ Services activés"

# systemd-boot
bootctl --path=/boot install

# Configuration systemd-boot
cat << 'LOADER' > /boot/loader/loader.conf
default  arch.conf
timeout  3
console-mode max
editor   no
LOADER

# Entrée de boot
ROOT_UUID=\$(blkid -s UUID -o value ${DISK}p2)
cat << BOOTENTRY > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=\$ROOT_UUID rootflags=subvol=@ rw loglevel=7 systemd.show_status=1
BOOTENTRY

# Entrée fallback
cat << BOOTFALLBACK > /boot/loader/entries/arch-fallback.conf
title   Arch Linux (fallback)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options root=UUID=\$ROOT_UUID rootflags=subvol=@ rw
BOOTFALLBACK

echo "✓ systemd-boot configuré"

# mkinitcpio
sed -i 's/^MODULES=()/MODULES=(btrfs)/' /etc/mkinitcpio.conf
mkinitcpio -p linux
echo "✓ initramfs généré"

EOF

# Exécution du script de configuration
chmod +x /mnt/setup.sh
arch-chroot /mnt ./setup.sh

# Nettoyage
rm /mnt/setup.sh

# ==============================================
# 9. FINALISATION
# ==============================================
echo ""
echo "========================================="
echo "   INSTALLATION TERMINÉE AVEC SUCCÈS!"
echo "========================================="
echo ""
echo "Configuration installée:"
echo "• Filesystem: BTRFS avec compression zstd"
echo "• Bootloader: systemd-boot"
echo "• Swap: zram (mémoire compressée)"
echo "• Timezone: $TIMEZONE"
echo "• Locale: $LOCALE"
echo "• Clavier: $KEYMAP"
echo "• Hostname: $HOSTNAME"
echo "• Utilisateur: $USERNAME"
echo "• Timeshift: Snapshots manuels"
echo ""
echo "Identifiants:"
echo "• Utilisateur: $USERNAME / $USER_PASSWORD"
echo "• Root: root / $ROOT_PASSWORD"
echo ""
echo "Prochaines étapes:"
echo "1. umount -R /mnt"
echo "2. reboot"
echo "3. Premier démarrage:"
echo "   - zramctl (vérifier zram)"
echo ""
read -p "Appuyez sur Entrée pour continuer..."
