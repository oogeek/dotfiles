#!/bin/bash
xclip -selection clipboard -o | qrencode -o - | xclip -selection clipboard -t image/png
xclip -selection clipboard -o | feh -F -
