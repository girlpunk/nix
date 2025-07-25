#!/usr/bin/env bash

# Restore previous brightness
brightnessctl -qr

# Turn on keyboard backlight
brightnessctl s -q -d 'tpacpi::kbd_backlight' 1
