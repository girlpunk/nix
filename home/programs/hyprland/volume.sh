#!/usr/bin/env zsh

wpctl set-volume @DEFAULT_SINK@ $1

printf %d\\n $(( "$(wpctl get-volume @DEFAULT_SINK@ | grep -Po '(?<=Volume: )\d+\.\d+')" * 100 )) > /run/user/1000/wob.sock

LOCKFILE=/run/user/1000/volume-notify
#LOCKFD=99
#
#_lock()             { flock -$1 $LOCKFD; }
#_no_more_locking()  { _lock u; _lock xn && rm -f $LOCKFILE; }
#_prepare_locking()  { eval "exec $LOCKFD>\"$LOCKFILE\""; trap _no_more_locking EXIT; }
#
#_prepare_locking
#
#exlock_now()        { _lock xn; }  # obtain an exclusive lock immediately or fail
#exlock()            { _lock x; }   # obtain an exclusive lock
#shlock()            { _lock s; }   # obtain a shared lock
#unlock()            { _lock u; }   # drop a lock
#
#exlock_now || exit 1

#pacat ~/.local/share/Steam/steamui/sounds/deck_ui_volume.wav

flock -n $LOCKFILE   pw-cat -p /home/sam/Music/awa.wav
