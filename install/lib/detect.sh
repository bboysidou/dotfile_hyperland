#!/usr/bin/env bash

EFIVARS_DIR="/sys/firmware/efi/efivars"
SECURE_BOOT_VAR="${EFIVARS_DIR}/SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c"
SECURE_BOOT_VALUE_OFFSET=4

NVIDIA_OPEN_CODENAMES="TU|GA|AD|GB|GH"
NVIDIA_580XX_CODENAMES="GM|GP|GV"
NVIDIA_LEGACY_CODENAMES="GK|GF|GT|G[0-9]"

D_CPU=none
D_VIRT=none
D_LAPTOP=0
D_UEFI=0
D_SECURE_BOOT=0
D_NVIDIA=none

detectCpu() {
  case "$(grep -m1 '^vendor_id' /proc/cpuinfo | awk '{print $3}')" in
    GenuineIntel) D_CPU=intel ;;
    AuthenticAMD) D_CPU=amd ;;
    *) D_CPU=none ;;
  esac
}

detectVirt() {
  D_VIRT="$(systemd-detect-virt 2>/dev/null || true)"
  D_VIRT="${D_VIRT:-none}"
}

detectLaptop() {
  D_LAPTOP=0
  if compgen -G '/sys/class/power_supply/BAT*' >/dev/null; then
    D_LAPTOP=1
  fi
}

detectFirmware() {
  D_UEFI=0
  D_SECURE_BOOT=0
  if [[ -d "$EFIVARS_DIR" ]]; then
    D_UEFI=1
  fi
  if [[ -r "$SECURE_BOOT_VAR" ]] &&
    [[ "$(od -An -t u1 -j "$SECURE_BOOT_VALUE_OFFSET" -N1 "$SECURE_BOOT_VAR" | tr -d ' ')" == 1 ]]; then
    D_SECURE_BOOT=1
  fi
}

nvidiaDriverFor() {
  local entry="$1"
  if [[ "$entry" =~ NVIDIA\ Corporation\ (${NVIDIA_OPEN_CODENAMES})[0-9] ]]; then
    echo open
  elif [[ "$entry" =~ NVIDIA\ Corporation\ (${NVIDIA_580XX_CODENAMES})[0-9] ]]; then
    echo 580xx
  elif [[ "$entry" =~ NVIDIA\ Corporation\ (${NVIDIA_LEGACY_CODENAMES})[0-9] ]]; then
    echo nouveau
  else
    echo open
  fi
}

detectNvidia() {
  local entry
  D_NVIDIA=none
  entry="$(grep -m1 '\[10de:' <<<"$G_LIST" || true)"
  if [[ -n "$entry" ]]; then
    D_NVIDIA="$(nvidiaDriverFor "$entry")"
  fi
}

detectAll() {
  detectCpu
  detectVirt
  detectLaptop
  detectFirmware
  detectGpu
  detectNvidia
}
