#!/bin/sh

# Toggle the "battery-low" css class for the battery widget

bat_capacity=$(eww --config "${HOME}/.config/eww/bar" get "EWW_BATTERY" | jq ".BAT0.capacity")
bat_status=$(eww --config "${HOME}/.config/eww/bar" get "EWW_BATTERY" | jq ".BAT0.status")

# yes, the double quotes are part of the output
if [ "${bat_status}" = '"Charging"' ]; then
	echo "battery-charging"

elif [ "${bat_capacity}" -le 10 ]; then

	battery_low=$(eww --config "${HOME}/.config/eww/bar" get "battery_low_class")

	if [ "${battery_low}" = "battery-low-on" ]; then
		echo "battery-low-off"
	else
		echo "battery-low-on"
	fi
fi
