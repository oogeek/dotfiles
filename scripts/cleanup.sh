#!/bin/bash
number="$(sudo pacman -Qtdq)"
[[ -z "$number" ]] && echo "no no no" || sudo pacman -Rns $(pacman -Qtdq)
