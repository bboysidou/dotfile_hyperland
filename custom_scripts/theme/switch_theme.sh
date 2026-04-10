#!/bin/bash

THEME_DIR="$HOME/.config/custom_scripts/theme"
PALETTE_DIR="$THEME_DIR/palettes"
COLORS_FILE="$THEME_DIR/colors.conf"
CURRENT_FILE="$THEME_DIR/.current_theme"

# Read current theme
current=$(cat "$CURRENT_FILE" 2>/dev/null || echo "vscode-dark")

# Build theme list with indicator
themes=()
for f in "$PALETTE_DIR"/*.conf; do
    name=$(basename "$f" .conf)
    if [ "$name" = "$current" ]; then
        themes+=("  $name")
    else
        themes+=("   $name")
    fi
done

# Show rofi picker
chosen=$(printf '%s\n' "${themes[@]}" | rofi -dmenu \
    -p "Theme" \
    -theme-str 'window { width: 350px; } listview { lines: 6; }' \
    -i -no-custom)

[ -z "$chosen" ] && exit 0

# Strip icon prefix
theme_name=$(echo "$chosen" | sed 's/^.*  //')
palette="$PALETTE_DIR/$theme_name.conf"

[ ! -f "$palette" ] && notify-send "Theme" "Palette not found: $theme_name" && exit 1

# Copy palette to active colors
cp "$palette" "$COLORS_FILE"

# Save current theme
echo "$theme_name" > "$CURRENT_FILE"

# Apply to all tools
bash "$THEME_DIR/apply_theme.sh"

# Reload apps
~/.config/waybar/launch.sh &
hyprctl reload &

# Notify
notify-send "Theme" "Switched to $theme_name" -i preferences-desktop-theme
