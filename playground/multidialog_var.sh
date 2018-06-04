#!/bin/bash

ip_address=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "IP Address:" 1 1 "IP Address" 1 25 25 15 2>&1 >/dev/tty)
subnet_mask=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "Subnet Mask:" 1 1 "Subnet Mask" 1 25 25 15 2>&1 >/dev/tty)
gateway=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "Gateway:" 1 1 "Gateway" 1 25 25 15 2>&1 >/dev/tty)
dns_server1=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "DNS Server 1:" 1 1 "DNS Server 1" 1 25 25 15 2>&1 >/dev/tty)
dns_server2=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "DNS Server 2:" 1 1 "DNS Server 2" 1 25 25 15 2>&1 >/dev/tty)
dns_server3=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "DNS Server 3:" 1 1 "DNS Server 3" 1 25 25 15 2>&1 >/dev/tty)
domain=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "Domain:" 1 1 "Domain" 1 25 25 15 2>&1 >/dev/tty)

echo "ip_address: ${ip_address[@]}"
echo "subnet_mask: ${subnet_mask[@]}"
echo "gateway: ${gateway[@]}"
echo "dns_server1: ${dns_server1[@]}"
echo "dns_server2: ${dns_server2[@]}"
echo "dns_server3: ${dns_server3[@]}"
echo "domain: ${domain[@]}"



sleep 1


#ip_address=$(dialog --backtitle "DHCP Setup - IP Settings for ${selected_interface}" --title "Dialog - IP settings for ${selected_interface}" --form "\n${bridge_desc}\n${ipaddr_desc}\n${gateway_desc}:" 25 60 16 "Server IP Address:" 1 1 "${proposed_ip}" 1 25 25 30)
#subnet_mask=$(dialog --backtitle "DHCP Setup - IP Settings for ${proposed_subnet}" --title "Dialog - IP settings for ${proposed_subnet}" --form "\n${bridge_desc}\n${ipaddr_desc}\n${gateway_desc}:" 25 60 16 "Server IP Address:" 1 1 "${proposed_subnet}" 1 25 25 30)
#dhcp_startip=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 3 | tail -n 1)
#dhcp_endip=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 4 | tail -n 1)
#gateway=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 5 | tail -n 1)
#dns_server1="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 6 | tail -n 1)"
#dns_server2="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 7 | tail -n 1)"
#dns_server3="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 8 | tail -n 1)"
#domain="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 9 | tail -n 1)"
