#!/usr/bin/env bash
battery=""
for d in /sys/class/power_supply/BAT*; do
  [ -d "$d" ] && battery="$d"
done

[ -z "$battery" ] && exit 0

cap=$(cat "$battery/capacity" 2>/dev/null)
status=$(cat "$battery/status" 2>/dev/null)

i=$((cap / 10))
[ "$i" -gt 10 ] && i=10

icons=(󰂎 󰂂 󰂁 󰂀 󰁿 󰁾 󰁽 󰁼 󰁻 󰁺 󰂎)
charging=(󰂅 󰂋 󰂊 󰂉 󰂈 󰂇 󰂆 󰂆 󰂆 󰂆 󰂅)

if [[ "$status" = "Charging" || "$status" = "Full" ]]; then
  icon=${charging[$i]}
else
  icon=${icons[$((10 - i))]}
fi

echo " $cap% $icon"