#!/bin/sh

# Increment, decrement, or mute the volume and send a notification
# of the current volume level.
send_notification() {
	volume=$(pactl list sinks | grep '^[[:space:]]Volume:' | \
    head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')
	dunstify -a "changevolume" -u low -r 9993 -h int:value:"$volume" -i "$HOME/.config/dunst/icons/volume-$1.png" "Volume: ${volume}%" -t 2000
}

case $1 in
up)
	# Set the volume on (if it was muted)
  pactl -- set-sink-volume 0 +5%
	send_notification "$1"
	;;
down)
  pactl -- set-sink-volume 0 -5%
	send_notification "$1"
	;;
mute)
	pamixer -t
	if eval "$(pamixer --get-mute)"; then
		dunstify -a "changevolume" -t 2000 -r 9993 -u low -i "volume-mute" "Muted"
	else
		send_notification up
	fi
	;;
esac
