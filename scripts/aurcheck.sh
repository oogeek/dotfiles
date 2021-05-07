#!/bin/bash
count=0
while read -r inpu
do
    count=$((count+1))
    dunstify -u normal -t 1000 "$inpu"
    sleep 0.5
done < <(checkupdates-aur)
[[ $count -eq 0 ]] && dunstify -u normal -t 1000 "no aur updates"


