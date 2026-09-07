#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

CHROMIUM_FLAGS=(
  "--ozone-platform-hint=auto"
  "--enable-features=AcceleratedVideoDecodeLinuxGL,AcceleratedVideoEncoder,VaapiVideoDecodeLinuxGL,WaylandLinuxDrmSyncobj"
  "--enable-gpu-rasterization"
  "--enable-zero-copy"
  "--ignore-gpu-blocklist"
)

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
_writeFlagsFile "${CONFIG_HOME}/chromium-flags.conf"
_writeFlagsFile "${CONFIG_HOME}/brave-flags.conf"

echo "============================================="
echo "-----| ZEN HARDWARE ACCELERATION |-----"
echo "============================================="

read -r -d '' ZEN_USER_JS <<'EOF' || true
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("media.rdd-ffmpeg.enabled", true);
user_pref("gfx.webrender.all", true);
user_pref("widget.dmabuf.force-enabled", true);
EOF

ZEN_ROOT="${CONFIG_HOME}/zen"
if [[ -d "$ZEN_ROOT" ]]; then
  found=0
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
  done < <(find "$ZEN_ROOT" -maxdepth 1 -mindepth 1 -type d -name '*.*' 2>/dev/null)
  ((found)) || echo "no Zen profile found - launch Zen once, then re-run this script"
else
  echo "Zen not installed yet - re-run this script after installing zen-browser-bin"
fi
