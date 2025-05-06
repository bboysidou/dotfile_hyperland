#!/bin/bash

# Path to your Hyprland config file
CONFIG="${HOME}/.config/hypr/hyprland.conf"

# Extract keybinds
keybinds=$(grep -E '^\s*bind' "$CONFIG" | sed 's/^ *bind.*,//' | sed 's/,/ → /' | sort)

# Show with rofi
echo "$keybinds" | rofi -dmenu -i -p "Hyprland Keybinds"
