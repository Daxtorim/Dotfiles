#!/bin/sh

get_info()
{
	vol_out=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' | tr -d "%")
	vol_mic=$(pactl get-source-volume @DEFAULT_SOURCE@ | head -n 1 | awk '{print $5}' | tr -d "%")
	mute_out=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
	mute_mic=$(pactl get-source-mute @DEFAULT_SOURCE@ | awk '{print $2}')

	echo "{\"vol_out\":\"${vol_out}\",\"vol_mic\":\"${vol_mic}\",\"mute_out\":\"${mute_out}\",\"mute_mic\":\"${mute_mic}\"}"
}

[ "$1" = "get-info" ] && get_info

[ "$1" = "set-sink-mute" ] && pactl set-sink-mute @DEFAULT_SINK@ toggle
[ "$1" = "set-source-mute" ] && pactl set-source-mute @DEFAULT_SOURCE@ toggle

if [ "$1" = "open-ctl" ]; then
	pavucontrol &
	exit
fi
