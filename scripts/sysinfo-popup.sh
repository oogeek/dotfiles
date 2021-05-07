 #/bin/bash

 HOST=$(uname -n)
 KERNEL=$(uname -r)
 UPTIME=$( uptime | sed 's/.* up //' | sed 's/[0-9]* us.*//' | sed 's/ day, /d /'\
          | sed 's/ days, /d /' | sed 's/:/h /' | sed 's/ min//'\
            |  sed 's/,/m/' | sed 's/  / /')
 PACKAGES=$(pacman -Q | wc -l)

 (
 echo "System Information"
 echo "Host: $HOST "
 echo "Kernel: $KERNEL"
 echo "Uptime: $UPTIME "
 echo "Pacman: $PACKAGES packages"
 ) | dzen2 -p -x "500" -y "30" -w "220" -l "5" -sa 'l' -ta 'c'\
    -title-name 'popup_sysinfo' -e 'onstart=uncollapse;button1=exit;button3=exit'

 # "onstart=uncollapse" ensures that slave window is visible from start.
