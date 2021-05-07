#!/bin/bash
## name="$(date)"
name="$(date +%Y-%m-%d-%H-%M-%S)"
import -quality 1 -window root ~/Screenshot/"$name.png"
# scrot -q 100 ~/scrot/"$name.png"
# xclip -selection clipboard -t image/png -i ~/scrot/"$name.png"
xclip -selection clipboard -t image/png -i ~/Screenshot/"$name.png"
dunstify -t 1000 -i ~/Screenshot/"$name.png" Screenshot taken
