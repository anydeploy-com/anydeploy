#!/bin/bash

. /anydeploy/includes/functions.sh

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




# Combine Arrays for dialog display
for i in "${!interfaces[@]}"; do
interface_dialog_name+=("${interfaces[${i}]}" "${interface_bus[${i}]}: ${interface_name[${i}]}")                                                   # Interface Dialog Name
interface_dialog_selection+=("${interfaces[${i}]}" "${interface_name[${i}]}" "off")                                                                # Interface Dialog Name
done


# Dialog single interface menu

selected_interface=$(dialog --backtitle "DHCP Setup - Interface Selection" \
                    --menu "please pick interfaces for dhcp server to listen on" 30 100 10 ${interface_dialog_name[@]} 2>&1 >/dev/tty)


# Dialog Checkboxes

#selected_interface_dialog=$(dialog --checklist "please pick interfaces for dhcp server to listen on" 30 100 10 ${interface_dialog_selection[@]} 2>&1 >/dev/tty)

#export selected_interface=($(echo $selected_interface_dialog | tr " " ,)) # Add , between interfaces if multiple
#echo "selected interfaces:" $selected_interface # Echo for debugging

# Fix back IFS
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

# Detect Current IP address and add message.

selected_interface_old_ip=$(ifconfig ${selected_interface} | grep inet | awk '{print $2}')

#echo "Selected interface old ip : ${selected_interface_old_ip}"


if [ ! -z "${selected_interface_old_ip}" ]; then
#  echo "old ip has value"
  proposed_ip="${selected_interface_old_ip}"
#  echo "Proposed ip = ${proposed_ip}"
  ipaddr_desc="Your system had IP address attached on selected interface, using same IP as default"
else
#  echo "no ip found - usin/etc/default/isc-dhcp-serverg default as proposed ip"
  proposed_ip="192.168.1.254"
  proposed_dhcp_start="192.168.1.10"
  proposed_dhcp_end="192.168.1.200"
  ipaddr_desc="Your system didn't have any IP address attached on selected interface, using defaults"
fi


# Detect running dhcp server and setup gateway ip if current exists - run as seperate process (&)

nmap --script broadcast-dhcp-discover -e ${selected_interface} &> /anydeploy/tmp/dhcp_discover.$$ &


# Display dhcp detection script (takes 25 seconds for nmap to detect if missing)
# TODO - make process shorter if dhcp_discover already contains variables

for i in $(seq 0 1 100) ; do sleep 0.25; echo $i | dialog --backtitle "DHCP Setup - Detecting Current DHCP settings on ${selected_interface}" --gauge "Detecting your current dhcp settings (ip address, subnet, gateway etc.)" 10 70 0; done



# If dhcp server installed detect current ip addresses

current_gateway_ip=$(cat /anydeploy/tmp/dhcp_discover.$$ | sed -n 's/Router://p' | cut -d "|" -f 2 | xargs)


if [ ! -z "${current_gateway_ip}" ]; then
#    echo "dhcp server exists on selected interface"
#    echo "Current Gateway IP Address: ${current_gateway_ip}"
    proposed_gateway="${current_gateway_ip}"
    proposed_subnet=$(cat /anydeploy/tmp/dhcp_discover.$$ | grep "Subnet Mask:" | sed -n 's/Subnet Mask://p' | cut -d "|" -f 2 | xargs)
    subnet_pre=$(echo ${current_gateway_ip} | cut -d "." -f 1,2,3)
    proposed_dhcp_start="${subnet_pre}.10"
    proposed_dhcp_end="${subnet_pre}.250"
    gateway_desc="Gateway found on selected interface, using same as default"


    # Detect DNS Servers
    dns_servers=$(cat /anydeploy/tmp/dhcp_discover.$$ | grep "Domain Name Server:" | sed -n 's/Domain Name Server: //p' | cut -d "|" -f 2 | xargs)

    dns_server1=$(echo ${dns_servers} | cut -d " " -f 1 | tr -d "," )
    dns_server2=$(echo ${dns_servers} | cut -d " " -f 2 | tr -d "," )
    dns_server3=$(echo ${dns_servers} | cut -d " " -f 3 | tr -d "," )

    # Get Domain # TODO change to anydeploy if empty

    domain=$(cat /anydeploy/tmp/dhcp_discover.$$ | grep "Domain Name:" | sed -n 's/Domain Name://p' | cut -d "|" -f 2 | xargs
    ldcd.co.uk)


else
#    echo "dhcp server doesn't exist on selected interface"
    proposed_subnet="255.255.255.0"
    proposed_gateway=""
    proposed_dhcp_start="192.168.1.10"
    proposed_dhcp_end="192.168.1.250"
    gateway_desc="Couldn't find default gateway, using empty"
    domain="anydeploy"
    dns_server1="8.8.8.8"
    dns_server2="8.8.4.4"
fi

# TODO detect bridged interfaces

# brctl show | grep ${selected_interface}


# REMOVE BRIDGE

# Down interface to be able to remove bridge

# brctl delif br0 eno1
# ifconfig br0 down
# brctl delbr br0

# service networking restart




# TODO add question - configure as bridge, support apple mac's, enable forwarding (if no gateway is specified)



dialog --backtitle "DHCP Setup - IP Settings for ${selected_interface}" --title "Dialog - IP settings for ${selected_interface}" \
--form "\n${ipaddr_desc}\n${gateway_desc}:" 25 60 16 \
"Server IP Address:" 1 1 "${proposed_ip}" 1 25 25 30 \
"Subnet Mask:" 2 1 "${proposed_subnet}" 2 25 25 30 \
"DHCP Start IP:" 3 1 "${proposed_dhcp_start}" 3 25 25 30 \
"DHCP End IP:" 4 1 "${proposed_dhcp_end}" 4 25 25 30 \
"Gateway:" 5 1 "${proposed_gateway}" 5 25 25 30 \
"DNS1:" 7 1 "${dns_server1}" 7 25 25 30 \
"DNS2:" 8 1 "${dns_server2}" 8 25 25 30 \
"DNS3:" 9 1 "${dns_server3}" 9 25 25 30 \
"Domain:" 11 1 "${domain}" 11 25 25 30 \
2>/anydeploy/tmp/ip_settings_form.$$


# Get values after form is processed

ip_address=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 1)
subnet_mask=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 2 | tail -n 1)
dhcp_startip=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 3 | tail -n 1)
dhcp_endip=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 4 | tail -n 1)
gateway=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 5 | tail -n 1)
dns_server1="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 6 | tail -n 1)"
dns_server2="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 7 | tail -n 1)"
dns_server3="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 8 | tail -n 1)"
domain="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 9 | tail -n 1)"

    # TODO prompt to enable postrouting if gateway empty



#echo "${selected_interface} old IP address: ${selected_interface_old_ip}"
#echo "IP Address: ${ip_address}"
#echo "DHCP Start IP: ${dhcp_startip}"
#echo "DHCP End IP: ${dhcp_endip}"
#echo "Gateway IP: ${gateway}"

configure_interface
# Fix back IFS
}

configure_interface () {
echo "TBD"

# /etc/network/interfaces

      # make copy (.anybackup)

      # remove selected interface until first space

      # remove bridge connected to selected interface until space

      # add interface lines (don't overwrite)

      # add vmbr0 lines (don't overwrite)

      # restart networking

# /etc/resolv.conf

      # make copy (.anybackup)

      # overwrite with selected dns servers

install_isc_dhcp

}

install_isc_dhcp () {

  # TODO - check if already installed and prompt what to do

        apt-get install isc-dhcp-server -y

configure_isc_dhcp
}


configure_isc_dhcp () {

echo "TBD"

  # /etc/default/isc-dhcp-server

        # make copy (.anybackup)

        cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.anybackup

        # replace interface (ipv4)

        sed -i -e "/INTERFACESv4=/ s/=.*/=${selected_interface}/" /etc/default/isc-dhcp-server


  # /etc/dhcp/dhcpd.conf

        # make copy (.anybackup)

        cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.anybackup

        # overwrite with EOF + variables


#        ${ip_address}
#        ${subnet_mask}
#        ${dhcp_startip}
#        ${dhcp_endip}
#        ${gateway}
#        ${dns_server1}
#        ${dns_server2}
#        ${dns_server3}
#        ${domain}


cat >"/etc/dhcp/dhcpd.conf" << EOF
        option domain-name "${domain}";
        option domain-name-servers ${dns_server1}, ${dns_server2};
        # Set up our desired subnet:
        subnet 192.168.1.0 netmask ${subnet_mask} {
            range ${dhcp_startip} ${dhcp_endip};
            option subnet-mask ${subnet_mask};
            option broadcast-address 192.168.1.255;
            option routers ${gateway};
            option domain-name-servers home;
        }
        default-lease-time 600;
        max-lease-time 7200;
        # Show that we want to be the only DHCP server in this network:
        authoritative;
EOF

        # restart isc dhcp

        sudo service isc-dhcp-server restart

cleanup

}

cleanup () {
  echo "cleaning up"
#  rm /anydeploy/tmp/dhcp_discover.$$
#  rm /anydeploy/tmp/ip_settings_form.$$
}


select_interface
