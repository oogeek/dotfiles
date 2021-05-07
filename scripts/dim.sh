#!/bin/bash
monitor="$(xrandr | sed -n "s/\(.*\)\ connected primary.*/\1/gp")"
case $monitor in
     eDP-1)
 brightness_change=30
 brightness=$(cat /sys/class/backlight/intel_backlight/brightness)
 if [[ $((brightness-brightness_change)) -ge 0 ]];
 then { brightness=$((brightness-brightness_change)); }
 else brightness=0
 fi

 echo $brightness> /sys/class/backlight/intel_backlight/brightness
 echo $brightness
        dunstify -u normal -t 5000  "monitor $monitor BRIGHTNESS changed to $brightness"
 ;;

     DP-1)
         brightness="$(ddcutil -b 6 getvcp 10 | sed -n "s/.*\(=.*,\).*/\1/gp" | grep -o "[[:digit:]]*")"
         min_brightness=0
         if [[ $((brightness-1)) -ge $min_brightness ]];
         then ddcutil -b 6 setvcp 10 "$((brightness-1))"
         else ddcutil -b 6 setvcp 10 $min_brightness
         fi
         echo "$((brightness-1))"
        dunstify -u normal -t 5000  "monitor $monitor BRIGHTNESS changed to $((brightness-1))"
     ;;
 esac
