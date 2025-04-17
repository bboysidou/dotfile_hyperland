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
	log "AC plugged in – enabling hybrid mode"
	# auto-cpufreq --force="reset"
	brightnessctl set 100%
else
	log "On battery – enabling integrated mode"
	# for auto-cpufreq users
	# auto-cpufreq --force="powersave"
	brightnessctl set 50%
fi
