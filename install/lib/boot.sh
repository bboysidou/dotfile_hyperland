#!/usr/bin/env bash

VERBOSE_CMDLINE="loglevel=7 systemd.show_status=1"
LSM_CMDLINE="lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
SDBOOT_TIMEOUT=3
GRUB_TIMEOUT_SECONDS=5
GRUB_DEFAULTS="/etc/default/grub"
GRUB_HOOK="/etc/pacman.d/hooks/95-grub.hook"
GRUB_BOOTLOADER_ID="GRUB"
GRUB_CFG="/boot/grub/grub.cfg"
LIMINE_TIMEOUT=3
LIMINE_SRC="/usr/share/limine/BOOTX64.EFI"
LIMINE_DIR="EFI/limine"
LIMINE_REMOVABLE_DIR="EFI/BOOT"
LIMINE_LOADER='\EFI\limine\BOOTX64.EFI'
LIMINE_LABEL="Limine"
LIMINE_HOOK="/etc/pacman.d/hooks/95-limine.hook"
LIMINE_CONF="limine.conf"
LIMINE_DEFAULTS="/etc/default/limine"
LIMINE_SCAN_PACKAGE="limine-entry-tool"
LIMINE_SNAPPER_PACKAGE="limine-snapper-sync"
SNAPPER_CONFIG="root"
SNAPPER_UNITS=(snapper-cleanup.timer limine-snapper-sync.service)
SNAPPER_RETENTION=(NUMBER_LIMIT=5 NUMBER_LIMIT_IMPORTANT=5 NUMBER_MIN_AGE=0 TIMELINE_CREATE=no)
LIMINE_MAX_SNAPSHOT_ENTRIES=6
WINDOWS_LOADER="EFI/Microsoft/Boot/bootmgfw.efi"
EDK2_SHELL_SRC="/usr/share/edk2-shell/x64/Shell.efi"
OS_PROBE_DIR="/mnt/osprobe"

W_OTHER_ESPS=""

bootPackages() {
  if [[ "$A_BOOT" == grub ]]; then
    printf '%s\n' grub efibootmgr os-prober fuse3 ntfs-3g
  elif [[ "$A_BOOT" == limine ]]; then
    printf '%s\n' limine efibootmgr
    if bootSnapperSelected; then echo snapper; fi
  elif [[ -n "$W_OTHER_ESPS" ]]; then
    echo edk2-shell
  fi
  return 0
}

bootSnapperSelected() {
  [[ "$A_BOOT" == limine && "${A_SNAPPER:-no}" == yes ]]
}

bootAurPackages() {
  if [[ "$A_BOOT" == limine && "${A_LIMINE_SCAN:-no}" == yes ]]; then
    echo "$LIMINE_SCAN_PACKAGE"
  fi
  if bootSnapperSelected; then
    echo "$LIMINE_SNAPPER_PACKAGE"
  fi
  return 0
}

bootUserStepCount() {
  if bootSnapperSelected; then echo 1; else echo 0; fi
}

bootSnapper() {
  if ((DRY_RUN)) || ! arch-chroot "$MNT" snapper --no-dbus list-configs 2>/dev/null | grep -qw "$SNAPPER_CONFIG"; then
    inChroot snapper --no-dbus -c "$SNAPPER_CONFIG" create-config /
  fi
  inChroot snapper --no-dbus -c "$SNAPPER_CONFIG" set-config "${SNAPPER_RETENTION[@]}"
  inChroot systemctl enable "${SNAPPER_UNITS[@]}"
}

bootExtraCmdline() {
  if bundleSecurityLsm; then
    echo "$LSM_CMDLINE"
  fi
  return 0
}

bootCmdline() {
  local extra uuid
  extra="$(bootExtraCmdline)"
  uuid="$(diskUuid "$L_ROOT")"
  echo "root=UUID=${uuid} rootflags=subvol=@ rw${extra:+ ${extra}}"
}

_bootSystemdEntries() {
  local cmdline="$1" entries="${MNT}/boot/loader/entries"
  writeFile "${entries}/arch.conf" <<EOF
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options ${cmdline} ${VERBOSE_CMDLINE}
EOF
  writeFile "${entries}/arch-fallback.conf" <<EOF
title   Arch Linux (fallback initramfs)
linux   /vmlinuz-linux
initrd  /initramfs-linux-fallback.img
options ${cmdline}
EOF
}

bootSystemdBoot() {
  local esp cmdline xboot=()
  esp="$(diskEspPath)"
  cmdline="$(bootCmdline)" || return 1
  if [[ -n "$L_XBOOT" ]]; then
    xboot=(--boot-path=/boot)
  fi
  run arch-chroot -S "$MNT" bootctl --esp-path="$esp" "${xboot[@]}" install
  writeFile "${MNT}${esp}/loader/loader.conf" <<EOF
default       @saved
timeout       ${SDBOOT_TIMEOUT}
console-mode  max
editor        no
EOF
  _bootSystemdEntries "$cmdline"
  if [[ -n "$W_OTHER_ESPS" ]]; then
    run install -Dm644 "${MNT}${EDK2_SHELL_SRC}" "${MNT}${esp}/shellx64.efi"
  fi
  return 0
}

_grubSet() {
  local key="$1" value="$2" file="${MNT}${GRUB_DEFAULTS}"
  if ((DRY_RUN)); then
    echo "  [dry-run] ${GRUB_DEFAULTS}: ${key}=${value}"
  elif grep -qE "^#?${key}=" "$file"; then
    sed -i -E "s|^#?${key}=.*|${key}=${value}|" "$file"
  else
    echo "${key}=${value}" >>"$file"
  fi
}

_grubInstallArgs() {
  printf '%s\n' --target=x86_64-efi "--efi-directory=$(diskEspPath)" "--bootloader-id=${GRUB_BOOTLOADER_ID}"
}

_grubHook() {
  local args removable=""
  args="$(_grubInstallArgs | paste -sd' ')"
  if [[ "$A_MODE" == wipe ]]; then
    removable=" && grub-install ${args} --removable"
  fi
  writeFile "${MNT}${GRUB_HOOK}" <<EOF
[Trigger]
Type = Package
Operation = Upgrade
Target = grub

[Action]
Description = Reinstalling GRUB and regenerating grub.cfg...
When = PostTransaction
Depends = grub
Exec = /usr/bin/sh -c "grub-install ${args}${removable} && grub-mkconfig -o ${GRUB_CFG}"
EOF
}

_grubProbeMounts() {
  local action="$1" esp index=0
  for esp in $W_OTHER_ESPS; do
    if [[ "$action" == mount ]]; then
      run mkdir -p "${MNT}${OS_PROBE_DIR}-${index}"
      run mount -o ro "$esp" "${MNT}${OS_PROBE_DIR}-${index}"
    else
      run umount "${MNT}${OS_PROBE_DIR}-${index}" || true
    fi
    index=$((index + 1))
  done
  return 0
}

bootGrub() {
  local args=()
  mapfile -t args < <(_grubInstallArgs)
  _grubSet GRUB_DEFAULT saved
  _grubSet GRUB_SAVEDEFAULT true
  _grubSet GRUB_TIMEOUT "$GRUB_TIMEOUT_SECONDS"
  _grubSet GRUB_DISABLE_OS_PROBER false
  _grubSet GRUB_GFXMODE auto
  _grubSet GRUB_GFXPAYLOAD_LINUX keep
  _grubSet GRUB_DISABLE_SUBMENU y
  _grubSet GRUB_CMDLINE_LINUX_DEFAULT "\"$(bootExtraCmdline | sed 's/$/ /')${VERBOSE_CMDLINE}\""
  inChroot grub-install "${args[@]}"
  if [[ "$A_MODE" == wipe ]]; then
    inChroot grub-install "${args[@]}" --removable
  fi
  _grubHook
  _grubProbeMounts mount
  inChroot grub-mkconfig -o "$GRUB_CFG"
  _grubProbeMounts umount
}

_limineGuid() {
  local id
  id="$(diskPartUuid "$1")"
  if [[ -z "$id" ]] && ((!DRY_RUN)); then
    echo "no PARTUUID for $1" >&2
    return 1
  fi
  echo "guid(${id})"
}

_limineKernelVolume() {
  if [[ -n "$L_XBOOT" ]]; then
    _limineGuid "$L_XBOOT"
  else
    echo "boot()"
  fi
}

_limineWindowsEntries() {
  local esp="$1" other volume
  if [[ -f "${MNT}${esp}/${WINDOWS_LOADER}" ]]; then
    printf '\n/Windows\n    protocol: efi\n    path: boot():/%s\n' "$WINDOWS_LOADER"
  fi
  for other in $W_OTHER_ESPS; do
    volume="$(_limineGuid "$other")" || return 1
    printf '\n/Windows (%s)\n    protocol: efi\n    path: %s:/%s\n' "$(basename "$other")" "$volume" "$WINDOWS_LOADER"
  done
}

_limineKernelEntry() {
  local heading="$1" volume="$2" initramfs="$3" cmdline="$4"
  cat <<EOF
${heading}
    protocol: linux
    kernel_path: ${volume}:/vmlinuz-linux
    module_path: ${volume}:/${initramfs}
    kernel_cmdline: ${cmdline}
EOF
}

_limineArchEntries() {
  local volume="$1" cmdline="$2" main="/Arch Linux" fallback="/Arch Linux (fallback initramfs)"
  if bootSnapperSelected; then
    echo "/+Arch Linux"
    main="//Linux"
    fallback="//Linux (fallback initramfs)"
  fi
  _limineKernelEntry "$main" "$volume" initramfs-linux.img "${cmdline} ${VERBOSE_CMDLINE}"
  echo
  _limineKernelEntry "$fallback" "$volume" initramfs-linux-fallback.img "$cmdline"
  if bootSnapperSelected; then
    printf '\n//Snapshots\n'
  fi
}

_limineConf() {
  local esp="$1" cmdline="$2" volume
  volume="$(_limineKernelVolume)" || return 1
  printf 'timeout: %s\nremember_last_entry: yes\n\n' "$LIMINE_TIMEOUT"
  _limineArchEntries "$volume" "$cmdline"
  _limineWindowsEntries "$esp" || return 1
}

_limineDirs() {
  echo "$LIMINE_DIR"
  if [[ "$A_MODE" == wipe ]]; then
    echo "$LIMINE_REMOVABLE_DIR"
  fi
}

_limineHook() {
  local esp="$1" dir copies=()
  while read -r dir; do
    copies+=("cp ${LIMINE_SRC} ${esp}/${dir}/")
  done < <(_limineDirs)
  writeFile "${MNT}${LIMINE_HOOK}" <<EOF
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = limine

[Action]
Description = Deploying the Limine EFI binary...
When = PostTransaction
Exec = /usr/bin/sh -c "$(printf '%s && ' "${copies[@]}" | sed 's/ && $//')"
EOF
}

_limineNvram() {
  local disk number
  if ((!DRY_RUN)) && efibootmgr 2>/dev/null | grep -qE "^Boot[0-9A-F]{4}\*? ${LIMINE_LABEL}([[:space:]]|$)"; then
    return 0
  fi
  disk="/dev/$(lsblk -no PKNAME "$L_ESP" 2>/dev/null | head -1 || true)"
  if [[ "$disk" == /dev/ ]] && ((!DRY_RUN)); then
    echo "cannot find the disk holding $L_ESP" >&2
    return 1
  fi
  number="$(cat "/sys/class/block/$(basename "$L_ESP")/partition" 2>/dev/null || echo 1)"
  run efibootmgr --create --disk "$disk" --part "$number" --label "$LIMINE_LABEL" --loader "$LIMINE_LOADER" --unicode
}

_limineScanDefaults() {
  local esp="$1" snapshots=""
  [[ "${A_LIMINE_SCAN:-no}" == yes ]] || bootSnapperSelected || return 0
  if bootSnapperSelected; then
    snapshots="MAX_SNAPSHOT_ENTRIES=${LIMINE_MAX_SNAPSHOT_ENTRIES}"
  fi
  writeFile "${MNT}${LIMINE_DEFAULTS}" <<EOF
ESP_PATH=${esp}
ENABLE_VERIFICATION=no
${snapshots}
EOF
}

bootLimine() {
  local esp cmdline conf dir
  esp="$(diskEspPath)"
  cmdline="$(bootCmdline)" || return 1
  conf="$(_limineConf "$esp" "$cmdline")" || return 1
  writeFile "${MNT}${esp}/${LIMINE_CONF}" <<<"$conf"
  while read -r dir; do
    run install -Dm644 "${MNT}${LIMINE_SRC}" "${MNT}${esp}/${dir}/BOOTX64.EFI"
  done < <(_limineDirs)
  _limineHook "$esp"
  _limineScanDefaults "$esp"
  _limineNvram
}

bootInstall() {
  case "$A_BOOT" in
    grub) bootGrub ;;
    limine) bootLimine ;;
    *) bootSystemdBoot ;;
  esac
}

bootNotes() {
  if [[ "$A_BOOT" == grub ]] && [[ -n "$W_OTHER_ESPS" || "$A_MODE" == alongside ]]; then
    echo "GRUB: if Windows is missing from the menu, run 'sudo grub-mkconfig -o ${GRUB_CFG}' after the first boot."
  fi
  if [[ "$A_BOOT" == systemd-boot && -n "$W_OTHER_ESPS" ]]; then
    echo "Windows is on another disk: pick it from the firmware boot menu, or boot 'EFI Shell', run 'map',"
    echo "note the alias of the Windows ESP (e.g. HD1b) and add /boot/loader/entries/windows.conf with"
    echo "'efi /shellx64.efi' and 'options -nointerrupt -nomap -noversion <alias>:EFI\\Microsoft\\Boot\\Bootmgfw.efi'."
  fi
  if bootSnapperSelected; then
    echo "Snapper: sys_update.sh (the bar's update button) takes a snapshot before each update, and limine-snapper-sync lists them under Arch Linux > Snapshots in the Limine menu."
  fi
  if [[ "$A_BOOT" == limine && "${A_LIMINE_SCAN:-no}" == yes ]]; then
    echo "Limine: run 'sudo limine-scan' after the first boot to add other EFI boot entries to the menu."
  fi
  if [[ "$A_MODE" == alongside ]]; then
    echo "Dual boot: Windows keeps the hardware clock in local time. In an admin prompt on Windows run"
    echo "'reg add HKLM\\SYSTEM\\CurrentControlSet\\Control\\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1 /f'."
  fi
  return 0
}
