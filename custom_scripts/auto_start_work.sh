#!/bin/sh

TABS=($(cat "$HOME/.config/custom_scripts/gitignore/tabs.txt"))
# Open Firefox Working Browser in workspace 1
hyprctl dispatch workspace 1

# Open Firefox with all tabs
firefox "${TABS[@]}" &

# Open Firefox Searching and Testing Browser in workspace 3
sleep 1
hyprctl dispatch workspace 3
firefox --new-window &

# Open Woking Project in workspace 2
sleep 1 
hyprctl dispatch workspace 2
sh $HOME/.config/custom_scripts/tmux_resurect_session.sh

