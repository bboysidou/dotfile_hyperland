#!/usr/bin/env bash

GPU_UDEV_RULE="/etc/udev/rules.d/90-gpu-dev-path.rules"
GPU_MODPROBE="/etc/modprobe.d/nvidia.conf"
GPU_MKINITCPIO_DROPIN="/etc/mkinitcpio.conf.d/10-installer.conf"
GPU_DEFAULT_HOOKS="base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck"
MESA_EGL_VENDOR="/usr/share/glvnd/egl_vendor.d/50_mesa.json"
NVIDIA_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
NVIDIA_POWER_UNITS=(nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service)
OLD_INTEL_PATTERN='HD Graphics (2|3|4)[0-9]{3}|Ironlake|Sandybridge|Ivybridge|Haswell'

G_LIST=""
G_AMD=0
G_INTEL=0
G_NVIDIA=0
G_COUNT=0
G_IGPU=""
G_DGPU=""
G_HYBRID=0
G_PRIMARY=""
G_PRIMARY_VENDOR=unknown
G_LIBVA=""
G_VDPAU=""
G_OLD_INTEL=0
G_PKGS=()
G_AUR=()

_gpuVendorOf() {
  case "$1" in
    *'[10de:'*) echo nvidia ;;
    *'[8086:'*) echo intel ;;
    *'[1002:'*) echo amd ;;
    *) echo unknown ;;
  esac
}

_gpuEntry() {
  grep "^$1" <<<"$G_LIST" || true
}

_gpuIsBootVga() {
  local file="/sys/bus/pci/devices/$1/boot_vga"
  [[ -r "$file" && "$(cat "$file")" == 1 ]]
}

_gpuPickHybrid() {
  local pci
  for pci in "$@"; do
    if [[ "$(_gpuVendorOf "$(_gpuEntry "$pci")")" == nvidia ]]; then
      [[ -z "$G_DGPU" ]] && G_DGPU="$pci"
    elif _gpuIsBootVga "$pci"; then
      [[ -z "$G_IGPU" ]] && G_IGPU="$pci"
    fi
  done
  if [[ -z "$G_IGPU" ]]; then
    for pci in "$@"; do
      [[ "$(_gpuVendorOf "$(_gpuEntry "$pci")")" == nvidia || "$pci" == "$G_DGPU" ]] && continue
      if [[ "$pci" == *":00:"* ]]; then
        G_IGPU="$pci"
        break
      fi
      [[ -z "$G_IGPU" ]] && G_IGPU="$pci"
    done
  fi
  if [[ -z "$G_DGPU" ]]; then
    for pci in "$@"; do
      if [[ "$pci" != "$G_IGPU" ]]; then
        G_DGPU="$pci"
        break
      fi
    done
  fi
  return 0
}

detectGpu() {
  local line all=()
  G_LIST="${GPU_LIST_OVERRIDE:-$(lspci -D -nn -d ::03xx 2>/dev/null || true)}"
  G_AMD=0 G_INTEL=0 G_NVIDIA=0 G_IGPU="" G_DGPU="" G_HYBRID=0 G_OLD_INTEL=0
  if grep -q '\[1002:' <<<"$G_LIST"; then G_AMD=1; fi
  if grep -q '\[8086:' <<<"$G_LIST"; then G_INTEL=1; fi
  if grep -q '\[10de:' <<<"$G_LIST"; then G_NVIDIA=1; fi
  while read -r line; do
    [[ -n "$line" ]] && all+=("${line%% *}")
  done <<<"$G_LIST"
  G_COUNT="${#all[@]}"
  if ((G_COUNT > 1)); then
    _gpuPickHybrid "${all[@]}"
  else
    G_IGPU="${all[0]:-}"
  fi
  if [[ -n "$G_IGPU" && -n "$G_DGPU" && "$G_IGPU" != "$G_DGPU" ]]; then
    G_HYBRID=1
  fi
  G_PRIMARY="${G_IGPU:-$G_DGPU}"
  G_PRIMARY_VENDOR="$(_gpuVendorOf "$(_gpuEntry "$G_PRIMARY")")"
  case "$G_PRIMARY_VENDOR" in
    intel) G_LIBVA=iHD G_VDPAU=va_gl ;;
    amd) G_LIBVA=radeonsi G_VDPAU=radeonsi ;;
    nvidia) G_LIBVA=nvidia G_VDPAU=nvidia ;;
    *) G_LIBVA="" G_VDPAU="" ;;
  esac
  if ((G_INTEL)) && grep -qiE "$OLD_INTEL_PATTERN" <<<"$G_LIST"; then
    G_OLD_INTEL=1
    if [[ "$G_PRIMARY_VENDOR" == intel ]]; then G_LIBVA=i965; fi
  fi
  return 0
}

gpuNvidiaProprietary() {
  [[ "${A_NVIDIA:-none}" == open || "${A_NVIDIA:-none}" == 580xx ]]
}

_gpuVirtPackages() {
  case "$D_VIRT" in
    kvm | qemu) G_PKGS+=(qemu-guest-agent spice-vdagent) ;;
    vmware) G_PKGS+=(open-vm-tools) ;;
    oracle) G_PKGS+=(virtualbox-guest-utils) ;;
    microsoft) G_PKGS+=(hyperv) ;;
  esac
  return 0
}

_gpuNvidiaPackages() {
  case "${A_NVIDIA:-none}" in
    open) G_PKGS+=(nvidia-open-dkms nvidia-utils lib32-nvidia-utils egl-wayland libva-nvidia-driver) ;;
    580xx)
      G_PKGS+=(egl-wayland libva-nvidia-driver)
      G_AUR+=(nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils)
      ;;
    nouveau) G_PKGS+=(vulkan-nouveau lib32-vulkan-nouveau) ;;
  esac
  if ((G_HYBRID)) && gpuNvidiaProprietary; then
    G_PKGS+=(nvidia-prime)
  fi
  return 0
}

gpuPackages() {
  G_PKGS=()
  G_AUR=()
  if [[ "$D_VIRT" != none ]]; then
    _gpuVirtPackages
    return 0
  fi
  if ((G_AMD)); then
    G_PKGS+=(vulkan-radeon lib32-vulkan-radeon lib32-mesa amdgpu_top)
  fi
  if ((G_INTEL)); then
    G_PKGS+=(vulkan-intel lib32-vulkan-intel lib32-mesa intel-gpu-tools)
    if ((G_OLD_INTEL)); then
      G_PKGS+=(libva-intel-driver)
    else
      G_PKGS+=(intel-media-driver)
    fi
  fi
  if ((G_NVIDIA)); then
    _gpuNvidiaPackages
  fi
  return 0
}

_gpuUdevRule() {
  printf 'KERNEL=="card*", KERNELS=="%s", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/%s"\n' "$2" "$1"
  printf 'KERNEL=="renderD*", KERNELS=="%s", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/%s-render"\n' "$2" "$1"
}

_gpuInitcpioModules() {
  local modules="btrfs"
  if gpuNvidiaProprietary; then
    if ((G_INTEL)); then modules+=" i915"; fi
    if ((G_AMD)); then modules+=" amdgpu"; fi
    modules+=" ${NVIDIA_MODULES}"
  fi
  echo "$modules"
}

_gpuInitcpioHooks() {
  local hooks conf="${MNT}/etc/mkinitcpio.conf"
  hooks="$(sed -nE 's/^HOOKS=\((.*)\)/\1/p' "$conf" 2>/dev/null || true)"
  hooks="${hooks:-$GPU_DEFAULT_HOOKS}"
  if gpuNvidiaProprietary; then
    hooks="$(tr ' ' '\n' <<<"$hooks" | grep -vx kms | tr '\n' ' ' | sed 's/ *$//')"
  fi
  echo "$hooks"
}

gpuConfigureSystem() {
  writeFile "${MNT}${GPU_MKINITCPIO_DROPIN}" <<EOF
MODULES=($(_gpuInitcpioModules))
HOOKS=($(_gpuInitcpioHooks))
EOF
  if gpuNvidiaProprietary; then
    writeFile "${MNT}${GPU_MODPROBE}" <<<"options nvidia_drm modeset=1"
  fi
  if ((G_HYBRID)); then
    {
      _gpuUdevRule igpu "$G_IGPU"
      _gpuUdevRule dgpu "$G_DGPU"
    } | writeFile "${MNT}${GPU_UDEV_RULE}"
  fi
  if [[ -n "$G_LIBVA" ]]; then
    writeFile "${MNT}/etc/environment" <<EOF
LIBVA_DRIVER_NAME=${G_LIBVA}
VDPAU_DRIVER=${G_VDPAU}
MOZ_DISABLE_RDD_SANDBOX=1
EOF
  fi
  return 0
}

gpuEnablePowerUnits() {
  if gpuNvidiaProprietary; then
    inChroot systemctl enable "${NVIDIA_POWER_UNITS[@]}"
  fi
  return 0
}

gpuEnvLua() {
  echo "-- generated by install.sh - do not edit by hand"
  if [[ -n "$G_LIBVA" ]]; then echo "hl.env(\"LIBVA_DRIVER_NAME\", \"${G_LIBVA}\")"; fi
  if [[ -n "$G_VDPAU" ]]; then echo "hl.env(\"VDPAU_DRIVER\", \"${G_VDPAU}\")"; fi
  echo 'hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")'
  if gpuNvidiaProprietary; then
    echo 'hl.env("NVD_BACKEND", "direct")'
    if [[ "$G_PRIMARY_VENDOR" == nvidia ]]; then
      echo 'hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")'
    else
      echo 'hl.env("AQ_FORCE_LINEAR_BLIT", "0")'
    fi
  fi
  if ((G_HYBRID)); then
    echo 'hl.env("AQ_DRM_DEVICES", "/dev/dri/igpu:/dev/dri/dgpu")'
    echo 'hl.env("MOZ_WAYLAND_DRM_DEVICE", "/dev/dri/igpu-render")'
  fi
  return 0
}

gpuConfigureUser() {
  local repo="$1"
  gpuEnvLua | writeFile "${repo}/hypr/config/env-gpu.lua"
  if ((G_HYBRID)) && [[ "$G_PRIMARY_VENDOR" != nvidia ]]; then
    writeFile "${repo}/systemd/user/quickshell.service.d/gpu.conf" <<EOF
[Service]
Environment=__EGL_VENDOR_LIBRARY_FILENAMES=${MESA_EGL_VENDOR}
EOF
  fi
  return 0
}

gpuDescribe() {
  local vendors=()
  if ((G_AMD)); then vendors+=(AMD); fi
  if ((G_INTEL)); then vendors+=(Intel); fi
  if ((G_NVIDIA)); then vendors+=("NVIDIA (${A_NVIDIA:-$D_NVIDIA})"); fi
  if ((${#vendors[@]} == 0)); then vendors+=("none detected"); fi
  printf '%s' "${vendors[*]}"
  if ((G_HYBRID)); then printf ' · hybrid, renders on %s' "$G_PRIMARY_VENDOR"; fi
  return 0
}
