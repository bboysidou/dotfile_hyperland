#!/bin/sh

IMAGE_DIR="$HOME/Pictures/wallpaper"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

selection=$(for img in "$IMAGE_DIR"/*; do
    name=$(basename "$img")
    echo -en "$name\0icon\x1f$img\n"
done | rofi -dmenu -show-icons -p "Wallpaper" -theme-str '
    window {
        width: 700px;
        height: 700px;
        location: center;
        anchor: center;
        border-radius: 24px;
    }
    listview {
        columns: 2;
        lines: 4;
        spacing: 10px;
        fixed-height: true;
    }
    element {
        orientation: vertical;
        padding: 10px;
        border-radius: 12px;
    }
    element-icon {
        size: 8em;
        horizontal-align: 0.5;
    }
    element-text {
        horizontal-align: 0.5;
    }
')

if [ -z "$selection" ]; then
    exit 0
fi

wallpaper="$IMAGE_DIR/$selection"

sed -i "s|^    path = .*$|    path = $wallpaper|" "$HYPRPAPER_CONF"

killall hyprpaper
sleep 0.5
hyprpaper &
