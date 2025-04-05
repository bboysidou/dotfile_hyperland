#!/bin/sh
 
TABS_FILE="$HOME/.config/custom_scripts/gitignore/tabs.txt"

if [ ! -f "$TABS_FILE" ]; then
    echo "Error: tabs.txt not found."
    exit 1
fi

TABS=($(cat "$TABS_FILE"))

hyprctl dispatch workspace 1
# Open Firefox Working Browser in workspace 1
hyprctl dispatch workspace 1
firefox "${TABS[@]}" &
sleep 1

# Open Firefox Searching and Testing Browser in workspace 3
hyprctl dispatch workspace 3
firefox --new-window &
sleep 1

# Open Woking Project in workspace 2
sleep 1 
hyprctl dispatch workspace 2
kitty --start-as=fullscreen sh $HOME/.config/custom_scripts/tmux_resurect_session.sh
