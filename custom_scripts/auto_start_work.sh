#!/bin/sh
 
TABS_FILE="$HOME/.config/custom_scripts/gitignore/tabs.txt"
WORKING_PROJECTS_FILE="$HOME/.config/custom_scripts/tmux_resurect_session.sh"

if [ ! -f "$TABS_FILE" ]; then
    notify-send -u critical "Error" "tabs.txt not found."
    echo "Error: tabs.txt not found."
    exit 1
fi

TABS=($(cat "$TABS_FILE"))

# Open Browser Working Browser in workspace 1
hyprctl dispatch workspace 1
# zen-browser "${TABS[@]}" &
zen-browser "${TABS[@]}" &

# Open Browser Searching and Testing Browser in workspace 3
sleep 2
hyprctl dispatch workspace 3
zen-browser --new-window &
# firefox --new-window &

# Point in workspace 2
sleep 1
hyprctl dispatch workspace 2
# Open mailspring in workspace 7
sleep 1
hyprctl dispatch workspace 7
mailspring --password-store="gnome-libsecret" &
# Open thunderbird in workspace 6
sleep 2
hyprctl dispatch workspace 6
thunderbird &

# Open Woking Project in workspace 2
sleep 3 
hyprctl dispatch workspace 2
notify-send "Startup Script" "Work setup initialized. Happy coding!"
kitty --start-as=fullscreen sh $WORKING_PROJECTS_FILE

