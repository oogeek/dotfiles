#!/bin/bash
intern=eDP-1
extern=DP-1

if xrandr | grep "$extern disconnected"; then
    xrandr --output "$extern" --off --output "$intern" --primary
else
    xrandr --output "$intern" --off --output "$extern" --primary
fi
