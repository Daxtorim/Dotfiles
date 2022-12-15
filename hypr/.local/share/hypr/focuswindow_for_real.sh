#!/usr/bin/env bash
# shellcheck disable=2207

address=$1
clients=$(hyprctl clients -j)

ws=$(echo "$clients" | jq -r --arg address "$address" '.[] | select(.address == $address) | .workspace.id')
fs_client=($(echo "$clients" | jq -r --argjson WS "$ws" '.[] | select(.workspace.id == $WS) | select(.fullscreen == true) | .address, .fullscreenMode'))

if [ -n "${fs_client[*]}" ]; then
	hyprctl dispatch focuswindow address:"${fs_client[0]}"
	hyprctl dispatch fullscreen "${fs_client[1]}"
fi

hyprctl dispatch focuswindow address:"$address"

if [ -n "${fs_client[*]}" ]; then
	hyprctl dispatch fullscreen "${fs_client[1]}"
fi
