#!/bin/bash

# List interfaces



interfaces=($(ls /sys/class/net/*/device | grep "sys/class" | cut -d / -f 5))                                             # Interface names
for interface in "${interfaces[@]}" ; do interfaces_fullpath+=($(readlink -f /sys/class/net/${interface})) ; done         # Interface Fullpaths
for interface_path in ${interfaces_fullpath[@]} ; do interface_usbfilter+=($(echo $interface_path | grep "usb")) ; done   # Filter if interface is USB
#echo ${interfaces[@]}
#echo ${interfaces_fullpath[@]}
echo ${interface_usbfilter[2]}
