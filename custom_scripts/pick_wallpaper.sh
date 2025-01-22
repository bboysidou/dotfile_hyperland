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

echo $IMAGE_DIR$selection
echo "" > $HYPRPAPER_CONF

PRELOAD="preload = $IMAGE_DIR$selection"
WALLPAPER="wallpaper = ,$IMAGE_DIR$selection" 
SPLASH="splash = false"
IPC="ipc = off"

echo $PRELOAD >> $HYPRPAPER_CONF 
echo $WALLPAPER >> $HYPRPAPER_CONF 
echo $SPLASH >> $HYPRPAPER_CONF 
echo $IPC >> $HYPRPAPER_CONF


hyprpaper
hyprctl hyprpaper unload all

hyprctl hyprpaper preload $IMAGE_DIR$selection
hyprctl hyprpaper wallpaper ",$IMAGE_DIR$selection"

hyprctl hyprpaper reload ,$IMAGE_DIR$selection

# killall hyprpaper
# sleep 1
# hyprpaper &

