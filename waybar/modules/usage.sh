#!/usr/bin/env bash
# Single producer for the cpu and memory pills.
#
# Computes the usage percentage once, renders the ring from that same number,
# and prints the readout as JSON. The image module only re-reads the rendered
# file (`usage.sh <src> path`), so the number and its ring cannot disagree.
#
# usage: usage.sh cpu|memory        -> JSON readout; renders the ring, wakes the image
#        usage.sh cpu|memory path   -> prints the ring PNG path
set -u

src="${1:?usage: usage.sh cpu|memory [path]}"
mode="${2:-read}"

run="${XDG_RUNTIME_DIR:-/tmp}"
png="$run/waybar-ring-$src.png"
state="$run/waybar-ring-$src.state"

size=16 # px, keep in sync with "size" in config.jsonc
track="#3E3E3E" # @bg-lighter
warn="#fabd2f" # @warning
crit="#F44747" # @critical

case "$src" in
cpu)
  icon="󰍛"
  accent="#1793d0" # @highlight
  sig=10
  ;;
memory)
  icon=""
  accent="#4EC9B0" # @green, same as the media text
  sig=11
  ;;
*)
  echo "usage.sh: unknown source '$src'" >&2
  exit 1
  ;;
esac

# gdk-pixbuf has no SVG loader here, so the arc is rasterised with rsvg-convert.
# r=40 in a 100x100 box, so the circumference is 2*pi*40 = 251.33.
render() {
  local pct=$1 color arc rest
  color="$accent"
  [ "$pct" -ge 70 ] && color="$warn"
  [ "$pct" -ge 90 ] && color="$crit"
  arc=$(awk -v p="$pct" 'BEGIN{printf "%.2f", 251.33 * p / 100}')
  rest=$(awk -v p="$pct" 'BEGIN{printf "%.2f", 251.33 * (100 - p) / 100}')
  rsvg-convert -w "$size" -h "$size" -o "$png" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <circle cx="50" cy="50" r="40" fill="none" stroke="$track" stroke-width="16"/>
  <circle cx="50" cy="50" r="40" fill="none" stroke="$color" stroke-width="16"
          stroke-dasharray="$arc $rest" transform="rotate(-90 50 50)"/>
</svg>
SVG
}

# The image module must never recompute: a second sample here is exactly how the
# ring used to drift away from the number beside it.
if [ "$mode" = "path" ]; then
  [ -f "$png" ] || render 0
  echo "$png"
  exit 0
fi

case "$src" in
cpu)
  sample() {
    read -r _ user nice sys idle iowait irq softirq steal _ </proc/stat
    total=$((user + nice + sys + idle + iowait + irq + softirq + steal))
    busy=$((total - idle - iowait))
  }

  if [ -f "$state" ]; then
    read -r prev_total prev_busy <"$state"
  else
    # nothing to diff against; a raw read would report the since-boot average
    sample
    prev_total=$total
    prev_busy=$busy
    sleep 0.3
  fi

  sample
  echo "$total $busy" >"$state"

  d_total=$((total - prev_total))
  d_busy=$((busy - prev_busy))
  if [ "$d_total" -gt 0 ]; then
    pct=$((100 * d_busy / d_total))
  else
    pct=0
  fi

  tooltip="LOAD: $(cut -d' ' -f1-3 /proc/loadavg)"
  ;;
memory)
  read -r mem_total mem_used swap_total swap_used < <(
    awk '/^MemTotal:/{t=$2} /^MemAvailable:/{a=$2} /^SwapTotal:/{st=$2} /^SwapFree:/{sf=$2}
         END{print t, t - a, st, st - sf}' /proc/meminfo
  )
  pct=$((100 * mem_used / mem_total))

  gib() { awk -v k="$1" 'BEGIN{printf "%.1fGiB", k / 1048576}'; }
  tooltip="USED: $(gib "$mem_used")\nTOTAL: $(gib "$mem_total")"
  tooltip="$tooltip\nSWAP USED: $(gib "$swap_used")\nSWAP TOTAL: $(gib "$swap_total")"
  ;;
esac

[ "$pct" -lt 0 ] && pct=0
[ "$pct" -gt 100 ] && pct=100

class=""
[ "$pct" -ge 70 ] && class="warning"
[ "$pct" -ge 90 ] && class="critical"

render "$pct"

printf '{"text":"%s %s%%","tooltip":"%s","class":"%s"}\n' \
  "$icon" "$pct" "$tooltip" "$class"

# tell the image module the file changed, so the ring lands with this number
pkill -RTMIN+$sig waybar 2>/dev/null || true
