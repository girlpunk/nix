#!/usr/bin/env bash

# Skip AC check for longer timeout periods
if [[ $* != *--always* ]]; then
    # If on AC power, don't turn off monitor
    ./inhibitors/ac.sh || exit 1
fi

# If pulse says something is playing, don't turn off monitor
./inhibitors/pulse.sh || exit 1

# Turn off monitor
hyprctl dispatch dpms off
