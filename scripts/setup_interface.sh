#!/bin/bash

. /anydeploy/includes/functions.sh
. /anydeploy/settings/global.sh


select_interface () {

SAVEIFS=$IFS
# Array of physical interfaces
interfaces=($(ls /sys/class/net/*/device | grep "sys/class" | cut -d / -f 5))
# Interfaces Devpaths
for interface in "${interfaces[@]}" ; do interfaces_devpath+=($(readlink -f /sys/class/net/${interface})) ; done

for interface_path in ${interfaces_devpath[@]} ; do
# Interface Buses
interface_bus+=($(udevadm info --path=$interface_path | grep "ID_BUS" | cut -d "=" -f 2))
# Interface Vendor ID
interface_vendor_id+=($(udevadm info --path=$interface_path | grep "ID_VENDOR_ID" | cut -d "=" -f 2 | sed -e 's/\0x//g'))
# Interface Model ID
interface_model_id+=($(udevadm info --path=$interface_path | grep "ID_MODEL_ID" | cut -d "=" -f 2 | sed -e 's/\0x//g'))
done
# Interface VENDEV ID ie (8086:1502)
for i in "${!interfaces[@]}"; do interface_vendev_id+=( "${interface_vendor_id[${i}]}":"${interface_model_id[${i}]}" ); done
# Device Names

    # Change IFS for proper device names (contain spaces)
    IFS=$'\n'

interface_name=()
for iface_index in "${!interface_bus[@]}"; do
  if [ "${interface_bus[${iface_index}]}" = "pci"  ] ; then
  # Interface Name (PCI)
          #sample : interface_name+=($(lspci -d 8086:15a2 | cut -d ":" -f 3,4,5 | xargs))
  interface_name+=($(lspci -d ${interface_vendev_id[${iface_index}]} | tail -n1 | cut -d ":" -f 3,4,5 | xargs))
  elif [ "${interface_bus[${iface_index}]}" = "usb"  ] ; then
  # Interface Name (USB)
          #sample : interface_name+=($(lsusb -d 0b95:7720 | sed -e 's/.*0b95:7720//' | xargs))
  interface_name+=($(lsusb -d ${interface_vendev_id[${iface_index}]} | tail -n1 | awk '{$1=$2=$3=$4=$5=$6="";print $0}' | xargs))
  else
  # Interface Name (UNKNOWN)
  echo "Warning - this interface is unknown" # TODO - add to log file
  interface_name+=("unknown")
  fi
done




# Combine Arrays for dialog display
for i in "${!interfaces[@]}"; do
  # Interface Dialog Name
interface_dialog_name+=("${interfaces[${i}]}" "${interface_bus[${i}]}: ${interface_name[${i}]}")
  # Interface Dialog Name
interface_dialog_selection+=("${interfaces[${i}]}" "${interface_name[${i}]}" "off")
done


# Dialog single interface menu

selected_interface=$(dialog --backtitle "DHCP Setup - Interface Selection" \
                    --menu "please pick interfaces for dhcp server to listen on" 30 100 10 ${interface_dialog_name[@]} 2>&1 >/dev/tty)

                    if test $? -eq 0
                    then
                       echo "ok pressed"
                       # save to global config
                       sed -e "/default_interface=/ s/=.*/=\"${selected_interface}\"/" global.sh
                       sed -e "/default_bridge=/ s/=.*/=\"anybr0\"/" global.sh
                    else
                       echo "cancel pressed"
                       cleanup
                       exit 1;
                    fi

    # Fix back IFS
    IFS=$SAVEIFS

cleanup

}







cleanup () {
  echo "cleaning up"
  interface_dialog_name=()
  rm /anydeploy/tmp/dhcp_discover.$$
  rm /anydeploy/tmp/ip_settings_form.$$
}


select_interface
