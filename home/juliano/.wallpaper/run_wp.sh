#!/bin/bash

mpv ~/.wallpaper/wall.mp4 \
    --loop \
    --no-audio \
    --geometry=100%x100%+0+0 \
    --no-border \
    --no-input-default-bindings \
    --player-operation-mode=pseudo-gui \
    --vo=gpu-next \
    --hwdec=auto \
    --title=wallpaper \
    --force-window=yes \
    --no-osc \
    --cursor-autohide=2 \
    #--input-conf=/dev/null &
exit
