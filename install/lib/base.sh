#!/usr/bin/env bash

BASE_PKGS=(base base-devel linux linux-firmware linux-headers btrfs-progs sudo zram-generator)
LIVE_PACMAN_CONF="/etc/pacman.conf"
LIVE_MIRRORLIST="/etc/pacman.d/mirrorlist"
PARALLEL_DOWNLOADS=12
MIRROR_COUNT=20
USER_GROUPS="wheel,users,storage,power,audio,video,input"
WHEEL_SUDOERS="/etc/sudoers.d/10-wheel"
I2C_MODULES_LOAD="/etc/modules-load.d/i2c-dev.conf"
PAM_LOGIN="/etc/pam.d/login"
PAM_PASSWD="/etc/pam.d/passwd"
ZSWAP_TMPFILES="/etc/tmpfiles.d/zswap-off.conf"
SYSCTL_LOCAL="/etc/sysctl.d/90-local.conf"
OOMD_CONF="/etc/systemd/oomd.conf.d/10-local.conf"
OOMD_APP_SLICE="/etc/systemd/user/app.slice.d/10-oomd.conf"
USER_STOP_TIMEOUT="/etc/systemd/user.conf.d/10-stop-timeout.conf"
SYSCTL_ARP="/etc/sysctl.d/90-arp.conf"
WIRELESS_REGDOM_CONF="/etc/conf.d/wireless-regdom"
ZONE_TAB="/usr/share/zoneinfo/zone.tab"
LAPTOP_MASKED_SERVICES=(NetworkManager-wait-online.service)
LOGIND_CONF="/etc/systemd/logind.conf.d/10-local.conf"
GVFS_SLEEP_HOOK="/usr/lib/systemd/system-sleep/gvfs-fuse"
FAILLOCK_CONF="/etc/security/faillock.conf"
FAILLOCK_DENY=10
FAILLOCK_UNLOCK_SECONDS=120
HIBERNATE_SWAPFILE="/swap/swapfile"
HIBERNATE_DELAY="2h"
HIBERNATE_SLEEP_CONF="/etc/systemd/sleep.conf.d/10-hibernate.conf"
HIBERNATE_LOGIND_CONF="/etc/systemd/logind.conf.d/20-hibernate.conf"
KIB_PER_GIB=1048576
GLOBAL_USER_SERVICES=(filter-chain.service)
SYSTEM_SERVICES=(NetworkManager.service fstrim.timer bluetooth.service cronie.service paccache.timer systemd-timesyncd.service qs-hwinfo.service systemd-oomd.service)

baseLivePacman() {
  run sed -i -E \
    -e 's/^#Color$/Color/' \
    -e 's/^#VerbosePkgLists$/VerbosePkgLists/' \
    -e "s/^#?ParallelDownloads.*/ParallelDownloads = ${PARALLEL_DOWNLOADS}/" \
    "$LIVE_PACMAN_CONF"
  if ! grep -q '^\[multilib\]' "$LIVE_PACMAN_CONF"; then
    run sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' "$LIVE_PACMAN_CONF"
  fi
  retry run pacman -Sy --noconfirm archlinux-keyring
}

baseMirrors() {
  retry run reflector --protocol https --latest "$MIRROR_COUNT" --sort rate --save "$LIVE_MIRRORLIST"
}

basePackageList() {
  local ucode=() boot=() shells=()
  case "${A_CPU:-none}" in
    amd) ucode=(amd-ucode) ;;
    intel) ucode=(intel-ucode) ;;
  esac
  bundleCollect
  gpuPackages
  mapfile -t boot < <(bootPackages)
  mapfile -t shells < <(shellPackages)
  printf '%s\n' "${BASE_PKGS[@]}" "${ucode[@]}" "${B_PKGS[@]}" "${G_PKGS[@]}" "${boot[@]}" "${shells[@]}" | awk 'NF && !seen[$0]++'
}

basePacstrap() {
  local packages=()
  mapfile -t packages < <(basePackageList)
  echo "installing ${#packages[@]} packages"
  retry run pacstrap -K -P "$MNT" "${packages[@]}"
}

baseFstab() {
  if ((DRY_RUN)); then
    echo "  [dry-run] genfstab -U ${MNT} > ${MNT}/etc/fstab"
    return 0
  fi
  genfstab -U "$MNT" >"${MNT}/etc/fstab"
  cat "${MNT}/etc/fstab"
}

systemLocale() {
  inChroot ln -sf "/usr/share/zoneinfo/${A_TZ}" /etc/localtime
  inChroot hwclock --systohc
  run sed -i "s|^#${A_LOCALE} |${A_LOCALE} |" "${MNT}/etc/locale.gen"
  inChroot locale-gen
  writeFile "${MNT}/etc/locale.conf" <<<"LANG=${A_LOCALE}"
  writeFile "${MNT}/etc/vconsole.conf" <<<"KEYMAP=${A_KEYMAP}"
}

systemHost() {
  writeFile "${MNT}/etc/hostname" <<<"$A_HOSTNAME"
  writeFile "${MNT}/etc/hosts" <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${A_HOSTNAME}.localdomain ${A_HOSTNAME}
EOF
}

systemTuning() {
  writeFile "${MNT}/etc/systemd/zram-generator.conf" <<'EOF'
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF
  writeFile "${MNT}${ZSWAP_TMPFILES}" <<<"w! /sys/module/zswap/parameters/enabled - - - - N"
  writeFile "${MNT}${SYSCTL_LOCAL}" <<'EOF'
vm.swappiness=150
vm.vfs_cache_pressure=50
vm.page-cluster=0
vm.watermark_boost_factor=0
vm.watermark_scale_factor=125
vm.dirty_background_bytes=67108864
vm.dirty_bytes=268435456
vm.dirty_writeback_centisecs=1500
EOF
  writeFile "${MNT}${OOMD_CONF}" <<'EOF'
[OOM]
DefaultMemoryPressureLimit=50%
DefaultMemoryPressureDurationSec=20s
EOF
  writeFile "${MNT}${OOMD_APP_SLICE}" <<'EOF'
[Slice]
ManagedOOMMemoryPressure=kill
EOF
  writeFile "${MNT}${USER_STOP_TIMEOUT}" <<'EOF'
[Manager]
DefaultTimeoutStopSec=10s
EOF
  run sed -i -E 's/^#?MAKEFLAGS=.*/MAKEFLAGS="-j$(nproc)"/' "${MNT}/etc/makepkg.conf"
}

_systemRegdom() {
  local country
  country="$(awk -v tz="$A_TZ" '$3 == tz { print $1 }' "$ZONE_TAB")"
  if [[ -n "$country" ]]; then
    run sed -i "s/^#WIRELESS_REGDOM=\"${country}\"/WIRELESS_REGDOM=\"${country}\"/" "${MNT}${WIRELESS_REGDOM_CONF}"
  fi
}

systemNetwork() {
  _systemRegdom
  if ((D_LAPTOP)); then
    writeFile "${MNT}${SYSCTL_ARP}" <<'EOF'
net.ipv4.conf.all.arp_ignore=1
net.ipv4.conf.default.arp_ignore=1
net.ipv4.conf.all.arp_announce=2
net.ipv4.conf.default.arp_announce=2
EOF
    inChroot systemctl mask "${LAPTOP_MASKED_SERVICES[@]}"
  fi
}

_systemSetPasswords() {
  if ((DRY_RUN)); then
    echo "  [dry-run] chpasswd for ${A_USER} and root (passwords via stdin)"
    return 0
  fi
  printf '%s:%s\n' "$A_USER" "$P_USER" | arch-chroot "$MNT" chpasswd
  printf 'root:%s\n' "$P_ROOT" | arch-chroot "$MNT" chpasswd
}

systemUsers() {
  if ((DRY_RUN)) || ! arch-chroot "$MNT" id -u "$A_USER" >/dev/null 2>&1; then
    inChroot useradd -m -G "$USER_GROUPS" -s "$(shellLoginPath)" "$A_USER"
  fi
  _systemSetPasswords
  writeFile "${MNT}${WHEEL_SUDOERS}" 440 <<<"%wheel ALL=(ALL:ALL) ALL"
  inChroot visudo -cf "$WHEEL_SUDOERS"
}

systemFiles() {
  writeFile "${MNT}${I2C_MODULES_LOAD}" <<<"i2c-dev"
  writeFile "${MNT}${PAM_LOGIN}" <<'EOF'
#%PAM-1.0

auth       requisite    pam_nologin.so
auth       include      system-local-login
auth       optional     pam_gnome_keyring.so
account    include      system-local-login
session    include      system-local-login
session    optional     pam_gnome_keyring.so auto_start
password   include      system-local-login
EOF
  writeFile "${MNT}${PAM_PASSWD}" <<'EOF'
#%PAM-1.0
auth		include		system-auth
account		include		system-auth
password	include		system-auth
password	optional	pam_gnome_keyring.so
EOF
  run install -Dm644 "${INSTALLER_DIR}/fontconfig/fonts.conf" "${MNT}/etc/fonts/local.conf"
  run install -Dm755 "${INSTALLER_DIR}/quickshell/system/qs-hwinfo" "${MNT}/usr/local/bin/qs-hwinfo"
  run install -Dm644 "${INSTALLER_DIR}/quickshell/system/qs-hwinfo.service" "${MNT}/etc/systemd/system/qs-hwinfo.service"
  run install -Dm755 "${INSTALLER_DIR}/quickshell/system/qs-battery-perms" "${MNT}/usr/local/bin/qs-battery-perms"
  run install -Dm644 "${INSTALLER_DIR}/quickshell/system/99-qs-battery.rules" "${MNT}/etc/udev/rules.d/99-qs-battery.rules"
  run sed -i -E \
    -e "s/^#? *deny *=.*/deny = ${FAILLOCK_DENY}/" \
    -e "s/^#? *unlock_time *=.*/unlock_time = ${FAILLOCK_UNLOCK_SECONDS}/" \
    "${MNT}${FAILLOCK_CONF}"
}

_systemRamGib() {
  awk -v kib="$KIB_PER_GIB" '/^MemTotal:/ { print int(($2 + kib - 1) / kib) }' /proc/meminfo
}

systemHibernate() {
  [[ "${A_HIBERNATE:-no}" == yes ]] || return 0
  inChroot btrfs filesystem mkswapfile --size "$(_systemRamGib)g" --uuid clear "$HIBERNATE_SWAPFILE"
  inChroot sh -c 'grep -qF "$1" /etc/fstab || printf "%s\n" "$1" >>/etc/fstab' _ "${HIBERNATE_SWAPFILE} none swap defaults,pri=0 0 0"
  writeFile "${MNT}${HIBERNATE_SLEEP_CONF}" <<EOF
[Sleep]
HibernateDelaySec=${HIBERNATE_DELAY}
EOF
  writeFile "${MNT}${HIBERNATE_LOGIND_CONF}" <<'EOF'
[Login]
HandleLidSwitch=suspend-then-hibernate
EOF
}

systemSleep() {
  writeFile "${MNT}${LOGIND_CONF}" <<'EOF'
[Login]
InhibitDelayMaxSec=15
HandlePowerKey=ignore
EOF
  writeFile "${MNT}${GVFS_SLEEP_HOOK}" 755 <<'EOF'
#!/bin/sh
case "$1" in
  pre)
    findmnt -rn -t fuse.gvfsd-fuse -o TARGET | while read -r target; do
      umount -l "$target"
    done
    ;;
  post)
    for user in $(loginctl list-users --no-legend | awk '{print $2}'); do
      systemctl --user -M "${user}@" --no-block restart gvfs-daemon.service
    done &
    ;;
esac
EOF
}

systemServices() {
  inChroot systemctl enable "${SYSTEM_SERVICES[@]}"
  inChroot systemctl --global enable "${GLOBAL_USER_SERVICES[@]}"
  gpuEnablePowerUnits
}

systemConfigure() {
  systemLocale
  systemHost
  systemTuning
  systemNetwork
  systemSleep
  systemHibernate
  systemUsers
  gpuConfigureSystem
  systemFiles
  bundleSystemHooks
  systemServices
}

systemInitramfs() {
  inChroot mkinitcpio -P
}
