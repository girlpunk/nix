#!/usr/bin/env bash

brightnessctl -qr
brightnessctl s -q -d 'tpacpi::kbd_backlight' 1

#pkill -SIGRTMIN+20 i3blocks

#if swaymsg -t get_outputs -r | grep 3840; then
#    PREV_HDMI=$(cat /tmp/prev_hdmi_brightness)
#    echo "$(date) prev brightness: ${PREV_HDMI}" >> /tmp/brightness.log
#    hdmibrightness $PREV_HDMI
#fi
