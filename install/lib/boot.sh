#!/usr/bin/env bash

VERBOSE_CMDLINE="loglevel=7 systemd.show_status=1"
LSM_CMDLINE="lsm=landlock,lockdown,yama,integrity,apparmor,bpf"
SDBOOT_TIMEOUT=3
GRUB_TIMEOUT_SECONDS=5
GRUB_DEFAULTS="/etc/default/grub"
GRUB_HOOK="/etc/pacman.d/hooks/95-grub.hook"
GRUB_BOOTLOADER_ID="GRUB"
GRUB_CFG="/boot/grub/grub.cfg"
EDK2_SHELL_SRC="/usr/share/edk2-shell/x64/Shell.efi"
OS_PROBE_DIR="/mnt/osprobe"

W_OTHER_ESPS=""

bootPackages() {
  if [[ "$A_BOOT" == grub ]]; then
    printf '%s\n' grub efibootmgr os-prober fuse3 ntfs-3g
  elif [[ -n "$W_OTHER_ESPS" ]]; then
    echo edk2-shell
  fi
  return 0
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

bootInstall() {
  if [[ "$A_BOOT" == grub ]]; then
    bootGrub
  else
    bootSystemdBoot
  fi
}

bootNotes() {
  if [[ "$A_BOOT" == grub ]] && [[ -n "$W_OTHER_ESPS" || "$A_MODE" == alongside ]]; then
    echo "GRUB: if Windows is missing from the menu, run 'sudo grub-mkconfig -o ${GRUB_CFG}' after the first boot."
  fi
  if [[ "$A_BOOT" != grub && -n "$W_OTHER_ESPS" ]]; then
    echo "Windows is on another disk: pick it from the firmware boot menu, or boot 'EFI Shell', run 'map',"
    echo "note the alias of the Windows ESP (e.g. HD1b) and add /boot/loader/entries/windows.conf with"
    echo "'efi /shellx64.efi' and 'options -nointerrupt -nomap -noversion <alias>:EFI\\Microsoft\\Boot\\Bootmgfw.efi'."
  fi
  if [[ "$A_MODE" == alongside ]]; then
    echo "Dual boot: Windows keeps the hardware clock in local time. In an admin prompt on Windows run"
    echo "'reg add HKLM\\SYSTEM\\CurrentControlSet\\Control\\TimeZoneInformation /v RealTimeIsUniversal /t REG_DWORD /d 1 /f'."
  fi
  return 0
}
