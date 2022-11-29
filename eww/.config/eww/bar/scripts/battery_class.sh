#!/bin/sh

# Toggle the "battery-low" css class for the battery widget

blink_delay=1

eww update battery_low_class='battery-box-low-on'
sleep ${blink_delay}
eww update battery_low_class='battery-box-low-off'
sleep ${blink_delay}

th=$(eww get 'battery_low_threshold')
cp=$(eww get 'EWW_BATTERY.BAT0.capacity')

if [ "$cp" -gt "$th" ]; then
	eww update battery_low_class=''
fi
