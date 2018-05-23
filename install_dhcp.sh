#!/bin/bash


# Save Original IFS
SAVEIFS=$IFS

net_interfaces=($(ls /sys/class/net/*/device | grep "sys/class" | cut -d / -f 5))

IFS=$'\n'

# Find Vendor/Device ID

for i in "${net_interfaces[@]}"
do
  net_interfaces_vendev+=($(cat /sys/class/net/${i}/device/{vendor,device} | sed -e 's/\0x//g' | xargs | tr " " :))
done

# Get Device Name

for i in "${net_interfaces_vendev[@]}"
do
  net_interfaces_names+=($(lspci -nn | grep "${i}" | tail -n1 | cut -d ":" -f 3,4,5))
done


# Combine arrays for dialog display
net_interfaces_dialog=()
for i in "${net_interfaces}"; do net_interfaces_dialog+=( "${net_interfaces[${i}]}" "${net_interfaces_names[${i}]}" ); done


# Restore Original IFS
IFS=$SAVEIFS


dialog --clear \
    --cancel-label "BACK" \
    --title "Some Windows Edition" \
    --menu "$banner2080" 20 80 10 "${net_interfaces_dialog[@]}" 2> selected_interface.$$




echo "interfaces list: ${net_interfaces[@]}"
echo "vendev list: ${net_interfaces_vendev[@]}"
echo "vendev names: ${net_interfaces_names[@]}"
