#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/core/packages.sh"

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

HYPR_ENV_FILE="${HOME}/.config/hypr/config/env-gpu.lua"
UDEV_RULE="/etc/udev/rules.d/90-gpu-dev-path.rules"

_run() {
  if ((DRY_RUN)); then
    echo "  [dry-run] $*"
  else
    "$@"
  fi
}

_installPackages() {
  (($# == 0)) && return 0
  if ((DRY_RUN)); then
    printf '  [dry-run] pacman -S --needed %s\n' "$*"
  else
    sudo pacman -S --noconfirm --needed "$@"
  fi
}

# ---------- DETECTION ----------

case "$(grep -m1 '^vendor_id' /proc/cpuinfo | awk '{print $3}')" in
  GenuineIntel) CPU_VENDOR="intel" ;;
  AuthenticAMD) CPU_VENDOR="amd" ;;
  *)            CPU_VENDOR="unknown" ;;
esac

GPU_LIST="${GPU_LIST_OVERRIDE:-$(lspci -D -nn -d ::03xx)}"

HAS_AMD=0
HAS_INTEL=0
HAS_NVIDIA=0
grep -q '\[1002:' <<<"$GPU_LIST" && HAS_AMD=1
grep -q '\[8086:' <<<"$GPU_LIST" && HAS_INTEL=1
grep -q '\[10de:' <<<"$GPU_LIST" && HAS_NVIDIA=1

_vendorOfEntry() {
  case "$1" in
    *'[10de:'*) echo "nvidia" ;;
    *'[8086:'*) echo "intel" ;;
    *'[1002:'*) echo "amd" ;;
    *)          echo "unknown" ;;
  esac
}

_isBootVga() {
  local f="/sys/bus/pci/devices/$1/boot_vga"
  [[ -r "$f" && "$(cat "$f")" == "1" ]]
}

ALL_PCI=()
while read -r line; do
  [[ -z "$line" ]] && continue
  ALL_PCI+=("${line%% *}")
done <<<"$GPU_LIST"

GPU_COUNT="${#ALL_PCI[@]}"

IGPU_PCI=""
DGPU_PCI=""

if ((GPU_COUNT > 1)); then
  for pci in "${ALL_PCI[@]}"; do
    entry="$(grep "^$pci" <<<"$GPU_LIST")"
    if [[ "$(_vendorOfEntry "$entry")" == "nvidia" ]]; then
      [[ -z "$DGPU_PCI" ]] && DGPU_PCI="$pci"
    elif _isBootVga "$pci"; then
      [[ -z "$IGPU_PCI" ]] && IGPU_PCI="$pci"
    fi
  done

  if [[ -z "$IGPU_PCI" ]]; then
    for pci in "${ALL_PCI[@]}"; do
      entry="$(grep "^$pci" <<<"$GPU_LIST")"
      [[ "$(_vendorOfEntry "$entry")" == "nvidia" ]] && continue
      [[ "$pci" == "$DGPU_PCI" ]] && continue
      if [[ "$pci" == *":00:"* ]]; then IGPU_PCI="$pci"; break; fi
      [[ -z "$IGPU_PCI" ]] && IGPU_PCI="$pci"
    done
  fi

  if [[ -z "$DGPU_PCI" ]]; then
    for pci in "${ALL_PCI[@]}"; do
      [[ "$pci" != "$IGPU_PCI" ]] && { DGPU_PCI="$pci"; break; }
    done
  fi
else
  IGPU_PCI="${ALL_PCI[0]:-}"
fi

IS_HYBRID=0
[[ -n "$IGPU_PCI" && -n "$DGPU_PCI" && "$IGPU_PCI" != "$DGPU_PCI" ]] && IS_HYBRID=1

PRIMARY_PCI="${IGPU_PCI:-$DGPU_PCI}"

_vendorOf() {
  local entry
  entry="$(grep "^$1" <<<"$GPU_LIST")"
  case "$entry" in
    *'[10de:'*) echo "nvidia" ;;
    *'[8086:'*) echo "intel" ;;
    *'[1002:'*) echo "amd" ;;
    *)          echo "unknown" ;;
  esac
}

PRIMARY_VENDOR="$(_vendorOf "$PRIMARY_PCI")"

case "$PRIMARY_VENDOR" in
  intel)  LIBVA_DRIVER="iHD"; DRI_BACKEND="iris"; VDPAU_DRIVER="va_gl" ;;
  amd)    LIBVA_DRIVER="radeonsi"; DRI_BACKEND="radeonsi"; VDPAU_DRIVER="radeonsi" ;;
  nvidia) LIBVA_DRIVER="nvidia"; DRI_BACKEND="nvidia"; VDPAU_DRIVER="nvidia" ;;
esac

if ((HAS_INTEL)); then
  if grep -qiE 'HD Graphics (2|3|4)[0-9]{3}|Ironlake|Sandybridge|Ivybridge|Haswell' <<<"$GPU_LIST"; then
    gpu_intel=("${gpu_intel[@]/intel-media-driver/libva-intel-driver}")
    [[ "$PRIMARY_VENDOR" == "intel" ]] && LIBVA_DRIVER="i965"
  fi
fi

echo "============================================="
echo "-----| HARDWARE DETECTED |-----"
echo "============================================="
echo "CPU vendor      : ${CPU_VENDOR}"
echo "GPUs found      : ${GPU_COUNT}"
sed 's/^/  /' <<<"$GPU_LIST"
echo "AMD / Intel / NVIDIA : ${HAS_AMD} / ${HAS_INTEL} / ${HAS_NVIDIA}"
echo "Hybrid          : ${IS_HYBRID}"
echo "Primary (render): ${PRIMARY_PCI} (${PRIMARY_VENDOR})"
((IS_HYBRID)) && echo "Secondary       : ${DGPU_PCI} ($(_vendorOf "$DGPU_PCI"))"
echo "LIBVA_DRIVER_NAME: ${LIBVA_DRIVER}"

# ---------- MULTILIB ----------

echo "============================================="
echo "-----| ENABLE MULTILIB |-----"
echo "============================================="
if grep -q '^\[multilib\]' /etc/pacman.conf; then
  echo "multilib already enabled"
else
  _run sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
  _run sudo pacman -Sy --noconfirm
fi

# ---------- PACKAGES ----------

echo "============================================="
echo "-----| INSTALL MICROCODE |-----"
echo "============================================="
case "$CPU_VENDOR" in
  amd)   _installPackages "${cpu_amd[@]}" ;;
  intel) _installPackages "${cpu_intel[@]}" ;;
  *)     echo "Unknown CPU vendor - skipping microcode" ;;
esac

echo "============================================="
echo "-----| INSTALL GPU DRIVERS |-----"
echo "============================================="
((HAS_AMD)) && _installPackages "${gpu_amd[@]}"
((HAS_INTEL)) && _installPackages "${gpu_intel[@]}"

if ((HAS_NVIDIA)); then
  KERNEL_HEADERS="linux-headers"
  pacman -Q linux-zen &>/dev/null && KERNEL_HEADERS="linux-zen-headers"
  pacman -Q linux-lts &>/dev/null && KERNEL_HEADERS="linux-lts-headers"
  pacman -Q linux-hardened &>/dev/null && KERNEL_HEADERS="linux-hardened-headers"

  _installPackages "$KERNEL_HEADERS" nvidia-open-dkms "${gpu_nvidia[@]}"

  echo "-----| NVIDIA EARLY KMS |-----"
  ((DRY_RUN)) || echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null

  MKINITCPIO_CONF="/etc/mkinitcpio.conf"
  NVIDIA_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
  ((HAS_INTEL)) && NVIDIA_MODULES="i915 ${NVIDIA_MODULES}"
  ((HAS_AMD)) && NVIDIA_MODULES="amdgpu ${NVIDIA_MODULES}"

  if ((DRY_RUN)); then
    echo "  [dry-run] MODULES += ${NVIDIA_MODULES}"
  else
    sudo cp "$MKINITCPIO_CONF" "${MKINITCPIO_CONF}.backup"
    sudo sed -i -E 's/ ?\b(i915|amdgpu|nvidia|nvidia_modeset|nvidia_uvm|nvidia_drm)\b//g' "$MKINITCPIO_CONF"
    sudo sed -i -E "s/MODULES=\(([^)]*)\)/MODULES=(${NVIDIA_MODULES} \1)/" "$MKINITCPIO_CONF"
    sudo sed -i -E 's/  +/ /g; s/\( /(/g; s/ \)/)/g' "$MKINITCPIO_CONF"
    sudo mkinitcpio -P
  fi
fi

# ---------- STABLE DEVICE PATHS ----------

_udevRule() {
  local name="$1" pci="$2"
  printf 'KERNEL=="card*", KERNELS=="%s", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/%s"\n' "$pci" "$name"
  printf 'KERNEL=="renderD*", KERNELS=="%s", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/%s-render"\n' "$pci" "$name"
}

if ((IS_HYBRID)); then
  echo "============================================="
  echo "-----| STABLE GPU DEVICE PATHS |-----"
  echo "============================================="
  RULE_BODY="$(_udevRule igpu "$IGPU_PCI"; _udevRule dgpu "$DGPU_PCI")"
  if ((DRY_RUN)); then
    echo "  [dry-run] would write ${UDEV_RULE}:"
    sed 's/^/    /' <<<"$RULE_BODY"
  else
    sudo tee "$UDEV_RULE" >/dev/null <<<"$RULE_BODY"
    sudo udevadm control --reload
    sudo udevadm trigger
  fi
  AQ_DRM_DEVICES="/dev/dri/igpu:/dev/dri/dgpu"
  IGPU_RENDER_NODE="/dev/dri/igpu-render"
else
  AQ_DRM_DEVICES=""
  IGPU_RENDER_NODE=""
fi

# ---------- HYPRLAND ENV ----------

echo "============================================="
echo "-----| WRITE HYPRLAND GPU ENV |-----"
echo "============================================="
ENV_LUA="-- generated by install/gpu.sh - do not edit by hand
hl.env(\"LIBVA_DRIVER_NAME\", \"${LIBVA_DRIVER}\")
hl.env(\"VDPAU_DRIVER\", \"${VDPAU_DRIVER}\")
hl.env(\"DRI_BACKEND\", \"${DRI_BACKEND}\")
hl.env(\"ELECTRON_OZONE_PLATFORM_HINT\", \"auto\")
"

if ((HAS_NVIDIA)); then
  ENV_LUA+="hl.env(\"NVD_BACKEND\", \"direct\")
"
  if [[ "$PRIMARY_VENDOR" == "nvidia" ]]; then
    ENV_LUA+="hl.env(\"__GLX_VENDOR_LIBRARY_NAME\", \"nvidia\")
"
  else
    ENV_LUA+="hl.env(\"AQ_FORCE_LINEAR_BLIT\", \"0\")
"
  fi
fi

if [[ -n "$AQ_DRM_DEVICES" ]]; then
  ENV_LUA+="hl.env(\"AQ_DRM_DEVICES\", \"${AQ_DRM_DEVICES}\")
"
fi

if [[ -n "$IGPU_RENDER_NODE" ]]; then
  ENV_LUA+="hl.env(\"MOZ_WAYLAND_DRM_DEVICE\", \"${IGPU_RENDER_NODE}\")
"
fi

if ((DRY_RUN)); then
  echo "  [dry-run] would write ${HYPR_ENV_FILE}:"
  sed 's/^/    /' <<<"$ENV_LUA"
else
  mkdir -p "$(dirname "$HYPR_ENV_FILE")"
  printf '%s' "$ENV_LUA" >"$HYPR_ENV_FILE"
  echo "wrote ${HYPR_ENV_FILE}"
fi

# ---------- SYSTEM ENV ----------

echo "============================================="
echo "-----| WRITE /etc/environment |-----"
echo "============================================="
SYS_ENV="LIBVA_DRIVER_NAME=${LIBVA_DRIVER}
VDPAU_DRIVER=${VDPAU_DRIVER}
MOZ_DISABLE_RDD_SANDBOX=1
"
if ((DRY_RUN)); then
  echo "  [dry-run] would write /etc/environment:"
  sed 's/^/    /' <<<"$SYS_ENV"
else
  sudo tee /etc/environment >/dev/null <<<"$SYS_ENV"
fi

echo "GPU setup complete"
