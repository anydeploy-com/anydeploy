#!/bin/bash

iface_to_remove_bridge=$(brctl show | grep "eno1" | awk '{print $1}')

echo "iface to remove bridge: ${iface_to_remove_bridge} "

if [ ! -z "${iface_to_remove_bridge}" ] ; then
echo "has value"
fi
