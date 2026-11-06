pragma Singleton

import Quickshell

Singleton {
    id: root

    readonly property var appScope: ["systemd-run", "--user", "--scope", "--collect", "--quiet", "--slice=app.slice"]
    readonly property string appDirectoryFlag: "--working-directory=%1"
    readonly property string endOfOptions: "--"
    readonly property var mouseSettings: ["solaar"]
    readonly property var fingerprintList: ["sh", "-c", "exec fprintd-list \"$USER\""]
    readonly property var fingerprintMonitor: ["stdbuf", "-oL", "gdbus", "monitor", "--system", "--dest", "net.reactivated.Fprint"]
    readonly property var fingerprintPresent: /'finger-present': <(true|false)>/
    readonly property var fingerprintFinger: /^\s*-\s*#\d+:\s*(\S+)/
    readonly property var fingerprintQuery: ["sh", "-c", "dev=$(busctl call net.reactivated.Fprint /net/reactivated/Fprint/Manager net.reactivated.Fprint.Manager GetDefaultDevice | cut -d'\"' -f2) && exec busctl get-property net.reactivated.Fprint \"$dev\" net.reactivated.Fprint.Device \"$1\"", "sh"]
    readonly property var fingerprintEnroll: ["stdbuf", "-oL", "fprintd-enroll", "-f"]
    readonly property var fingerprintDelete: ["fprintd-delete", "-f"]
    readonly property var fingerprintSudoCheck: ["grep", "-q", "pam_fprintd", "/etc/pam.d/sudo"]
    readonly property string fingerprintSetup: `${Quickshell.shellDir}/scripts/fingerprint/qs-fingerprint-setup`
    readonly property var updates: ({
            program: ["sh", "-c", "SYS_UPDATE_PAUSE=1 exec \"$HOME/.config/quickshell/scripts/updates/sys_update.sh\""],
            title: "updates",
            hold: false
        })
    readonly property var cpuMonitor: ({
            program: ["btop"],
            title: "btop",
            hold: false
        })
    readonly property var memoryMonitor: ({
            program: ["htop"],
            title: "htop",
            hold: false
        })
    readonly property var gpuMonitor: ({
            program: ["nvtop"],
            title: "nvtop",
            hold: false
        })
    readonly property var hardwareSetup: ({
            program: ["bash", `${Quickshell.shellDir}/scripts/hardware/qs-hwsetup`],
            title: "hardware setup",
            hold: false
        })
    readonly property var calendar: ["zen-browser", "https://calendar.google.com"]
    readonly property var networkEditor: ["nm-connection-editor"]
    readonly property var gpu: ["sh", `${Quickshell.shellDir}/scripts/gpu/gpu.sh`]
    readonly property var decode: ["sh", `${Quickshell.shellDir}/scripts/decode/decode.sh`, "scan"]
    readonly property var decodeCaps: ["sh", `${Quickshell.shellDir}/scripts/decode/caps.sh`, "cards"]
    readonly property var speedTest: ["bash", `${Quickshell.shellDir}/scripts/speedtest/net_speedtest.sh`]
    readonly property var bluetoothUnblock: ["rfkill", "unblock", "bluetooth"]
    readonly property var shutdown: ["systemctl", "poweroff"]
    readonly property var reboot: ["systemctl", "reboot"]
    readonly property var suspend: ["sh", "-c", "[ -f /etc/systemd/sleep.conf.d/10-hibernate.conf ] && exec systemctl suspend-then-hibernate; exec systemctl suspend"]
    readonly property var sleepInhibitor: ["systemd-inhibit", "--what=sleep", "--mode=delay", "--who=quickshell", "--why=Lock the screen before sleep", "sleep", "infinity"]
    readonly property var sleepMonitor: ["gdbus", "monitor", "--system", "--dest", "org.freedesktop.login1", "--object-path", "/org/freedesktop/login1"]
    readonly property string sleepSignal: "PrepareForSleep"
    readonly property string sleepStarting: "(true"
    readonly property var uptime: ["cat", "/proc/uptime"]
    readonly property var monitorsQuery: ["hyprctl", "monitors", "all", "-j"]
    readonly property var workspacesQuery: ["hyprctl", "workspaces", "-j"]
    readonly property var hyprEval: ["hyprctl", "eval"]
    readonly property var hyprReload: ["hyprctl", "reload"]
    readonly property var fetch: ["curl", "-fsSL", "--max-time", "20"]
    readonly property string wanAddressUrl: "https://api.ipify.org"
    readonly property var calendarNew: ["zen-browser", "https://calendar.google.com/calendar/r/eventedit"]
    readonly property string weatherUrl: "https://api.open-meteo.com/v1/forecast?latitude=%1&longitude=%2&current=temperature_2m,apparent_temperature,relative_humidity_2m,precipitation_probability,weather_code,wind_speed_10m,is_day&hourly=temperature_2m,apparent_temperature,relative_humidity_2m,precipitation_probability,weather_code,wind_speed_10m,is_day&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,wind_speed_10m_max,apparent_temperature_max&timezone=auto&forecast_days=7&wind_speed_unit=ms"

    readonly property string wifiSignals: "iw dev %1 scan dump 2>/dev/null | grep -E '^BSS |signal:|SSID:'"
    readonly property string networkDetails: "nmcli -t -f %1 dev show %2 2>/dev/null"
    readonly property string kernel: "uname -r"
    readonly property string packageCount: "pacman -Q | wc -l"
    readonly property string repoUpdates: "timeout %1 checkupdates 2>/dev/null"
    readonly property string aurUpdates: "timeout %1 yay -Qua 2>/dev/null"
    readonly property string brightnessQuery: "if ls /sys/class/backlight/*/brightness >/dev/null 2>&1; then echo \"backlight $(brightnessctl -c backlight -m 2>/dev/null | cut -d, -f4 | tr -d '%')\"; elif command -v ddcutil >/dev/null 2>&1; then echo \"ddc $(ddcutil getvcp 10 --brief 2>/dev/null | awk '/^VCP/ && $5 > 0 { print int($4 * 100 / $5); exit }')\"; else echo none; fi"
    readonly property string brightnessSet: "brightnessctl -c backlight -q s %1%"
    readonly property var backlightEvents: ["udevadm", "monitor", "--udev", "--subsystem-match=backlight"]
    readonly property string backlightChange: " change "
    readonly property string brightnessDdcSet: "for d in $(ddcutil detect --brief 2>/dev/null | sed -n 's/^Display //p'); do ddcutil setvcp 10 %1 --display \"$d\" --noverify & done; wait"

    readonly property string batteryInfo: 'cd "$1" 2>/dev/null || exit 0; for f in cycle_count voltage_now voltage_min_design voltage_max current_now energy_full_design charge_full_design technology manufacturer model_name serial_number temp health capacity_level state_of_health capacity_error_margin internal_resistance manufacture_year manufacture_month manufacture_day charge_control_start_threshold charge_control_end_threshold charge_behaviour charge_types; do [ -r "$f" ] || continue; printf "%s\\t%s\\n" "$f" "$(cat "$f" 2>/dev/null)"; [ -w "$f" ] && printf "w:%s\\t1\\n" "$f"; done; exit 0'
    readonly property string batteryWrite: 'cd "$1" || exit 1; shift; while [ $# -gt 1 ]; do printf "%s" "$2" > "$1" || exit 1; shift 2; done'
    readonly property string chargerInfo: 'cd "$1" 2>/dev/null || exit 0; for d in *; do [ "$(cat "$d/type" 2>/dev/null)" = Battery ] && continue; printf "%s" "$d"; for f in type online usb_type voltage_now current_now voltage_max current_max; do [ -r "$d/$f" ] && printf "\\t%s=%s" "$f" "$(cat "$d/$f" 2>/dev/null)"; done; printf "\\n"; done'
    readonly property string upowerHistory: 'busctl --system --json=short call org.freedesktop.UPower "$1" org.freedesktop.UPower.Device GetHistory suu "$2" "$3" "$4"'
    readonly property string upowerBatteryPath: "/org/freedesktop/UPower/devices/battery_%1"

    readonly property string cpuProcesses: "top -b -n 2 -d %1 -w 512 -o %CPU | awk '/^ *PID/ { frame++; next } frame == 2 && NF >= 12 && $12 != \"top\" && shown < %2 { shown++; name = $12; for (i = 13; i <= NF; i++) name = name \" \" $i; printf \"%s\\t%s\\t%s\\n\", $1, $9, name }'"

    readonly property string shotNotify: 'act=$(notify-send -c "%5" -h "string:image-path:%1" -A "show=%4" -A "edit=%6" -w "%2" "%3"); case "$act" in show) dbus-send --session --type=method_call --dest=org.freedesktop.FileManager1 /org/freedesktop/FileManager1 org.freedesktop.FileManager1.ShowItems array:string:"file://%1" string:"" ;; edit) qs ipc call screenshot edit "%1" ;; esac'
    readonly property var screenshotClients: ["hyprctl", "clients", "-j"]
    readonly property var screenshotCursor: ["hyprctl", "cursorpos", "-j"]
    readonly property string screenshotPublish: 'out="$dir/$base.png"; n=2; until ln "$tmp" "$out" 2>/dev/null; do [ "$n" -gt "$max" ] && exit 1; out="$dir/$base-$n.png"; n=$((n + 1)); done; [ "$copy" = 1 ] && wl-copy --type image/png < "$out" >/dev/null 2>&1; printf "%s" "$out"'
    readonly property string screenshotOutput: `copy=1; src=$1; dir=$2; base=$3; max=$4; shift 4; tmp="$dir/.$base.$$.png"; trap 'rm -f "$src" "$tmp"' EXIT; ${root.screenshotCrop}; mkdir -p "$dir" && magick "$src" -crop "$crop" +repage "$tmp" || exit 1; ${root.screenshotPublish}`
    readonly property string screenshotCrop: `size=$(magick identify -format "%w %h" "$src") || exit 1; crop=$(echo "$size $*" | awk 'function n(v) { return sprintf("%.4f", v) + 0 } function c(v) { v = n(v); return v == int(v) ? v : int(v) + 1 } { W = $1; H = $2; sx = W / $7; sy = H / $8; l = int(n($3 * sx)); t = int(n($4 * sy)); r = c(($3 + $5) * sx); b = c(($4 + $6) * sy); if (l < 0) l = 0; if (t < 0) t = 0; if (r > W) r = W; if (b > H) b = H; printf "%dx%d+%d+%d", r - l, b - t, l, t }')`
    readonly property string ocrRead: 'text=$(set -o pipefail; tesseract "$img" - -l "$lang" 2>/dev/null | sed "/^[[:space:]]*$/d") || exit 1; [ -n "$text" ] || exit 3; printf "%s" "$text" | wl-copy >/dev/null 2>&1; printf "%s" "$text"'
    readonly property string screenshotOcr: `src=$1; lang=$2; shift 2; img="$src.png"; trap 'rm -f "$src" "$img"' EXIT; ${root.screenshotCrop}; magick "$src" -crop "$crop" +repage "$img" || exit 1; ${root.ocrRead}`
    readonly property string screenshotMerge: `copy=1; dir=$1; base=$2; max=$3; cw=$4; ch=$5; shift 5; tmp="$dir/.$base.$$.png"; srcs=(); specs=(); scale=0; trap 'rm -f "\${srcs[@]}" "$tmp"' EXIT; while [ $# -ge 5 ]; do srcs+=("$1"); specs+=("$1 $2 $3 $4 $5"); width=$(magick identify -format "%w" "$1") || exit 1; scale=$(awk -v a="$scale" -v b="$width" -v c="$4" 'BEGIN { s = b / c; print (s > a) ? s : a }'); shift 5; done; args=(-size "$(awk -v s="$scale" -v w="$cw" -v h="$ch" 'BEGIN { printf "%dx%d", w * s + 0.5, h * s + 0.5 }')" xc:none); for spec in "\${specs[@]}"; do set -- $spec; geo=$(awk -v s="$scale" -v x="$2" -v y="$3" -v w="$4" -v h="$5" 'BEGIN { printf "%dx%d!+%d+%d", w * s + 0.5, h * s + 0.5, x * s + 0.5, y * s + 0.5 }'); args+=("(" "$1" -resize "\${geo%%+*}" ")" -geometry "+\${geo#*+}" -composite); done; mkdir -p "$dir" && magick "\${args[@]}" -depth 8 "$tmp" || exit 1; ${root.screenshotPublish}`
    readonly property string editorExport: `src=$1; mode=$2; dir=$3; base=$4; max=$5; size=$6; tmp="$dir/.$base.$$.png"; trap 'rm -f "$src" "$tmp"' EXIT; [ "$(magick identify -format "%wx%h" "$src")" = "$size" ] || magick "$src" -resize "$size!" -depth 8 "$src" || exit 1; if [ "$mode" = copy ]; then wl-copy --type image/png < "$src" >/dev/null 2>&1; exit 0; fi; copy=0; [ "$mode" = both ] && copy=1; mkdir -p "$dir" && cp "$src" "$tmp" || exit 1; ${root.screenshotPublish}`
    readonly property string editorOcr: `img=$1; lang=$2; trap 'rm -f "$img"' EXIT; ${root.ocrRead}`
    readonly property string screenshotCopy: 'wl-copy --type image/png < "$1" >/dev/null 2>&1'
    readonly property var screenshotReveal: ["dbus-send", "--session", "--type=method_call", "--dest=org.freedesktop.FileManager1", "/org/freedesktop/FileManager1", "org.freedesktop.FileManager1.ShowItems"]
    readonly property var screenshotTrash: ["gio", "trash"]
    readonly property var editorCopied: ["notify-send", "-a", "Screenshot"]
    readonly property var screenshotFailed: ["notify-send", "-u", "critical"]
    readonly property var screenshotDiscard: ["rm", "-f"]

    readonly property var clipList: ["cliphist", "list"]
    readonly property string clipCopy: 'printf "%s\\t\\n" "$1" | cliphist decode | wl-copy'
    readonly property string clipDelete: 'printf "%s\\t\\n" "$1" | cliphist delete'
    readonly property var clipWipe: ["cliphist", "wipe"]
    readonly property string clipDeleteMany: 'for id; do printf "%s\\t\\n" "$id"; done | cliphist delete'
    readonly property var clipWatchText: ["wl-paste", "--type", "text", "--watch", "cliphist", "store"]
    readonly property var clipWatchImage: ["wl-paste", "--type", "image", "--watch", "cliphist", "store"]
    readonly property string clipConfig: 'mkdir -p "${1%/*}" && printf "max-items %s\\n" "$2" > "$1"'
    readonly property string clipThumbs: 'dir="$1"; shift; mkdir -p "$dir" || exit 1; for id; do [ -s "$dir/$id" ] || printf "%s\\t\\n" "$id" | cliphist decode > "$dir/$id"; done; for f in "$dir"/*; do [ -e "$f" ] || continue; keep=0; for id; do [ "${f##*/}" = "$id" ] && keep=1 && break; done; [ "$keep" = 1 ] || rm -f -- "$f"; done'

    readonly property var shareRegion: ["slurp", "-f", "%o %x %y %w %h"]
    readonly property string shareReply: '[ -p "$2" ] && printf "%s\\n" "$1" > "$2"'

    readonly property string serviceStatus: 'for spec; do id=${spec%%|*}; rest=${spec#*|}; kind=${rest%%|*}; unit=${rest#*|}; case $kind in system) state=$(systemctl show -p LoadState,ActiveState,UnitFileState "$unit" | tr "\\n" " ") ;; user) state=$(systemctl --user show -p LoadState,ActiveState,UnitFileState "$unit" | tr "\\n" " ") ;; flag) if [ -e "$unit" ]; then state="LoadState=loaded ActiveState=inactive UnitFileState=disabled"; else state="LoadState=loaded ActiveState=active UnitFileState=enabled"; fi ;; esac; printf "%s\\t%s\\n" "$id" "$state"; done'
    readonly property string serviceInstall: 'name=${2%.service}; install -Dm755 "$1/scripts/hardware/$name" "/usr/local/bin/$name" && install -Dm644 "$1/scripts/hardware/$2" "/etc/systemd/system/$2" && systemctl daemon-reload && systemctl enable --now "$2"'
    readonly property string serviceFlagOff: 'mkdir -p "${1%/*}" && touch "$1"'
    readonly property string serviceSystem: "sudo systemctl %1 %2"
    readonly property string serviceSystemInstall: "sudo install -Dm755 %1/scripts/hardware/%2 /usr/local/bin/%2 && sudo install -Dm644 %1/scripts/hardware/%3 /etc/systemd/system/%3 && sudo systemctl daemon-reload && sudo systemctl enable --now %3"
    readonly property string serviceUser: "systemctl --user %1 %2"
    readonly property var serviceOn: ["enable", "--now"]
    readonly property var serviceOff: ["disable", "--now"]
    readonly property var serviceStart: ["start"]
    readonly property var serviceStop: ["stop"]
    readonly property string serviceFlagEnable: "rm -f %1"
    readonly property string serviceFlagKill: "touch %1"

    readonly property var timezones: ["timedatectl", "list-timezones"]
    readonly property var logFollow: ["qs", "log", "--follow", "--no-color", "--log-times", "--pid"]
    readonly property string hyprlandErrors: `printf 'V\\t%s\\n' "$(hyprctl version | head -n 1)"; tail --pid="$1" -n +1 -F "$2" 2>/dev/null | awk -v ctx="$3" '$0 ~ /^[A-Z]+ @ / { split($0, f, " "); c = substr(f[3], 1, 8); if (c < last) rolls++; last = c } /^(ERR|WARN|CRIT)/ { for (i = (seen > ctx ? seen - ctx : 0); i < seen; i++) print "C\\t" ring[i % ctx]; seen = 0; print "E\\t" NR "\\t" last "\\t" rolls + 0 "\\t" $0; fflush(); next } { ring[seen % ctx] = $0; seen++ }'`
    readonly property string crashReports: 'for d in "$1"/*/; do r="$d"report.txt; [ -f "$r" ] || continue; printf "%s\\t%s\\t%s\\n" "$(stat -c %Y "$r")" "$r" "$(sed -n "s/^Signal: //p" "$r" | head -n 1)"; done'
    readonly property string copyFile: 'wl-copy < "$1"'
    readonly property string faviconFetch: 'mkdir -p "${1%/*}" && { curl -sfL --max-time "$2" -o "$1" "$3" || curl -sfL --max-time "$2" -o "$1" "$4"; }'
    readonly property var keymapLayouts: ["localectl", "list-x11-keymap-layouts"]
    readonly property var keymapVariants: ["localectl", "list-x11-keymap-variants"]
    readonly property var inputDevices: ["hyprctl", "-j", "devices"]
    readonly property string inputQuery: 'for o; do hyprctl -j getoption "$o" | tr -d "\\n"; echo; done'
    readonly property var inputOptions: ["input:kb_layout", "input:kb_variant", "input:kb_options", "input:sensitivity", "input:accel_profile", "input:natural_scroll", "input:touchpad:natural_scroll", "input:touchpad:tap_to_click", "input:touchpad:disable_while_typing"]
}
