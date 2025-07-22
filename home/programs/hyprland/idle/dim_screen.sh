#!/usr/bin/env bash

~/.config/hypr/scripts/idle/inhibitors/pulse.sh || exit 1
#echo "$(date) dim_screen.sh running" >> /tmp/brightness.log

#if swaymsg -t get_outputs -r | grep 3840; then
#    hdmibrightness get > /tmp/prev_hdmi_brightness
#    hdmibrightness 0
#fi

# inhibited by AC or pulse?
~/.config/hypr/scripts/idle/inhibitors/ac.sh || exit 1

# Save current brightness state, and set 10% as the new state
brightnessctl -qs
brightnessctl -q set 5%
brightnessctl s -q -d 'tpacpi::kbd_backlight' 0

#echo "wrote brightness 10% ($IDLE_BRIGHTNESS}. max: $MAX" >> /tmp/brightness.log
#pkill -SIGRTMIN+20 i3blocks
