#!/bin/sh

export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland

export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_QPA_PLATFORM="wayland;xcb"
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
# export QT_QPA_PLATFORMTHEME=qt5ct

export XCURSOR_THEME=Bibata-Modern-Amber
export XCURSOR_SIZE=24

exec Hyprland
