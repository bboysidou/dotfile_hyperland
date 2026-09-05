pragma Singleton

import Quickshell

Singleton {
    readonly property var terminal: ["kitty", "-e"]
    readonly property var mouseSettings: ["solaar"]
    readonly property var updates: ["kitty", "--hold", "--title", "updates", "yay", "-Syu"]
    readonly property var cpuMonitor: ["kitty", "--title", "btop", "btop"]
    readonly property var memoryMonitor: ["kitty", "--title", "htop", "htop"]
    readonly property var calendar: ["zen-browser", "https://calendar.google.com"]
    readonly property var networkEditor: ["nm-connection-editor"]
    readonly property var shutdown: ["systemctl", "poweroff"]
    readonly property var reboot: ["systemctl", "reboot"]
    readonly property var uptime: ["cat", "/proc/uptime"]

    readonly property string kernel: "uname -r"
    readonly property string packageCount: "pacman -Q | wc -l"
    readonly property string brightnessQuery: "ls /sys/class/backlight/*/brightness >/dev/null 2>&1 && brightnessctl -c backlight -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo -1"
    readonly property string brightnessSet: "brightnessctl -c backlight -q s %1%"

    readonly property string shotRegion: 'mkdir -p "%1" && grim -g "$(slurp)" "%1/%2" && notify-send "Screenshot created" "Selected area\n%1/%2"'
    readonly property string shotFullscreen: 'mkdir -p "%1" && sleep %3 && grim "%1/%2" && notify-send "Screenshot created" "Fullscreen\n%1/%2"'
    readonly property string shotOcr: 'img=$(mktemp --suffix=.png) && grim -g "$(slurp)" "$img" && text=$(tesseract "$img" - -l eng 2>/dev/null) && rm -f "$img" && printf "%s" "$text" | wl-copy && notify-send "OCR complete" "$text"'
}
