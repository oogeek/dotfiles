#!/bin/bash
if [[ -n "$1" ]]; then
    sudo udisksctl unmount -b /dev/"$1"
    sudo udisksctl power-off -b /dev/"$1"
    if [[ "$?" = "0" ]];
        then echo "success"
    fi
fi
