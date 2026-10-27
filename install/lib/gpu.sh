#!/usr/bin/env bash

GPU_UDEV_RULE="/etc/udev/rules.d/90-gpu-dev-path.rules"
GPU_MODPROBE="/etc/modprobe.d/nvidia.conf"
GPU_MKINITCPIO_DROPIN="/etc/mkinitcpio.conf.d/10-installer.conf"
GPU_DEFAULT_HOOKS="base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck"
MESA_EGL_VENDOR="/usr/share/glvnd/egl_vendor.d/50_mesa.json"
NVIDIA_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
NVIDIA_POWER_UNITS=(nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service nvidia-suspend-then-hibernate.service)
NVIDIA_RTD3_CODENAMES="TU"
NVIDIA_RTD3_OPTION="options nvidia NVreg_DynamicPowerManagement=0x02"
NVIDIA_RTD3_UDEV_RULE="/etc/udev/rules.d/80-nvidia-rtd3.rules"
VIRGL_DMESG_PATTERN='virtio_gpu.*features: \+virgl'
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

_gpuPickDesktop() {
  local pci boot=""
  for pci in "$@"; do
    if _gpuIsBootVga "$pci"; then
      boot="$pci"
      break
    fi
  done
  [[ -n "$boot" ]] || return 1
  G_IGPU="$boot"
  for pci in "$@"; do
    if [[ "$pci" != "$boot" ]]; then
      G_DGPU="$pci"
      break
    fi
  done
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
    if ((D_LAPTOP)) || ! _gpuPickDesktop "${all[@]}"; then
      _gpuPickHybrid "${all[@]}"
    fi
  else
    G_IGPU="${all[0]:-}"
  fi
  if [[ -n "$G_IGPU" && -n "$G_DGPU" && "$G_IGPU" != "$G_DGPU" ]]; then
    G_HYBRID=1
  fi
  G_PRIMARY="${G_IGPU:-$G_DGPU}"
  G_PRIMARY_VENDOR="$(_gpuVendorOf "$(_gpuEntry "$G_PRIMARY")")"
  if ((G_INTEL)) && grep -qiE "$OLD_INTEL_PATTERN" <<<"$G_LIST"; then
    G_OLD_INTEL=1
  fi
  return 0
}

gpuNvidiaProprietary() {
  [[ "${A_NVIDIA:-none}" == open || "${A_NVIDIA:-none}" == 580xx ]]
}

_gpuNvidiaRenders() {
  gpuNvidiaProprietary && [[ "$G_PRIMARY_VENDOR" == nvidia ]]
}

_gpuKernelDriver() {
  local link="/sys/bus/pci/devices/$1/driver"
  if [[ -L "$link" ]]; then
    basename "$(readlink "$link")"
    return 0
  fi
  case "$(_gpuVendorOf "$(_gpuEntry "$1")")" in
    intel) echo i915 ;;
    amd) echo amdgpu ;;
  esac
  return 0
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
    open) G_PKGS+=(nvidia-open-dkms nvidia-utils lib32-nvidia-utils egl-wayland libva-nvidia-driver vdpauinfo) ;;
    580xx)
      G_PKGS+=(egl-wayland libva-nvidia-driver vdpauinfo)
      G_AUR+=(nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils)
      ;;
    nouveau) G_PKGS+=(vulkan-nouveau lib32-vulkan-nouveau) ;;
  esac
  if ((G_HYBRID)) && gpuNvidiaProprietary && [[ "$G_PRIMARY_VENDOR" != nvidia ]]; then
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
  local modules="btrfs" pci driver
  if gpuNvidiaProprietary; then
    for pci in "$G_IGPU" "$G_DGPU"; do
      [[ -n "$pci" ]] || continue
      [[ "$(_gpuVendorOf "$(_gpuEntry "$pci")")" == nvidia ]] && continue
      driver="$(_gpuKernelDriver "$pci")"
      case "$driver" in
        i915 | xe | amdgpu | radeon) [[ " $modules " == *" $driver "* ]] || modules+=" $driver" ;;
      esac
    done
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

gpuNvidiaManualRtd3() {
  ((G_HYBRID && D_LAPTOP)) && gpuNvidiaProprietary &&
    [[ "$(_gpuEntry "$G_DGPU")" =~ NVIDIA\ Corporation\ (${NVIDIA_RTD3_CODENAMES})[0-9] ]]
}

_gpuRtd3Udev() {
  echo 'ACTION=="add|bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", TEST=="power/control", ATTR{power/control}="auto"'
  echo 'ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", TEST=="power/control", ATTR{power/control}="on"'
}

gpuConfigureSystem() {
  writeFile "${MNT}${GPU_MKINITCPIO_DROPIN}" <<EOF
MODULES=($(_gpuInitcpioModules))
HOOKS=($(_gpuInitcpioHooks))
EOF
  if gpuNvidiaProprietary; then
    {
      echo "options nvidia_drm modeset=1"
      if gpuNvidiaManualRtd3; then echo "$NVIDIA_RTD3_OPTION"; fi
    } | writeFile "${MNT}${GPU_MODPROBE}"
  fi
  if gpuNvidiaManualRtd3; then
    _gpuRtd3Udev | writeFile "${MNT}${NVIDIA_RTD3_UDEV_RULE}"
  fi
  if ((G_HYBRID)); then
    {
      _gpuUdevRule igpu "$G_IGPU"
      _gpuUdevRule dgpu "$G_DGPU"
    } | writeFile "${MNT}${GPU_UDEV_RULE}"
  fi
  if _gpuNvidiaRenders; then
    writeFile "${MNT}/etc/environment" <<'EOF'
LIBVA_DRIVER_NAME=nvidia
VDPAU_DRIVER=nvidia
MOZ_DISABLE_RDD_SANDBOX=1
EOF
  fi
  return 0
}

gpuEnablePowerUnits() {
  local unit
  [[ "${A_NVIDIA:-none}" == 580xx ]] || return 0
  for unit in "${NVIDIA_POWER_UNITS[@]}"; do
    if ((DRY_RUN)) || [[ -e "${MNT}/usr/lib/systemd/system/${unit}" ]]; then
      inChroot systemctl enable "$unit"
    fi
  done
  return 0
}

gpuEnvLua() {
  echo "-- generated by install.sh - do not edit by hand"
  if _gpuNvidiaRenders; then
    echo 'hl.env("LIBVA_DRIVER_NAME", "nvidia")'
    echo 'hl.env("VDPAU_DRIVER", "nvidia")'
  fi
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

gpuWarnVirtual() {
  [[ "$D_VIRT" != none ]] || return 0
  if dmesg 2>/dev/null | grep -qE "$VIRGL_DMESG_PATTERN"; then return 0; fi
  uiWarn "Virtual machine (${D_VIRT}): Hyprland starts only with 3D acceleration on."
  uiInfo "virt-manager: Video Virtio with 3D acceleration, SPICE display with OpenGL."
  uiInfo "VirtualBox: VMSVGA with Enable 3D Acceleration. VMware: Accelerate 3D graphics."
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
