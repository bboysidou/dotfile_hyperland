#!/bin/sh
 
TABS_FILE="$HOME/.config/custom_scripts/gitignore/tabs.txt"

if [ ! -f "$TABS_FILE" ]; then
    echo "Error: tabs.txt not found."
    exit 1
fi

TABS=($(cat "$TABS_FILE"))

# Open Firefox Working Browser in workspace 1
hyprctl dispatch workspace 1
firefox "${TABS[@]}" &

# Open Firefox Searching and Testing Browser in workspace 3
sleep 2
hyprctl dispatch workspace 3
firefox --new-window &

# Open Woking Project in workspace 2
sleep 1 
hyprctl dispatch workspace 2
notify-send "Startup Script" "Work setup initialized. Happy coding!"
kitty --start-as=fullscreen sh $HOME/.config/custom_scripts/tmux_resurect_session.sh
