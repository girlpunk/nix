#!/usr/bin/env bash

# Skip AC check for longer timeout periods
if [[ $* != *--always* ]]; then
    # If on AC power, don't suspend
    ./inhibitors/ac.sh || exit 1
fi

# If pulse says something is playing, don't suspend
./inhibitors/pulse.sh || exit 1

# Suspend
systemctl suspend-then-hibernate
