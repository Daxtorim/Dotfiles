#!/bin/sh

[ "$1" = "get-vol" ] && pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' | tr -d "%" && exit
[ "$1" = "set-vol" ] && pactl set-sink-volume @DEFAULT_SINK@ "$2%" && exit

[ "$1" = "get-mute" ] && pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}' && exit
[ "$1" = "set-mute" ] && pactl set-sink-mute @DEFAULT_SINK@ "toggle" && exit

[ "$1" = "open-ctl" ] && plasmawindowed org.kde.plasma.volume && exit
