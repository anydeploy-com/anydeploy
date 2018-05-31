#!/bin/bash

zenity --backtitle "Dialog - Form sample" \
    --form " Form Test - use [up] [down] to select input field " 21 70 18 \
    "Network-ID:" 2 2 "" 2 15 20 0\
    "Subnet Mask:" 4 2 "" 4 15 20 0\

if test $? -eq 0
then
   echo "ok pressed"
else
   echo "cancel pressed"
fi
