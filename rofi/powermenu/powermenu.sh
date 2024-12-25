#!/bin/sh
dir="$HOME/.config/rofi/powermenu/type"
theme='style'

# CMDs
uptime="`uptime -p | sed -e 's/up //g'`"
# host=`hostname`

# Options
shutdown=' Shutdown'
reboot=' Reboot'
# lock=''
# suspend=''
# logout=''
yes=' YES'
no=' NO'

# Rofi CMD
rofi_cmd() {
	rofi -dmenu \
		-p "Uptime: $uptime" \
		-mesg "Uptime: $uptime" \
		-theme ${dir}/${theme}.rasi
}
chosen=$(printf "  Power Off\n  Restart\n  Lock" | rofi -dmenu \
		-p "Uptime: $uptime" \
		-mesg "Uptime: $uptime" \
		-theme ${dir}/${theme}.rasi
)

case "$chosen" in
	"  Power Off") poweroff ;;
	"  Restart") reboot ;;
	"  Lock") sh $HOME/.config/screen-lock/lock.sh;;
	*) exit 1 ;;
esac
