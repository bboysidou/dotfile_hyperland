pragma Singleton

import Quickshell

Singleton {
    readonly property var mouseSettings: ["solaar"]
    readonly property var updates: ({
            program: ["yay", "-Syu"],
            title: "updates",
            hold: true
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
    readonly property var calendar: ["zen-browser", "https://calendar.google.com"]
    readonly property var networkEditor: ["nm-connection-editor"]
    readonly property var bluetoothUnblock: ["rfkill", "unblock", "bluetooth"]
    readonly property var shutdown: ["systemctl", "poweroff"]
    readonly property var reboot: ["systemctl", "reboot"]
    readonly property var suspend: ["systemctl", "suspend"]
    readonly property var uptime: ["cat", "/proc/uptime"]
    readonly property var monitorsQuery: ["hyprctl", "monitors", "all", "-j"]
    readonly property var workspacesQuery: ["hyprctl", "workspaces", "-j"]
    readonly property var hyprEval: ["hyprctl", "eval"]
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

    readonly property string gpuReadings: '[ "$(cat "$1/power/runtime_status" 2>/dev/null)" = suspended ] && { echo suspended; exit 0; }; shift; echo active; for f; do cat "$f" 2>/dev/null || echo -; done'
    readonly property string gpuProbe: 'for d in /sys/class/drm/card*/device; do [ -r "$d/gpu_busy_percent" ] || continue; pci=$(basename "$(readlink -f "$d")"); hw=$(ls -d "$d"/hwmon/hwmon* 2>/dev/null | head -n 1); vram=$(cat "$d/mem_info_vram_total" 2>/dev/null); state=$(cat "$d/power/runtime_status" 2>/dev/null); name=$(cat "$d/product_name" 2>/dev/null); [ -n "$name" ] || name=$(lspci -vmm -s "$pci" 2>/dev/null | sed -n "s/^Device:\t//p"); printf "%s\\t%s\\t%s\\t%s\\t%s\\t%s\\n" "$d" "$hw" "$pci" "$vram" "$state" "$name"; done'
    readonly property string cpuProcesses: "top -b -n 2 -d %1 -w 512 -o %CPU | awk '/^ *PID/ { frame++; next } frame == 2 && NF >= 12 && $12 != \"top\" && shown < %2 { shown++; name = $12; for (i = 13; i <= NF; i++) name = name \" \" $i; printf \"%s\\t%s\\t%s\\n\", $1, $9, name }'"
    readonly property string gpuProcesses: `find /proc/[0-9]*/fd -lname '/dev/dri/*' 2>/dev/null | sed 's|/fd/|/fdinfo/|' | xargs -r awk -v want="$1" '
        FNR == 1 { flush(); split(FILENAME, part, "/"); pid = part[3]; client = ""; pdev = ""; gfx = 0; vram = 0 }
        /^drm-client-id:/ { client = $2 }
        /^drm-pdev:/ { pdev = $2 }
        /^drm-engine-gfx:/ { gfx = $2 }
        /^drm-(memory|resident)-vram:/ { vram = $2 }
        function flush() { if (client != "" && (want == "" || pdev == "" || pdev == want) && !seen[pid SUBSEP pdev SUBSEP client]++) { busy[pid] += gfx; mem[pid] += vram } client = "" }
        END { flush(); for (id in busy) { path = "/proc/" id "/comm"; name = ""; getline name < path; close(path); printf "%s\\t%d\\t%d\\t%s\\n", id, busy[id], mem[id], name } }' 2>/dev/null`

    readonly property string shotRegion: 'mkdir -p "%1" && grim -g "$(slurp)" "%1/%2" && %3'
    readonly property string shotFullscreen: 'mkdir -p "%1" && sleep %3 && grim "%1/%2" && %4'
    readonly property string shotNotify: 'act=$(notify-send -c "%5" -h "string:image-path:%1" -A "show=%4" -w "%2" "%3") && [ "$act" = show ] && dbus-send --session --type=method_call --dest=org.freedesktop.FileManager1 /org/freedesktop/FileManager1 org.freedesktop.FileManager1.ShowItems array:string:"file://%1" string:""'
    readonly property string shotOcr: 'img=$(mktemp --suffix=.png) && grim -g "$(slurp)" "$img" && text=$(tesseract "$img" - -l eng 2>/dev/null) && rm -f "$img" && printf "%s" "$text" | wl-copy && notify-send "OCR complete" "$text"'

    readonly property var clipList: ["cliphist", "list"]
    readonly property string clipCopy: 'printf "%s\\t\\n" "$1" | cliphist decode | wl-copy'
    readonly property string clipDelete: 'printf "%s\\t\\n" "$1" | cliphist delete'
    readonly property var clipWipe: ["cliphist", "wipe"]
    readonly property string clipThumbs: 'dir="$1"; shift; mkdir -p "$dir" || exit 1; for id; do [ -s "$dir/$id" ] || printf "%s\\t\\n" "$id" | cliphist decode > "$dir/$id"; done; for f in "$dir"/*; do [ -e "$f" ] || continue; keep=0; for id; do [ "${f##*/}" = "$id" ] && keep=1 && break; done; [ "$keep" = 1 ] || rm -f -- "$f"; done'

    readonly property var shareRegion: ["slurp", "-f", "%o %x %y %w %h"]
    readonly property string shareReply: '[ -p "$2" ] && printf "%s\\n" "$1" > "$2"'
}
