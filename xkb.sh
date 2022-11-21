#!/usr/bin/env bash

# this is my script to set up my keyboard to how I like it, and if anyone ever needs to use qwerty I can easily change it back by running this script with -q

xset r rate 300 50

if [ "$1" = "-q" ]; then
setxkbmap us
xmodmap -e "keycode 47 = colon semicolon"

else

setxkbmap us -variant colemak
xmodmap -e "keycode 33 = colon semicolon"
fi
setxkbmap -option caps:swapescape
#
