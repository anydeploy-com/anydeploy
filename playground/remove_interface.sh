#!/bin/bash

remove_interface () {

# Define interface to remove variable (from input)
iface_to_remove=${1}
echo "iface to remove = ${iface_to_remove}"

# Detect if there are any bridges setup on selected interface

iface_to_remove_bridge=$(brctl show | grep "${1}" | awk '{print $1}')


# If exists - remove selected interface bridges from /etc/network/interfaces
if [ ! -z "${iface_to_remove_bridge}" ] ; then
echo "iface to remove bridge found - removing ${iface_to_remove_bridge}"
sed -i "/${iface_to_remove_bridge}/,/^$/d" /etc/network/interfaces
else
echo "no bridge interfaces found for : ${iface_to_remove_bridge}"
fi

# Removes selected interface from /etc/network/interfaces
echo "removing interface ${iface_to_remove}"
sed -i "/${iface_to_remove}/,/^$/d" /etc/network/interfaces

}

#remove_interface eno1
