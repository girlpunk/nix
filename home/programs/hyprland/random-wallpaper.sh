#!/usr/bin/env bash

monitors=$(hyprctl monitors | grep Monitor | awk '{print $2}') # get monitors

for monitor in $monitors; do
    wallpaper=$(find /usr/share/wallpapers/*/contents  -type f | shuf -n 1)
    hyprctl hyprpaper preload $wallpaper
    hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
done

sleep 0.25s # wait for wallpaper to load

hyprctl hyprpaper unload all  # unload old wallpaper
