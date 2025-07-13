#!/bin/bash
if [[ $(xrandr --verbose | sed -n '/ connected primary/p' | sed 's/ connected.*//') = "VGA1" ]]
then
xrandr --output HDMI1 --primary
else
xrandr --output VGA1 --primary
fi
