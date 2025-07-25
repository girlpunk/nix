#!/usr/bin/env bash

# If pulseaudio says something is playing, don't dim
./inhibitors/pulse.sh || exit 1

# Skip AC check for longer timeout periods
if [[ $* != *--always* ]]; then
    # If on AC power, don't dim
    ./inhibitors/ac.sh || exit 1
fi

# Save current brightness state
brightnessctl -qs

# Set 5% as new brightness
brightnessctl -q set 5%

# Turn off keyboard backlight
brightnessctl s -q -d 'tpacpi::kbd_backlight' 0
