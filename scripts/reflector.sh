 sudo reflector -c "$1" --latest 20  --protocol http,https --sort rate --verbose --save /etc/pacman.d/mirrorlist
