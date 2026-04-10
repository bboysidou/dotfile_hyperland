#!/bin/bash

STYLES_DIR="$HOME/.config/waybar/styles"
STYLE_TARGET="$HOME/.config/waybar/style.css"

declare -A THEMES
THEMES["🔘 Default"]="default.css"
THEMES["⚡ Powerline"]="powerline.css"
THEMES["💜 Neon"]="neon.css"
THEMES["🌊 Tide"]="tide.css"

OPTIONS=""
for key in "🔘 Default" "⚡ Powerline" "💜 Neon" "🌊 Tide"; do
    OPTIONS+="$key\n"
done

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Waybar Theme" -theme "$HOME/.config/rofi/launcher/style.rasi")

[ -z "$CHOICE" ] && exit 0

if [[ -v "THEMES[$CHOICE]" ]]; then
    sed 's|url("../colors.css")|url("colors.css")|g' "$STYLES_DIR/${THEMES[$CHOICE]}" > "$STYLE_TARGET"
    killall waybar 2>/dev/null
    sleep 0.2
    waybar &
    notify-send "Waybar Theme" "Applied: $CHOICE" -t 2000
fi
