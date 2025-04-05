#!/bin/sh
DIRECTORY_PIC="$HOME/Pictures/"
DIRECTORY="$HOME/Pictures/screenshots/"
DIR="$HOME/Pictures/screenshots/"
NAME="screenshot_$(date +%d%m%Y_%H%M%S).png"

if [ ! -d "$DIRECTORY_PIC" ]; then
    echo "The directory $DIRECTORY_PIC does not exist. Creating it now..."
    mkdir -p "$DIRECTORY_PIC"
fi

if [ ! -d "$DIRECTORY" ]; then
    echo "The directory $DIRECTORY does not exist. Creating it now..."
    mkdir -p "$DIRECTORY"
fi

option2="󰆞  Selected area"
option3="󰹑  Fullscreen (delay 1 sec)"
option4="󱄺  OCR (image to text)"

options="$option2\n$option3\n$option4"

choice=$(echo -e "$options" | rofi -dmenu -replace -config ~/.config/rofi/config.rasi -l 3 -width 30 -p "Take Screenshot")

case $choice in
    $option2)
        grim -g "$(slurp)" "$DIR$NAME"
        notify-send "Screenshot created" "Mode: Selected area\n $DIR$NAME"
    ;;
    $option3)
        sleep 1
        grim "$DIR$NAME" 
        notify-send "Screenshot created" "Mode: Fullscreen\n $DIR$NAME"
    ;;
    $option4)
        sh ~/.config/custom_scripts/ocr.sh 
    ;;
esac
