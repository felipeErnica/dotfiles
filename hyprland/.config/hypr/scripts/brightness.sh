#!/usr/bin/env bash

# Get brightness
get_backlight() {
	echo $(brightnessctl -m | cut -d, -f4)
}

# Get icons
get_icon() {
	current=$(get_backlight | sed 's/%//')
	if   [ "$current" -le "10" ]; then
		icon=""
	elif [ "$current" -le "20" ]; then
		icon=""
	elif [ "$current" -le "30" ]; then
		icon=""
	elif [ "$current" -le "40" ]; then
		icon=""
	elif [ "$current" -le "50" ]; then
		icon=""
	elif [ "$current" -le "60" ]; then
		icon=""
	elif [ "$current" -le "70" ]; then
		icon=""
	elif [ "$current" -le "80" ]; then
		icon=""
	else
		icon=""
	fi
}

# Notify
notify_user() {
	notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i "$icon" "Brilho : $current%"
}

# Change brightness
change_backlight() {
	brightnessctl set "$1" && get_icon && notify_user
}

# Execute accordingly
case "$1" in
	"--get")
		get_backlight
		;;
	"--inc")
		change_backlight "+10%"
		;;
	"--dec")
		change_backlight "10%-"
		;;
    *)
		get_backlight
		;;
esac
