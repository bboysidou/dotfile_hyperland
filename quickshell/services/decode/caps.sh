#!/bin/sh
set -u

SYS="${QS_DECODE_SYSFS:-/sys}"
DRI_DRIVERS=/usr/lib/dri
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/quickshell/decode-caps.tsv"
UNKNOWN=-
NONE=none
MODERN_CODEC=av1
LEGACY_CODECS=" mpeg2 vc1 "

codecs_of() {
    command -v vainfo >/dev/null 2>&1 || { echo "$UNKNOWN"; return; }
    [ -e "$1" ] || { echo "$UNKNOWN"; return; }
    vainfo --display drm --device "$1" 2>/dev/null | awk -v none="$NONE" '
        /VAEntrypointVLD/ {
            if ($1 ~ /^VAProfileH264/) found["h264"] = 1
            else if ($1 ~ /^VAProfileHEVC/) found["hevc"] = 1
            else if ($1 ~ /^VAProfileVP8/) found["vp8"] = 1
            else if ($1 ~ /^VAProfileVP9/) found["vp9"] = 1
            else if ($1 ~ /^VAProfileAV1/) found["av1"] = 1
            else if ($1 ~ /^VAProfileMPEG2/) found["mpeg2"] = 1
            else if ($1 ~ /^VAProfileVC1/) found["vc1"] = 1
        }
        END {
            n = split("h264 hevc vp8 vp9 av1 mpeg2 vc1", order, " ")
            out = ""
            for (i = 1; i <= n; i++) if (order[i] in found) out = out (out == "" ? "" : ",") order[i]
            print out == "" ? none : out
        }'
}

cache_key() {
    printf '%s:%s:%s' "$(cat "$1/vendor" 2>/dev/null)" "$(cat "$1/device" 2>/dev/null)" "$(stat -c %Y "$DRI_DRIVERS" 2>/dev/null)"
}

cached() {
    [ -r "$CACHE" ] && awk -F'\t' -v pci="$1" -v key="$2" '$1 == pci && $2 == key { print $3; exit }' "$CACHE"
}

remember() {
    mkdir -p "${CACHE%/*}"
    { [ -r "$CACHE" ] && awk -F'\t' -v pci="$1" '$1 != pci' "$CACHE"; printf '%s\t%s\t%s\n' "$1" "$2" "$3"; } >"$CACHE.tmp" && mv -f "$CACHE.tmp" "$CACHE"
}

cards() {
    for dev in "$SYS"/bus/pci/devices/*; do
        case "$(cat "$dev/class" 2>/dev/null)" in 0x03*) ;; *) continue ;; esac
        pci=${dev##*/}
        key=$(cache_key "$dev")
        codecs=$(cached "$pci" "$key")
        if [ -z "$codecs" ] && [ "$(cat "$dev/power/runtime_status" 2>/dev/null)" != suspended ]; then
            node=$(ls -d "$dev"/drm/renderD* 2>/dev/null | head -n 1)
            codecs=$([ -n "$node" ] && codecs_of "/dev/dri/${node##*/}" || echo "$UNKNOWN")
            [ "$codecs" != "$UNKNOWN" ] && remember "$pci" "$key" "$codecs"
        fi
        printf '%s\t%s\n' "$pci" "${codecs:-$UNKNOWN}"
    done
}

covers() {
    case ",$1," in *",$2,"*) return 0 ;; esac
    return 1
}

should_pin() {
    integrated=$(codecs_of "$1")
    dedicated=$(codecs_of "$2")
    case "$integrated" in "$UNKNOWN" | "$NONE") return 1 ;; esac
    case "$dedicated" in
        "$NONE") return 0 ;;
        "$UNKNOWN")
            covers "$integrated" "$MODERN_CODEC"
            return
            ;;
    esac
    for codec in $(printf '%s' "$dedicated" | tr ',' ' '); do
        case "$LEGACY_CODECS" in *" $codec "*) continue ;; esac
        covers "$integrated" "$codec" || return 1
    done
    return 0
}

case "${1:-}" in
    cards) cards ;;
    node) codecs_of "${2:-}" ;;
    pin) should_pin "${2:-}" "${3:-}" ;;
    *)
        echo "usage: caps.sh cards | node RENDER_NODE | pin IGPU_NODE DGPU_NODE" >&2
        exit 2
        ;;
esac
