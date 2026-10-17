pragma Singleton

import Quickshell

Singleton {
    readonly property var terminal: ["kitty", "-e"]
    readonly property var mouseSettings: ["solaar"]
    readonly property var updates: ["kitty", "--hold", "--title", "updates", "yay", "-Syu"]
    readonly property var cpuMonitor: ["kitty", "--title", "btop", "btop"]
    readonly property var memoryMonitor: ["kitty", "--title", "htop", "htop"]
    readonly property var gpuMonitor: ["kitty", "--title", "nvtop", "nvtop"]
    readonly property var calendar: ["zen-browser", "https://calendar.google.com"]
    readonly property var networkEditor: ["nm-connection-editor"]
    readonly property var bluetoothUnblock: ["rfkill", "unblock", "bluetooth"]
    readonly property var shutdown: ["systemctl", "poweroff"]
    readonly property var reboot: ["systemctl", "reboot"]
    readonly property var uptime: ["cat", "/proc/uptime"]

    readonly property string wifiSignals: "iw dev %1 scan dump 2>/dev/null | grep -E '^BSS |signal:|SSID:'"
    readonly property string networkDetails: "nmcli -t -f %1 dev show %2 2>/dev/null"
    readonly property string kernel: "uname -r"
    readonly property string packageCount: "pacman -Q | wc -l"
    readonly property string repoUpdates: "timeout %1 checkupdates 2>/dev/null"
    readonly property string aurUpdates: "timeout %1 yay -Qua 2>/dev/null"
    readonly property string brightnessQuery: "ls /sys/class/backlight/*/brightness >/dev/null 2>&1 && brightnessctl -c backlight -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo -1"
    readonly property string brightnessSet: "brightnessctl -c backlight -q s %1%"

    readonly property string readEach: 'for f; do cat "$f" 2>/dev/null || echo -; done'
    readonly property string gpuProbe: 'for d in /sys/class/drm/card*/device; do [ -r "$d/gpu_busy_percent" ] || continue; echo "$d"; ls -d "$d"/hwmon/hwmon* 2>/dev/null | head -n 1; lspci -vmm -s "$(basename "$(readlink -f "$d")")" | sed -n "s/^Device:\t//p"; exit 0; done'
    readonly property string cpuProcesses: "top -b -n 2 -d %1 -w 512 -o %CPU | awk '/^ *PID/ { frame++; next } frame == 2 && NF >= 12 && $12 != \"top\" && shown < %2 { shown++; name = $12; for (i = 13; i <= NF; i++) name = name \" \" $i; printf \"%s\\t%s\\t%s\\n\", $1, $9, name }'"
    readonly property string gpuProcesses: `find /proc/[0-9]*/fd -lname '/dev/dri/*' 2>/dev/null | sed 's|/fd/|/fdinfo/|' | xargs -r awk '
        FNR == 1 { flush(); split(FILENAME, part, "/"); pid = part[3]; client = ""; gfx = 0; vram = 0 }
        /^drm-client-id:/ { client = $2 }
        /^drm-engine-gfx:/ { gfx = $2 }
        /^drm-(memory|resident)-vram:/ { vram = $2 }
        function flush() { if (client != "" && !seen[pid SUBSEP client]++) { busy[pid] += gfx; mem[pid] += vram } client = "" }
        END { flush(); for (id in busy) { path = "/proc/" id "/comm"; name = ""; getline name < path; close(path); printf "%s\\t%d\\t%d\\t%s\\n", id, busy[id], mem[id], name } }' 2>/dev/null`

    readonly property string shotRegion: 'mkdir -p "%1" && grim -g "$(slurp)" "%1/%2" && %3'
    readonly property string shotFullscreen: 'mkdir -p "%1" && sleep %3 && grim "%1/%2" && %4'
    readonly property string shotNotify: 'act=$(notify-send -c "%5" -h "string:image-path:%1" -A "show=%4" -w "%2" "%3") && [ "$act" = show ] && dbus-send --session --type=method_call --dest=org.freedesktop.FileManager1 /org/freedesktop/FileManager1 org.freedesktop.FileManager1.ShowItems array:string:"file://%1" string:""'
    readonly property string shotOcr: 'img=$(mktemp --suffix=.png) && grim -g "$(slurp)" "$img" && text=$(tesseract "$img" - -l eng 2>/dev/null) && rm -f "$img" && printf "%s" "$text" | wl-copy && notify-send "OCR complete" "$text"'
}
