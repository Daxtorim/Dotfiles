#!/bin/sh

paused=$(eww get notifications_paused)

if [ "${paused}" = "false" ]; then
	dunstctl set-paused true
	eww update notifications_paused=true
else
	dunstctl set-paused false
	eww update notifications_paused=false
fi
