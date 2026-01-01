#!/bin/sh

IMAGE_DIR="$HOME/Pictures/wallpaper/"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"

selection=$(ls "$IMAGE_DIR" | 
  fzf --reverse \
  --info right \
  --prompt "Select a Image: " \
  --border "rounded" \
  --border-label "WALLPAPERS" \
  --height=100% \
  --preview "chafa --clear -c full --color-space rgb --dither none -p on -s 50x50 $IMAGE_DIR{}" \
  --preview-window=right:65% 
)

if [ -z "$selection" ]; then
    echo "No image selected."
    exit 1
fi

# Update only the path line in hyprpaper.conf
sed -i "s|^    path = .*$|    path = $IMAGE_DIR$selection|" "$HYPRPAPER_CONF"

# Rest of your hyprpaper commands...
hyprctl hyprpaper unload all
hyprctl hyprpaper preload "$IMAGE_DIR$selection"
hyprctl hyprpaper wallpaper ",\"$IMAGE_DIR$selection\""
hyprctl hyprpaper reload
#
# killall hyprpaper
# sleep 1
# hyprpaper &
