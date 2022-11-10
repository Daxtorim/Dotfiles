#!/bin/bash

[ "$1" = "open-ctl" ] && plasmawindowed org.kde.plasma.networkmanagement && exit

if [ "$1" = "monitor" ]; then
	"${HOME}/.config/eww/bar/scripts/network_widget.py"
	nmcli monitor | while read -r _; do
		"${HOME}/.config/eww/bar/scripts/network_widget.py"
	done
fi
