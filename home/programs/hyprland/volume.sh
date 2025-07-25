#!/usr/bin/env zsh

wpctl set-volume @DEFAULT_SINK@ $1

printf %d\\n $(( "$(wpctl get-volume @DEFAULT_SINK@ | grep -Po '(?<=Volume: )\d+\.\d+')" * 100 )) > /run/user/1000/wob.sock

LOCKFILE=/run/user/1000/volume-notify

flock -n $LOCKFILE   pw-cat -p /home/sam/Music/awa.wav
