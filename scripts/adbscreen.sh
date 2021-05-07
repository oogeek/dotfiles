#!/bin/bash
DATE="$(date)"
name=${1:-$DATE}
adb exec-out screencap -p > "$name.png"
# adb shell screencap -p | sed 's/^M$//' > screenshot.png
