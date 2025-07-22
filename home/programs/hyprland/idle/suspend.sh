#!/usr/bin/env bash

# inhibited?
~/.config/hypr/scripts/idle/inhibitors/ac.sh || exit 1
~/.config/hypr/scripts/idle/inhibitors/pulse.sh || exit 1

sudo systemctl suspend
