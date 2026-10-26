pragma Singleton

import Quickshell

Singleton {
    readonly property var appScope: ["systemd-run", "--user", "--scope", "--collect", "--quiet", "--slice=app.slice", "--"]
    readonly property var mouseSettings: ["solaar"]
    readonly property var updates: ({
            program: ["sh", "-c", "exec \"$HOME/.config/custom_scripts/sys_update.sh\""],
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
    readonly property var hardwareSetup: ({
            program: ["bash", `${Quickshell.shellDir}/system/qs-hwsetup`],
            title: "hardware setup",
            hold: false
        })
    readonly property var calendar: ["zen-browser", "https://calendar.google.com"]
    readonly property var networkEditor: ["nm-connection-editor"]
    readonly property var gpu: ["sh", `${Quickshell.shellDir}/services/gpu/gpu.sh`]
    readonly property var speedTest: ["bash", `${Quickshell.shellDir}/services/speedtest/net_speedtest.sh`]
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

    readonly property string serviceStatus: 'for spec; do id=${spec%%|*}; rest=${spec#*|}; kind=${rest%%|*}; unit=${rest#*|}; case $kind in system) state=$(systemctl show -p LoadState,ActiveState,UnitFileState "$unit" | tr "\\n" " ") ;; user) state=$(systemctl --user show -p LoadState,ActiveState,UnitFileState "$unit" | tr "\\n" " ") ;; flag) if [ -e "$unit" ]; then state="LoadState=loaded ActiveState=inactive UnitFileState=disabled"; else state="LoadState=loaded ActiveState=active UnitFileState=enabled"; fi ;; esac; printf "%s\\t%s\\n" "$id" "$state"; done'
    readonly property string serviceInstall: 'name=${2%.service}; install -Dm755 "$1/system/$name" "/usr/local/bin/$name" && install -Dm644 "$1/system/$2" "/etc/systemd/system/$2" && systemctl daemon-reload && systemctl enable --now "$2"'
    readonly property string serviceFlagOff: 'mkdir -p "${1%/*}" && touch "$1"'
    readonly property string serviceSystem: "sudo systemctl %1 %2"
    readonly property string serviceSystemInstall: "sudo install -Dm755 %1/system/%2 /usr/local/bin/%2 && sudo install -Dm644 %1/system/%3 /etc/systemd/system/%3 && sudo systemctl daemon-reload && sudo systemctl enable --now %3"
    readonly property string serviceUser: "systemctl --user %1 %2"
    readonly property var serviceOn: ["enable", "--now"]
    readonly property var serviceOff: ["disable", "--now"]
    readonly property var serviceStart: ["start"]
    readonly property var serviceStop: ["stop"]
    readonly property string serviceFlagEnable: "rm -f %1"
    readonly property string serviceFlagKill: "touch %1"
}
