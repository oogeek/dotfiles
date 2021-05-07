#!/bin/bash

# detect the primary monitor
monitor="$(xrandr | sed -n "s/\(.*\)\ connected primary.*/\1/gp")"

# two cases
case $monitor in
    eDP-1)
    brightness_change=30
    brightness=$(cat /sys/class/backlight/intel_backlight/brightness)
    max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)

    if [ $((brightness_change+brightness)) -le "$max_brightness" ]; then { brightness=$((brightness_change+brightness)); }
    else brightness=$((max_brightness))
    fi

    echo $brightness> /sys/class/backlight/intel_backlight/brightness
        dunstify -u normal -t 5000  "monitor $monitor BRIGHTNESS changed to $((brightness+1))"
;;

    DP-1)
        brightness="$(ddcutil -b 6 getvcp 10 | sed -n "s/.*\(=.*,\).*/\1/gp" | grep -o "[[:digit:]]*")"
        max_brightness=100
        if [[ $((brightness+1)) -le $max_brightness ]];
        then ddcutil -b 6 setvcp 10 "$((brightness+1))"
        else ddcutil -b 6 setvcp 10 $max_brightness
        fi

        dunstify -u normal -t 5000  "monitor $monitor BRIGHTNESS changed to $((brightness+1))"
    ;;
esac
