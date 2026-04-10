#!/bin/bash

# -----------------------------------------------------
# Cache results so all modules read the same data
# -----------------------------------------------------
CACHE_DIR="/tmp/waybar-updates"
CACHE_AGE=300 # refresh every 5 min

mkdir -p "$CACHE_DIR"

if [ ! -f "$CACHE_DIR/stamp" ] || [ $(($(date +%s) - $(cat "$CACHE_DIR/stamp"))) -gt $CACHE_AGE ]; then
    checkupdates 2>/dev/null | wc -l > "$CACHE_DIR/pacman"
    trizen -Su --aur --quiet 2>/dev/null | wc -l > "$CACHE_DIR/aur"
    pacman -Qtdq 2>/dev/null | wc -l > "$CACHE_DIR/orphans"

    checkupdates 2>/dev/null > "$CACHE_DIR/pacman_list"
    trizen -Su --aur --quiet 2>/dev/null > "$CACHE_DIR/aur_list"
    pacman -Qtdq 2>/dev/null > "$CACHE_DIR/orphans_list"

    date +%s > "$CACHE_DIR/stamp"
fi

pacman_count=$(cat "$CACHE_DIR/pacman" 2>/dev/null || echo 0)
aur_count=$(cat "$CACHE_DIR/aur" 2>/dev/null || echo 0)
orphan_count=$(cat "$CACHE_DIR/orphans" 2>/dev/null || echo 0)

# -----------------------------------------------------
# Module selector via argument
# -----------------------------------------------------
case "$1" in
    icon)
        total=$(( pacman_count + aur_count ))
        css_class="green"
        [ "$total" -gt 25 ] && css_class="yellow"
        [ "$total" -gt 100 ] && css_class="red"
        printf '{"text": "%s", "alt": "%s", "tooltip": "Click to expand", "class": "%s"}' "$total" "$total" "$css_class"
        ;;
    pacman)
        list=$(cat "$CACHE_DIR/pacman_list" 2>/dev/null | head -20 | sed 's/$/\\n/' | tr -d '\n')
        [ -z "$list" ] && list="System is up to date"
        printf '{"text": "󰏗 %s", "tooltip": "%s", "class": "pacman"}' "$pacman_count" "$list"
        ;;
    aur)
        list=$(cat "$CACHE_DIR/aur_list" 2>/dev/null | head -20 | sed 's/$/\\n/' | tr -d '\n')
        [ -z "$list" ] && list="AUR is up to date"
        printf '{"text": "󰏓 %s", "tooltip": "%s", "class": "aur"}' "$aur_count" "$list"
        ;;
    orphans)
        list=$(cat "$CACHE_DIR/orphans_list" 2>/dev/null | head -20 | sed 's/$/\\n/' | tr -d '\n')
        [ -z "$list" ] && list="No orphan packages"
        printf '{"text": "󰗩 %s", "tooltip": "%s", "class": "orphans"}' "$orphan_count" "$list"
        ;;
esac
