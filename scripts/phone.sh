#!/bin/bash
adb devices
[[ ! "$1" = "push" ]] || [[ ! "$1" = "pull" ]]  || exit 1
echo "${PWD}"
case "$1" in
    push)
        phonepath="${3:-''}"
        phonepath="${3#/}"
        pathnow="${PWD}/$2"
        phonepath="/storage/emulated/0/$phonepath"
        echo "push from $pathnow to $phonepath"
        adb push --sync "$pathnow" "$phonepath" 
        ;;
    pull)
        phonepath="${2#/}"
        phonepath="/storage/emulated/0/$phonepath"
        pathnow="${PWD}/$3"
        echo "pull from $phonepath to $pathnow"
        adb pull "$phonepath" "$pathnow"
        ;;
esac
