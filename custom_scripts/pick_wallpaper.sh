#!/bin/bash

IMAGE_DIR="$HOME/Pictures/wallpaper/"

# Find images and display them in Rofi
IMAGE=$(for a in "$IMAGE_DIR"*; do echo -en "$a\0icon\x1f$a\n" ; done | rofi -dmenu)

# Show a preview notification if an image is selected
if [ -n "$IMAGE" ]; then
    # Send a notification with the image preview (requires dunst)
    dunstify -I "$IMAGE" -t 1500 "Image Preview" "$(basename "$IMAGE")"
    # Open the selected image in default viewer
    # xdg-open "$IMAGE"
    hyprctl hyprpaper preload "$IMAGE" 
    hyprctl hyprpaper monitor "$IMAGE"
    killall hyprpaper
    sleep 1
    hyprpaper &

else
    echo "No image selected."
fi
