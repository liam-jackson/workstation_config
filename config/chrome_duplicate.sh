#!/bin/bash

xdotool search --onlyvisible --name ".*Google Chrome.*" windowactivate --sync
sleep 0.1
xdotool key --clearmodifiers ctrl+l
sleep 0.1
xdotool key ctrl+c
sleep 0.1
xdotool key ctrl+t
sleep 0.1
xdotool key ctrl+v
sleep 0.1
xdotool key Return
