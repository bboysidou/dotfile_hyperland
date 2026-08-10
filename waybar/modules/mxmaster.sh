#!/usr/bin/env bash
# MX Master battery via solaar. Silent when the mouse/receiver is absent.
# Bars on multiple outputs run this concurrently, so the solaar query is
# serialised behind a lock and shared through a short-lived cache.

cache="${XDG_RUNTIME_DIR:-/tmp}/waybar-mxmaster.cache"
ttl=120

exec 9>"${cache}.lock"
flock 9

if [ -f "$cache" ] && [ $(( $(date +%s) - $(stat -c %Y "$cache") )) -lt "$ttl" ]; then
  cat "$cache"
  exit 0
fi

out=$(timeout 15 solaar show 2>/dev/null)

cap=$(grep -m1 -oP 'Battery: \K[0-9]+(?=%)' <<<"$out")
if [ -z "$cap" ]; then
  : >"$cache"
  exit 0
fi

state=$(grep -m1 -oP 'BatteryStatus\.\K[A-Z_]+' <<<"$out")
name=$(grep -m1 -oP '^\s+Name: \K.*' <<<"$out")
[ -z "$name" ] && name="Mouse"

if [ "$cap" -le 15 ]; then
  class="critical"
elif [ "$cap" -le 30 ]; then
  class="warning"
else
  class=""
fi

icon="󰍽"
[ "$state" = "RECHARGING" ] && icon="󰠕"

# battery ramp, empty -> full in 10% steps; index 10 is the 100% glyph
levels=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
charging=(󰢟 󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)

i=$((cap / 10))
[ "$i" -gt 10 ] && i=10

if [ "$state" = "RECHARGING" ]; then
  batt=${charging[$i]}
else
  batt=${levels[$i]}
fi

printf '{"text":"%s %s%% %s","tooltip":"%s: %s%% (%s)","class":"%s"}\n' \
  "$icon" "$cap" "$batt" "$name" "$cap" "${state,,}" "$class" | tee "$cache"
