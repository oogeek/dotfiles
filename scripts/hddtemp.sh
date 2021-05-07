#!/bin/bash
#disk="s$(lsblk -f | sed -n "s/^\(.*\)s\([a-d][a-d]\)1 \(.*\) 7d20d0ff-2c37-495c-adc5-3082bb5e10ff \(.*\)/\2/gp")"
catd="$(cat 2>/dev/null /home/oogeek/disk.txt)"
disk=${catd:-sdb}
#tmp="$(sudo hddtemp SATA:/dev/$disk | awk '{print $4}')"
[[ -a "/dev/$disk" ]] || dunstify -u normal -t 1000 "no such disk: $disk"
[[ -a "/dev/$disk" ]] || exit 1
tmp="$(sudo smartctl -x /dev/"$disk" | sed -n "s/Current Temperature:\([[:space:]]*\)\([1-6][0-9]\) Celsius/\2/gp")"        # echo "$tmp"
## notify-send -u critical -t 1000 "$tmp"
dunstify -u critical -t 1000 "$tmp"

