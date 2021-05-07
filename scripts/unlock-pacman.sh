#!/bin/bash
if [[ -a "/var/lib/pacman/db.lck" ]] ; then
    echo "Lock exist"
    sudo rm /var/lib/pacman/db.lck && dunstify -u critical -t 2000 "Lock removed"
else echo "No such lock"
fi
