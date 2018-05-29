#!/bin/bash

# List interfaces

# GET IP

#hostname -I


select_interface () {

SAVEIFS=$IFS


interfaces=($(ls /sys/class/net/*/device | grep "sys/class" | cut -d / -f 5))                                                                     # Interface Name
for interface in "${interfaces[@]}" ; do interfaces_devpath+=($(readlink -f /sys/class/net/${interface})) ; done                                  # Interface Devpath
for interface_path in ${interfaces_devpath[@]} ; do
interface_bus+=($(udevadm info --path=$interface_path | grep "ID_BUS" | cut -d "=" -f 2))                                                         # Interface Bus
interface_vendor_id+=($(udevadm info --path=$interface_path | grep "ID_VENDOR_ID" | cut -d "=" -f 2 | sed -e 's/\0x//g'))                         # Interface Vendor ID
interface_model_id+=($(udevadm info --path=$interface_path | grep "ID_MODEL_ID" | cut -d "=" -f 2 | sed -e 's/\0x//g'))                           # Interface Model ID
done
for i in "${!interfaces[@]}"; do interface_vendev_id+=( "${interface_vendor_id[${i}]}":"${interface_model_id[${i}]}" ); done                      # Interface VENDEV ID
# Device Names

# Change IFS for proper device names (contain spaces)
IFS=$'\n'

interface_name=()
for iface_index in "${!interface_bus[@]}"; do
  if [ "${interface_bus[${iface_index}]}" = "pci"  ] ; then
  #sample : interface_name+=($(lspci -d 8086:15a2 | cut -d ":" -f 3,4,5 | xargs))
  interface_name+=($(lspci -d ${interface_vendev_id[${iface_index}]} | tail -n1 | cut -d ":" -f 3,4,5 | xargs))                                   # Interface Name (PCI)
  elif [ "${interface_bus[${iface_index}]}" = "usb"  ] ; then
  #sample : interface_name+=($(lsusb -d 0b95:7720 | sed -e 's/.*0b95:7720//' | xargs))
  interface_name+=($(lsusb -d ${interface_vendev_id[${iface_index}]} | tail -n1 | awk '{$1=$2=$3=$4=$5=$6="";print $0}' | xargs))                 # Interface Name (USB)
  else
  echo "Warning - this interface is unknown" # TODO - add to log file
  interface_name+=("unknown")                                                                                                                     # Interface Name (UNKNOWN)
  fi
done

# Fix back IFS


# Combine Arrays for dialog display
for i in "${!interfaces[@]}"; do
interface_dialog_name+=("${interfaces[${i}]}" "${interface_bus[${i}]}: ${interface_name[${i}]}")                                                   # Interface Dialog Name
interface_dialog_selection+=("${interfaces[${i}]}" "${interface_name[${i}]}" "off")                                                                # Interface Dialog Name
done


# Dialog single interface menu

export selected_interface=$(dialog --backtitle "DHCP Server - Interface Selection" \
                    --menu "please pick interfaces for dhcp server to listen on" 30 100 10 ${interface_dialog_name[@]} 2>&1 >/dev/tty)


# Dialog Checkboxes

#selected_interface_dialog=$(dialog --checklist "please pick interfaces for dhcp server to listen on" 30 100 10 ${interface_dialog_selection[@]} 2>&1 >/dev/tty)

#export selected_interface=($(echo $selected_interface_dialog | tr " " ,)) # Add , between interfaces if multiple
#echo "selected interfaces:" $selected_interface # Echo for debugging

IFS=$SAVEIFS

#echo INTERFACES INDEXES: ${!interfaces[@]}
#echo INTERFACES LIST: ${interfaces[@]}
#echo INTERFACES DEVPATHS: ${interfaces_devpath[@]}
#echo INTERFACE BUS: ${interface_bus[@]}
#echo INTERFACE VENDOR_ID: ${interface_vendor_id[@]}
#echo INTERFACE MODEL_ID: ${interface_model_id[@]}
#echo INTERFACE VENDEV_ID: ${interface_vendev_id[@]}
#echo INTERFACE NAME: ${interface_name[@]}
#echo ""
#echo INTERFACE NAME1: ${interface_name[0]}
#echo INTERFACE NAME2: ${interface_name[1]}
#echo INTERFACE NAME3: ${interface_name[2]}
#echo ""
#echo DIALOG NAME1: ${interface_dialog_name[0]}
#echo DIALOG NAME2: ${interface_dialog_name[1]}
#echo DIALOG NAME3: ${interface_dialog_name[2]}
#echo DIALOG_SELECTION: ${interface_dialog_selection[@]}

setup_ip

}



setup_ip () {

# TODO - if on ubuntu detect if using netplan and remove this crap

# TODO - if interface has ip already also detect and display

# TODO - if dhcp server installed detect current ip addresses

# TODO detect bridged interfaces

# brctl | grep ${selected_interface}


# REMOVE BRIDGE


# Down interface to be able to remove bridge
# ifconfig eno1 down
# ifconfig br0 down
# brctl delbr br0




dialog --backtitle "DHCP Server - IP Settings for ${selected_interface}" --title "Dialog - Form" \
--form "\nIP Adresses Setup:" 25 60 16 \
"Server IP Address:" 1 1 "10.1.1.1" 1 25 25 30 \
"DHCP Start IP:" 2 1 "10.1.1.50" 2 25 25 30 \
"DHCP End IP:" 3 1 "10.1.1.250" 3 25 25 30 \
"Gateway:" 4 1 "10.1.1.254" 4 25 25 30 \
2>/anydeploy/tmp/form.$$


ip_address=$(cat /anydeploy/tmp/form.$$ | head -n 1)
dhcp_startip=$(cat /anydeploy/tmp/form.$$ | head -n 2 | tail -n 1)
dhcp_endip=$(cat /anydeploy/tmp/form.$$ | head -n 3 | tail -n 1)
gateway=$(cat /anydeploy/tmp/form.$$ | head -n 4 | tail -n 1)

echo "IP Address: ${ip_address}"
echo "DHCP Start IP: ${dhcp_startip}"
echo "DHCP End IP: ${dhcp_endip}"
echo "Gateway IP: ${gateway}"

sleep 5

}

select_interface
