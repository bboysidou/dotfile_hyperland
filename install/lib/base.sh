#!/usr/bin/env bash

BASE_PKGS=(base base-devel linux linux-firmware linux-headers btrfs-progs sudo zram-generator)
LIVE_PACMAN_CONF="/etc/pacman.conf"
LIVE_MIRRORLIST="/etc/pacman.d/mirrorlist"
PARALLEL_DOWNLOADS=12
MIRROR_COUNT=20
USER_GROUPS="wheel,users,storage,power,audio,video,input"
WHEEL_SUDOERS="/etc/sudoers.d/10-wheel"
I2C_MODULES_LOAD="/etc/modules-load.d/i2c-dev.conf"
GLOBAL_USER_SERVICES=(filter-chain.service)
SYSTEM_SERVICES=(NetworkManager.service fstrim.timer bluetooth.service cronie.service paccache.timer systemd-timesyncd.service qs-hwinfo.service)

baseLivePacman() {
  run sed -i -E \
    -e 's/^#Color$/Color/' \
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
  run sed -i -E 's/^#?MAKEFLAGS=.*/MAKEFLAGS="-j$(nproc)"/' "${MNT}/etc/makepkg.conf"
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
  run install -Dm644 "${INSTALLER_DIR}/fontconfig/fonts.conf" "${MNT}/etc/fonts/local.conf"
  run install -Dm755 "${INSTALLER_DIR}/quickshell/system/qs-hwinfo" "${MNT}/usr/local/bin/qs-hwinfo"
  run install -Dm644 "${INSTALLER_DIR}/quickshell/system/qs-hwinfo.service" "${MNT}/etc/systemd/system/qs-hwinfo.service"
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
  systemUsers
  gpuConfigureSystem
  systemFiles
  bundleSystemHooks
  systemServices
}

systemInitramfs() {
  inChroot mkinitcpio -P
}
