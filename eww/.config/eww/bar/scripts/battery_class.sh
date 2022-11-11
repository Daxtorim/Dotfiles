#!/bin/sh

# Toggle the "battery-low" css class for the battery widget

eww_cmd="eww --config ${HOME}/.config/eww/bar"
blink_delay=1

${eww_cmd} update battery_low_class='battery-box-low-on'
sleep ${blink_delay}
${eww_cmd} update battery_low_class='battery-box-low-off'
sleep ${blink_delay}

th=$(${eww_cmd} get 'battery_low_threshold')
cp=$(${eww_cmd} get 'EWW_BATTERY.BAT0.capacity')

if [ "$cp" -gt "$th" ]; then
	${eww_cmd} update battery_low_class=''
fi
