#!/bin/bash

if [ "$1" = "open-ctl" ]; then
	kitty nmtui &
	exit
fi

if [ "$1" = "monitor" ]; then
	"${HOME}/.config/eww/bar/scripts/network_widget.py"
	nmcli monitor | while read -r _; do
		"${HOME}/.config/eww/bar/scripts/network_widget.py"
	done
fi
