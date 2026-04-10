#!/bin/bash

ANIM_CONF="$HOME/.config/hypr/config/animation.conf"

declare -A PRESETS

PRESETS["🌊 Wind (Current)"]='animations {
    enabled = true
    bezier = wind, 0.05, 0.9, 0.1, 1.05
    bezier = winIn, 0.1, 1.1, 0.1, 1.1
    bezier = winOut, 0.3, -0.3, 0, 1
    bezier = liner, 1, 1, 1, 1
    animation = windows, 1, 3, wind, slide
    animation = windowsIn, 1, 3, winIn, slide
    animation = windowsOut, 1, 3, winOut, slide
    animation = windowsMove, 1, 3, wind, slide
    animation = border, 1, 1, liner
    animation = borderangle, 1, 3, liner, loop
    animation = fade, 1, 3, default
    animation = workspaces, 1, 3, wind
}'

PRESETS["🎾 Bouncy"]='animations {
    enabled = true
    bezier = bounce, 0.05, 0.9, 0.1, 1.3
    bezier = bounceIn, 0.1, 1.2, 0.2, 1.2
    bezier = bounceOut, 0.3, -0.4, 0, 1.1
    bezier = liner, 1, 1, 1, 1
    animation = windows, 1, 5, bounce, popin 80%
    animation = windowsIn, 1, 5, bounceIn, popin 60%
    animation = windowsOut, 1, 4, bounceOut, popin 80%
    animation = windowsMove, 1, 4, bounce, slide
    animation = border, 1, 1, liner
    animation = borderangle, 1, 40, liner, loop
    animation = fade, 1, 5, bounce
    animation = workspaces, 1, 5, bounce, slide
}'

PRESETS["✨ Smooth"]='animations {
    enabled = true
    bezier = smooth, 0.25, 1, 0.5, 1
    bezier = smoothIn, 0.15, 1, 0.3, 1
    bezier = smoothOut, 0.36, 0, 0.66, -0.56
    bezier = liner, 1, 1, 1, 1
    animation = windows, 1, 6, smooth, slide
    animation = windowsIn, 1, 6, smoothIn, slidefade 30%
    animation = windowsOut, 1, 4, smoothOut, slidefade 30%
    animation = windowsMove, 1, 5, smooth, slide
    animation = border, 1, 2, liner
    animation = borderangle, 1, 50, liner, loop
    animation = fade, 1, 6, smooth
    animation = workspaces, 1, 6, smooth, slidefade 40%
}'

PRESETS["🚀 Snappy"]='animations {
    enabled = true
    bezier = snap, 0.4, 0, 0, 1
    bezier = snapIn, 0.5, 0, 0, 1.1
    bezier = snapOut, 0.7, 0, 1, 0.5
    bezier = liner, 1, 1, 1, 1
    animation = windows, 1, 2, snap, slide
    animation = windowsIn, 1, 2, snapIn, popin 90%
    animation = windowsOut, 1, 2, snapOut, popin 90%
    animation = windowsMove, 1, 2, snap, slide
    animation = border, 1, 1, liner
    animation = borderangle, 1, 20, liner, loop
    animation = fade, 1, 2, snap
    animation = workspaces, 1, 2, snap, slide
}'

PRESETS["🌀 Elastic"]='animations {
    enabled = true
    bezier = elastic, 0.28, 0.84, 0.42, 1.2
    bezier = elasticIn, 0.2, 0.9, 0.3, 1.3
    bezier = elasticOut, 0.5, -0.5, 0.1, 1.2
    bezier = liner, 1, 1, 1, 1
    animation = windows, 1, 6, elastic, popin 70%
    animation = windowsIn, 1, 6, elasticIn, popin 50%
    animation = windowsOut, 1, 5, elasticOut, popin 70%
    animation = windowsMove, 1, 5, elastic, slide
    animation = border, 1, 2, liner
    animation = borderangle, 1, 60, liner, loop
    animation = fade, 1, 5, elastic
    animation = workspaces, 1, 6, elastic, slide
}'

PRESETS["💨 Slide Fade"]='animations {
    enabled = true
    bezier = glide, 0.16, 1, 0.3, 1
    bezier = glideIn, 0.05, 0.85, 0.15, 1
    bezier = glideOut, 0.6, 0, 0.8, 0.2
    bezier = liner, 1, 1, 1, 1
    animation = windows, 1, 5, glide, slidefade 40%
    animation = windowsIn, 1, 5, glideIn, slidefade 40%
    animation = windowsOut, 1, 4, glideOut, slidefade 40%
    animation = windowsMove, 1, 4, glide, slide
    animation = border, 1, 2, liner
    animation = borderangle, 1, 35, liner, loop
    animation = fade, 1, 5, glide
    animation = workspaces, 1, 5, glide, slidefadevert 30%
}'

PRESETS["🎪 Flashy"]='animations {
    enabled = true
    bezier = flash, 0.1, 1.2, 0.2, 1.15
    bezier = flashIn, 0.05, 1.3, 0.1, 1.2
    bezier = flashOut, 0.4, -0.6, 0.2, 1.1
    bezier = liner, 1, 1, 1, 1
    animation = windows, 1, 7, flash, popin 60%
    animation = windowsIn, 1, 7, flashIn, popin 40%
    animation = windowsOut, 1, 5, flashOut, slidefade 50%
    animation = windowsMove, 1, 5, flash, slidefade 30%
    animation = border, 1, 2, liner
    animation = borderangle, 1, 30, liner, loop
    animation = fade, 1, 6, flash
    animation = workspaces, 1, 7, flash, slidefadevert 40%
}'

PRESETS["🧊 Minimal"]='animations {
    enabled = true
    bezier = minimal, 0.4, 0, 0.2, 1
    bezier = liner, 1, 1, 1, 1
    animation = windows, 1, 3, minimal, slide
    animation = windowsIn, 1, 3, minimal, slidefade 20%
    animation = windowsOut, 1, 2, minimal, slidefade 20%
    animation = windowsMove, 1, 3, minimal, slide
    animation = border, 1, 1, liner
    animation = borderangle, 1, 80, liner, loop
    animation = fade, 1, 3, minimal
    animation = workspaces, 1, 3, minimal, slidefade 20%
}'

PRESETS["🫧 Popin"]='animations {
    enabled = true
    bezier = pop, 0.1, 0.8, 0.2, 1.05
    bezier = popIn, 0.05, 0.9, 0.1, 1.15
    bezier = popOut, 0.5, -0.2, 0.8, 0.4
    bezier = liner, 1, 1, 1, 1
    animation = windows, 1, 5, pop, popin 70%
    animation = windowsIn, 1, 5, popIn, popin 50%
    animation = windowsOut, 1, 4, popOut, popin 80%
    animation = windowsMove, 1, 4, pop, popin 90%
    animation = border, 1, 1, liner
    animation = borderangle, 1, 45, liner, loop
    animation = fade, 1, 4, pop
    animation = workspaces, 1, 5, pop, popin 70%
}'

PRESETS["⚡ Vertical"]='animations {
    enabled = true
    bezier = vert, 0.2, 1, 0.3, 1
    bezier = vertIn, 0.1, 1.1, 0.2, 1.05
    bezier = vertOut, 0.5, -0.3, 0.7, 0.3
    bezier = liner, 1, 1, 1, 1
    animation = windows, 1, 5, vert, slidevert
    animation = windowsIn, 1, 5, vertIn, slidefadevert 30%
    animation = windowsOut, 1, 4, vertOut, slidefadevert 30%
    animation = windowsMove, 1, 4, vert, slidevert
    animation = border, 1, 1, liner
    animation = borderangle, 1, 40, liner, loop
    animation = fade, 1, 4, vert
    animation = workspaces, 1, 5, vert, slidevert
}'

PRESETS["❌ Disabled"]='animations {
    enabled = false
}'

# Decoration block stays the same
DECORATION='decoration {
    blur {
        enabled = true
        size = 2
        passes = 2
        new_optimizations = on
        ignore_opacity = true
        xray = true
    }
}'

# Build rofi menu
OPTIONS=""
for key in "🌊 Wind (Current)" "🎾 Bouncy" "✨ Smooth" "🚀 Snappy" "🌀 Elastic" "💨 Slide Fade" "🎪 Flashy" "🧊 Minimal" "🫧 Popin" "⚡ Vertical" "❌ Disabled"; do
    OPTIONS+="$key\n"
done

CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Animation" -theme "$HOME/.config/rofi/launcher/style.rasi")

[ -z "$CHOICE" ] && exit 0

if [[ -v "PRESETS[$CHOICE]" ]]; then
    printf '%s\n%s\n' "${PRESETS[$CHOICE]}" "$DECORATION" > "$ANIM_CONF"
    hyprctl reload
    notify-send "Hyprland Animations" "Applied: $CHOICE" -t 2000
fi
