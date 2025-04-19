#!/bin/bash

# CHECK THE ADAPTER PATH for this its ADP0
# ls /sys/class/power_supply/
# Replace it with the one you found
# To check which one is the AC, run:
# cat /sys/class/power_supply/{ADAPTER}/type
# it should display "Mains"

#!/bin/bash

POWER_STATE=$(cat /sys/class/power_supply/ADP0/online)

log() {
  echo "$(date): $1" >> /var/log/power-events.log
}

# Environment for GUI actions
export DISPLAY=:0
export XDG_RUNTIME_DIR="/run/user/1000"
USER=$(whoami)

if [[ "$POWER_STATE" -eq 1 ]]; then
  log "AC plugged in – You are now connected to AC power."
  sudo -u $USER DISPLAY=$DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR notify-send "🔌 AC plugged in" "You are now connected to AC power."
  sudo -u $USER XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR paplay /usr/share/sounds/freedesktop/stereo/power-plug.oga
  brightnessctl set 100%
else
  log "On battery – You are using battery power."
  sudo -u $USER DISPLAY=$DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR notify-send "🔋 On battery" "You are now on battery power."
  sudo -u $USER XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR paplay /usr/share/sounds/freedesktop/stereo/power-unplug.oga
  brightnessctl set 50%
fi
