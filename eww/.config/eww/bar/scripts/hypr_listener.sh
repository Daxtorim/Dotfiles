#!/usr/bin/env bash
dir=$(dirname -- "$(readlink -f -- "$0")")

eww update workspace_data="$("${dir}/workspaces_widget.py")"

socat - UNIX-CONNECT:/tmp/hypr/"${HYPRLAND_INSTANCE_SIGNATURE}"/.socket2.sock | while read -r line; do
	event="${line%%>>*}"
	case "${event}" in
		activewindow)
			eww update workspace_data="$("${dir}/workspaces_widget.py")"
			eww update activewindow_fullscreen="$(hyprctl activewindow -j | jq ".fullscreen" 2> /dev/null)"
			;;
		*workspace* | *window* | focusedmon | monitor*)
			eww update workspace_data="$("${dir}/workspaces_widget.py")"
			;;
		fullscreen)
			eww update activewindow_fullscreen="$(hyprctl activewindow -j | jq ".fullscreen" 2> /dev/null)"
			;;
	esac
done
