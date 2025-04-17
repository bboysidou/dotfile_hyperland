#!/bin/bash

# CHECK THE ADAPTER PATH for this its ADP0 
# ls /sys/class/power_supply/
# Replace it with the one you found
# To check which one is the AC, run:
# cat /sys/class/power_supply/{ADAPTER}/type
# it should display "Mains"

POWER_STATE=$(cat /sys/class/power_supply/ADP0/online)

log() {
	echo "$(date): $1" >> /var/log/power-events.log
}

if [[ "$POWER_STATE" -eq 1 ]]; then
	log "AC plugged in – You are now connected to AC power."
	brightnessctl set 100%
	notify-send "AC plugged in" "You are now connected to AC power."

else
	log "On battery – You are using battery power."
	brightnessctl set 50%
	notify-send "On battery" "You are using battery power."
fi
