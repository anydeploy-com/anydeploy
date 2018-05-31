#!/bin/bash

# make backup of interfaces file
cp /etc/network/interfaces /etc/network/interfaces.anybackup

# list bridges with following interface

bridge_with_selected_interface=$(brctl show | grep eno1 | awk '{print $1}')

# if bridges_with_selected_interface has value then

brctl delif ${bridge_with_selected_interface} ${selected_interface}

# stop bridge before delete

ifconfig ${bridge_with_selected_interface} down

# delete bridge afterwards

brctl delbr ${bridge_with_selected_interface}





# delete every matching ${bridge_with_selected_interface} from /etc/network/interfaces

#TODO

# delete every matching ${selected_interface} from /etc/network/interfaces















# restart networking

ifdown eno1
ifdown vmbr0

ifup eno1
ifup vmbr0

service networking restart
