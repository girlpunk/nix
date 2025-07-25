#!/usr/bin/env bash

# If pulse says something is playing, don't lock
./inhibitors/pulse.sh || exit 1

# Start lock screen
pidof hyprlock || hyprlock
