#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions

##############################################################################
#                  Verify if interface is selected                           #
##############################################################################

      verify_interface_selection () {

# If no interface is selected display warning (5 secs) and prompt to go to interface selection + call script


    if [ ! -z "${selected_interface}" ]; then
        if [ "${debugging}" = "yes" ]; then
          echo "DEBUG: interface is selected"
          echo "DEBUG: selected interface: ${selected_interface}"
          echo "DEBUG: Calling detect_bridge function"
          sleep 5
        fi
        detect_bridge
    else
      if [ "${debugging}" = "yes" ]; then
      echo "DEBUG: no interface selected"
      echo "DEBUG: running dialog window to prompt user if he want to select interface"
      sleep 5
      fi
      dialog --title "Reconfigure Interface" \
      --backtitle "Anydeploy - Reconfigure Interface" \
      --yesno "No interface has been selected yet. Would you like to select one now?" 7 60

      response=$?
      case $response in
         0) if [ "${debugging}" = "yes" ]; then
           echo "DEBUG: Going to interface selection"
           sleep 5
           fi
           ./select_interface.sh
           if [ "${debugging}" = "yes" ]; then
             echo "DEBUG: Re-running self since interface was re-selected"
             sleep 5
             fi
           ${install_path}/scripts/setup/detect_dhcp.sh;;
         1) echo "DEBUG: Don't select interface selected - exiting script"
         sleep 5
         exit 1
         ;;
         255) echo "[ESC] key pressed.";;
      esac
    fi
    }

    ##############################################################################
    #          Detect Bridge on ${selected_interface} + bridge ip                #
    ##############################################################################

    detect_bridge () {
      if [ "${debugging}" = "yes" ]; then
        echo "DEBUG: Running bridge detection"
        sleep 5
        fi
    selected_interface_bridge=$(brctl show | grep "${selected_interface}" | awk '{print $1}')

    if [ ! -z "${selected_interface_bridge}" ] ; then

        bridge_desc="Bridge has been detected on selected interface. Using bridge settings detection"
        selected_interface_old_ip=$(ifconfig ${selected_interface_bridge} | grep "inet " | awk '{print $2}')
        if [ "${debugging}" = "yes" ]; then
            echo "DEBUG: Bridge has been detected on selected interface. Bridge name = ${selected_interface_bridge}"
            echo "DEBUG: Bridge detected ip is ${selected_interface_old_ip}"
            sleep 5
        fi
    else
          if [ "${debugging}" = "yes" ]; then
              echo "DEBUG: No bridge has been found"
              sleep 5
          fi
        selected_interface_old_ip=$(ifconfig ${selected_interface} | grep "inet " | awk '{print $2}')
        bridge_desc=""
    fi

    ##############################################################################
    #                               Detect IP                                    #
    ##############################################################################



    if [ ! -z "${selected_interface_old_ip}" ]; then
    #  echo "old ip has value"
      proposed_ip="${selected_interface_old_ip}"
    #  echo "Proposed ip = ${proposed_ip}"
      ipaddr_desc="Your system had IP address attached on selected interface, using same IP as default"
    else
    #  echo "no ip found - usin/etc/default/isc-dhcp-serverg default as proposed ip"
      proposed_ip="192.168.1.254"
    #  proposed_dhcp_start="192.168.1.10"
    #  proposed_dhcp_end="192.168.1.200"
      ipaddr_desc="Your system didn't have any IP address attached on selected interface, using defaults"
    fi

    setup_ip
}

setup_ip () {

# TODO - if on ubuntu detect if using netplan and remove it + install ifupdown

# Detect Current IP address and add message.

  # Define Bridge interface if it's configured




#echo "Selected interface old ip : ${selected_interface_old_ip}"




# Detect running dhcp server and setup gateway ip if current exists - run as seperate process (&)

if [ "${debugging}" = "yes" ]; then
    echo "DEBUG: Gonna killall dhcpcd to ensure no dummy processes are running"
    sleep 5
fi
killall dhcpcd > /dev/null


if [ "${debugging}" = "yes" ]; then
    echo "DEBUG: Going to use dhcpcd to detect dhcp settings running on selected interface/bridge"
    sleep 5
fi

if [ ! -z "${selected_interface_bridge}" ] ; then
dhcpcd -T ${selected_interface_bridge} &> /anydeploy/tmp/dhcp_discover.$$ &
else
dhcpcd -T ${selected_interface} &> /anydeploy/tmp/dhcp_discover.$$ &
fi

pid=$(ps aux | grep dhcpcd -T | grep -v grep | awk '{print $2}')


i=0
while kill -0 $pid 2>/dev/null
do
  i=$(( (i+1) %4 ))
  #printf " - Detecting Current DHCP Settings\r${spin:$i:1}"
  for i in $(seq 0 1 100) ; do sleep 0.05; echo $i | dialog --backtitle "DHCP Setup - Detecting Current DHCP settings on ${selected_interface}" --gauge "Detecting your current dhcp settings (ip address, subnet, gateway etc.)" 10 70 0; done
done




# Display dhcp detection script (wait 25 seconds before declare it missing)
# TODO - make process shorter if dhcp_discover already contains variables


#for i in $(seq 0 1 100) ; do sleep 0.25; echo $i | dialog --backtitle "DHCP Setup - Detecting Current DHCP settings on ${selected_interface}" --gauge "Detecting your current dhcp settings (ip address, subnet, gateway etc.)" 10 70 0; done

# If dhcp server installed detect current ip addresses

current_gateway_ip=$(cat /anydeploy/tmp/dhcp_discover.$$ | grep new_routers | uniq | cut -d "=" -f 2 | tr "'" " " | xargs)


if [ ! -z "${current_gateway_ip}" ]; then
#    echo "dhcp server exists on selected interface"
#    echo "Current Gateway IP Address: ${current_gateway_ip}"
    proposed_gateway="${current_gateway_ip}"
    proposed_subnet=$(cat /anydeploy/tmp/dhcp_discover.$$ | grep "new_subnet_mask" | cut -d "=" -f 2 | tr "'" " " | xargs)
    subnet_pre=$(echo ${proposed_ip} | cut -d "." -f 1,2,3)
    proposed_dhcp_start="${subnet_pre}.10"
    proposed_dhcp_end="${subnet_pre}.250"
    gateway_desc="Gateway found on selected interface, using same as default"


    # Detect DNS Servers
    dns_servers=$(cat /anydeploy/tmp/dhcp_discover.$$ | grep "new_domain_name_servers" | cut -d "=" -f 2 | tr "'" " " | xargs | tr " " ",")

    dns_server1=$(echo ${dns_servers} | cut -d "," -f 1)
    dns_server2=$(echo ${dns_servers} | cut -d "," -f 2)
    dns_server3=$(echo ${dns_servers} | cut -d "," -f 3)

    # Get Domain # TODO change to anydeploy if empty

    domain=$(cat /anydeploy/tmp/dhcp_discover.$$ | grep "new_domain_name=" | cut -d "=" -f 2 | tr "'" " " | xargs)


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

# TODO detect bridged interfaces)

# brctl show | grep ${selected_interface}


# REMOVE BRIDGE

# Down interface to be able to remove bridge

# brctl delif br0 eno1
# ifconfig br0 down
# brctl delbr br0

# service networking restart




# TODO add question - configure as bridge, support apple mac's, enable forwarding (if no gateway is specified)


# Get values after form is processed

ip_address=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "IP Address:" 1 1 "${proposed_ip}" 1 25 25 15 2>&1 >/dev/tty)
subnet_mask=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "Subnet Mask:" 1 1 "${proposed_subnet}" 1 25 25 15 2>&1 >/dev/tty)
gateway=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "Gateway:" 1 1 "${proposed_gateway}" 1 25 25 15 2>&1 >/dev/tty)
dns_server1=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "DNS Server 1:" 1 1 "${dns_server1}" 1 25 25 15 2>&1 >/dev/tty)
dns_server2=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "DNS Server 2:" 1 1 "${dns_server2}" 1 25 25 15 2>&1 >/dev/tty)
dns_server3=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "DNS Server 3:" 1 1 "${dns_server3}" 1 25 25 15 2>&1 >/dev/tty)
domain=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "Domain:" 1 1 "${domain}" 1 25 25 15 2>&1 >/dev/tty)


if [ -z "${proposed_gateway}" ]; then
  dialog --title "Postrouting" \
  --backtitle "anydeploy No gateway defined - enable postrouting" \
  --yesno "No gateway has been defined - would you like to enable postrouting?\n\n This will enable internet access on ${selected_interface} interface" 10 70

  # Get exit status
  # 0 means user hit [yes] button.
  # 1 means user hit [no] button.
  # 255 means user hit [Esc] key.
  response=$?
  case $response in
     0) echo "Enabling postrouting"
      # Enable forwarding
      sysctl -w net.ipv4.ip_forward=1
      # Save Changes for pernament
      echo "1" > /proc/sys/net/ipv4/ip_forward
      # Uncomment /etc/sysctl.conf # net.ipv4.ip_forward=1
      sed -i '/net.ipv4.ip_forward/s/^#//g' /etc/sysctl.conf
      # Live Apply changes
      sysctl -p
      # Detect internet enabled interface
      net_iface=$(route | grep "default" | awk '{print $8}')


      # IPTABLES

      #Install iptables-persistent



      apt-get install iptables-persistent -y
      rm /etc/iptables/rules.v4
      touch /etc/iptables/rules.v4
cat >"/etc/iptables/rules.v4" << EOF
*nat
:PREROUTING ACCEPT [3448:701197]
:INPUT ACCEPT [2617:608016]
:OUTPUT ACCEPT [635:137144]
:POSTROUTING ACCEPT [180:14711]
-A POSTROUTING -o ${net_iface} -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT [44701:49666478]
:FORWARD ACCEPT [244334:236658033]
:OUTPUT ACCEPT [28299:3566120]
COMMIT
EOF
      # Apply iptables rules
      iptables-apply /etc/iptables/rules.v4

      ;;
     1) echo "Postrouting not enabled - skipping";;
     255) echo "[ESC] Postrouting not enabled - skipping";;
  esac
fi




#dialog --backtitle "DHCP Setup - IP Settings for ${selected_interface}" --title "Dialog - IP settings for ${selected_interface}" \
#--form "\n${bridge_desc}\n${ipaddr_desc}\n${gateway_desc}:" 25 60 16 \
#"Server IP Address:" 1 1 "${proposed_ip}" 1 25 25 30 \
#"Subnet Mask:" 2 1 "${proposed_subnet}" 2 25 25 30 \
#"Gateway:" 3 1 "${proposed_gateway}" 3 25 25 30 \
#"DNS1:" 5 1 "${dns_server1}" 5 25 25 30 \
#"DNS2:" 6 1 "${dns_server2}" 6 25 25 30 \
#"DNS3:" 7 1 "${dns_server3}" 7 25 25 30 \
#"Domain:" 9 1 "${domain}" 9 25 25 30 \
#2>/anydeploy/tmp/ip_settings_form.$$

if test $? -eq 0
then
   echo "ok pressed"
else
   echo "cancel pressed"
   cleanup
   exit 1;
fi


# Get values after form is processed

#ip_address=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 1)
#subnet_mask=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 2 | tail -n 1)
#dhcp_startip=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 3 | tail -n 1)
#dhcp_endip=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 4 | tail -n 1)
#gateway=$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 5 | tail -n 1)
#dns_server1="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 6 | tail -n 1)"
#dns_server2="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 7 | tail -n 1)"
#dns_server3="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 8 | tail -n 1)"
#domain="$(cat /anydeploy/tmp/ip_settings_form.$$ | head -n 9 | tail -n 1)"

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
# /etc/network/interfaces


      # TODO generate bridge name (if default vmbr0 is taken)

      # remove network-manager (if installed)

      # make copy (.anybackup)

      echo "making a backup of current interfaces file in /etc/network/interfaces.anybackup"
      sleep 2
      cp /etc/network/interfaces /etc/network/interfaces.anybackup

      # remove interface and bridges

      remove_interface ${selected_interface}
      sleep 2



      # add interface lines (don't overwrite)

      TAB=$'\t'
      echo "adding interfaces"
      sleep 2

      echo "" >> /etc/network/interfaces
      echo "iface ${selected_interface} inet manual" >> /etc/network/interfaces

      # add bridge (vmbr0) lines (don't overwrite)

      # TODO i1 add empty line only if one isn't there
      echo "" >> /etc/network/interfaces
      echo "auto anybr0" >> /etc/network/interfaces
      echo "iface anybr0 inet static" >> /etc/network/interfaces # TODO i5 replace vmbr1 with dynamic interface
      echo "${TAB}address ${ip_address}" >> /etc/network/interfaces
      echo "${TAB}netmask ${subnet_mask}" >> /etc/network/interfaces
      if [ ! -z "${gateway}" ]; then
      echo "${TAB}gateway ${gateway}" >> /etc/network/interfaces
      fi
      echo "${TAB}bridge_ports ${selected_interface}" >> /etc/network/interfaces
      echo "${TAB}bridge_stp off" >> /etc/network/interfaces
      echo "${TAB}bridge_fd 0" >> /etc/network/interfaces

      # TODO - remove uncecessary spaces
      sed -i '/^$/{N;/^\n$/d;}' /etc/network/interfaces

      # restart networking

      service networking restart

# /etc/resolv.conf

      # make copy (.anybackup)

      # overwrite with selected dns servers


# TODO Verify if interface is up and running otherwise print error and prompt what to do

# TODO Add interface and bridge name to global config file



cleanup

}

cleanup () {
  echo "cleaning up"
  rm /anydeploy/tmp/dhcp_discover.$$
#  rm /anydeploy/tmp/ip_settings_form.$$
}


verify_interface_selection
