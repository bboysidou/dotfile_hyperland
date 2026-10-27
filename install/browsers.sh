#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
NVIDIA_VAAPI=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --nvidia-vaapi) NVIDIA_VAAPI=1 ;;
  esac
done

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DECODE_CAPS="${SCRIPT_DIR}/../quickshell/services/decode/caps.sh"
GPU_UDEV_RULE="/etc/udev/rules.d/90-gpu-dev-path.rules"
IGPU_RENDER_NODE="/dev/dri/igpu-render"
NVIDIA_FEATURE="VaapiOnNvidiaGPUs"

CHROMIUM_FLAGS=(
  "--ozone-platform-hint=auto"
  "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder,VaapiVideoDecodeLinuxGL,WaylandLinuxDrmSyncobj"
  "--enable-gpu-rasterization"
  "--enable-zero-copy"
  "--ignore-gpu-blocklist"
  "--password-store=gnome-libsecret"
)

_gpuPci() {
  sed -nE "s/.*KERNELS==\"([^\"]+)\".*SYMLINK\+=\"dri\/$1\"$/\\1/p" "$GPU_UDEV_RULE" 2>/dev/null | head -n 1
}

_pinIntegrated() {
  local igpu dgpu
  compgen -G "/sys/class/power_supply/BAT*" >/dev/null || return 1
  igpu="$(_gpuPci igpu)"
  dgpu="$(_gpuPci dgpu)"
  [[ -n "$igpu" && -n "$dgpu" && -r "$DECODE_CAPS" ]] || return 1
  sh "$DECODE_CAPS" pin "/dev/dri/by-path/pci-${igpu}-render" "/dev/dri/by-path/pci-${dgpu}-render"
}

_nvidiaRenders() {
  grep -qx 'LIBVA_DRIVER_NAME=nvidia' /etc/environment 2>/dev/null
}

_addFlags() {
  if ((NVIDIA_VAAPI)); then
    CHROMIUM_FLAGS[1]="${CHROMIUM_FLAGS[1]},${NVIDIA_FEATURE}"
  elif _nvidiaRenders; then
    echo "NVIDIA renders here: re-run with --nvidia-vaapi to try Chromium hardware decode (needs libva-nvidia-driver 0.0.18+)"
  fi
  if _pinIntegrated; then
    CHROMIUM_FLAGS+=("--render-node-override=${IGPU_RENDER_NODE}")
    echo "hybrid laptop: video decode pinned to the integrated GPU"
  fi
  return 0
}

_writeFlagsFile() {
  local target="$1" body
  body="$(printf '%s\n' "${CHROMIUM_FLAGS[@]}")"
  if ((DRY_RUN)); then
    echo "  [dry-run] would write ${target}:"
    sed 's/^/    /' <<<"$body"
  else
    printf '%s\n' "$body" >"$target"
    echo "wrote ${target}"
  fi
}

echo "============================================="
echo "-----| CHROMIUM / BRAVE HARDWARE ACCELERATION |-----"
echo "============================================="
_addFlags
_writeFlagsFile "${CONFIG_HOME}/chromium-flags.conf"
_writeFlagsFile "${CONFIG_HOME}/brave-flags.conf"

echo "============================================="
echo "-----| ZEN HARDWARE ACCELERATION |-----"
echo "============================================="

read -r -d '' ZEN_USER_JS <<'EOF' || true
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("media.rdd-ffmpeg.enabled", true);
user_pref("widget.dmabuf.force-enabled", true);
EOF

ZEN_ROOTS=("${HOME}/.zen" "${CONFIG_HOME}/zen")
found=0
for zen_root in "${ZEN_ROOTS[@]}"; do
  [[ -d "$zen_root" ]] || continue
  while IFS= read -r profile; do
    [[ -z "$profile" ]] && continue
    found=1
    target="${profile}/user.js"
    if ((DRY_RUN)); then
      echo "  [dry-run] would write ${target}"
    else
      printf '%s\n' "$ZEN_USER_JS" >"$target"
      echo "wrote ${target}"
    fi
  done < <(find "$zen_root" -maxdepth 1 -mindepth 1 -type d -name '*.*' 2>/dev/null)
done
((found)) || echo "no Zen profile found - install zen-browser-bin and launch it once, then re-run this script"
