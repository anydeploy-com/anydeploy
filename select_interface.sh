#!/bin/bash


# Save Original IFS
SAVEIFS=$IFS


# Interesting command to identify physical network devices only

#ls -la /sys/class/net/*/device

# Interesting Command to show full path

#readlink -f /sys/class/net/*


net_interfaces=($(ls /sys/class/net/*/device | grep "sys/class" | cut -d / -f 5))

IFS=$'\n'

# Find Vendor/Device ID

for interface in "${net_interfaces[@]}"
do
echo ${interface}
  if [ ! -f /sys/class/net/${interface}/device/vendor ]; then
    # TODO - IDENTIFY USB NETWORK DEVICES AND ADD VENDORID and MODEL
  net_interfaces_vendev+=('0000:0000')
  else
    net_interfaces_vendev+=($(cat /sys/class/net/${interface}/device/{vendor,device} | sed -e 's/\0x//g' | xargs | tr " " :))
  fi
done

#echo "netinterfaces ven dev: ${net_interfaces_vendev[@]}"

# Get Device Name

for vendev in "${net_interfaces_vendev[@]}"
do
echo $vendev
  if [[ -z $(lspci -nn | grep "${vendev}" | tail -n1) ]]; then
  net_interfaces_names+=($(echo "Unknown Network Device"))
  else
  echo "variable has value set";
  net_interfaces_names+=($(lspci -nn | grep "${vendev}" | tail -n1 | cut -d ":" -f 3,4,5 | xargs))
  fi
done

# Combine arrays for dialog display
net_interfaces_dialog=()
for i in "${!net_interfaces[@]}"; do net_interfaces_dialog+=( "${net_interfaces[${i}]}" "${net_interfaces_names[${i}]}" ); done


# Restore Original IFS
IFS=$SAVEIFS


dialog --clear \
   --cancel-label "BACK" \
   --title "Select interface for DHCP server to listen on:" \
       --menu "$banner2080" 25 90 30 "${net_interfaces_dialog[@]}" 2> selected_interface.$$




#echo "interfaces list: ${net_interfaces[@]}"
#echo "vendev list: ${net_interfaces_vendev[@]}"
#echo "vendev names: ${net_interfaces_names[@]}"
#echo "vendev names: ${net_interfaces_dialog[@]}"
#echo "net name: ${net_name[2]}"


#if [ "$gender" = "male" ]; then echo "it's a man"; else echo "it's a female"; fi
