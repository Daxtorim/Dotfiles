#!/usr/bin/bash

function run {
	if ! pgrep $1 ; then
		$@&
	fi
}

run xfce4-power-manager
# Wallpaper
run feh --bg-fill --no-fehbg --randomize ~/Pictures/wallpapers/*
# Compositor
run picom
# NetworkManager
run nm-applet
# System packages
run pamac-tray
# Volume
sleep 10s
pulseaudio -D
run volumeicon
