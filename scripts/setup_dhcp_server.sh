#!/bin/bash

. /anydeploy/includes/functions.sh


dhcpsetup () {
  dialog --backtitle "anydeploy - DHCP SETUP" --menu "DHCP SETUP - select task:" 20 55 15 \
    RUNSERVER "Setup DHCP Server (ISC DHCP SERVER)" \
    DNSMASQ "Use DHCP Proxy (dnsmasq)" \
    USEOWN "Use my current dhcp server" \
    OPTIONS "Go Back to Options Menu" 2> tmp/options_list.$$

    options_list=`cat tmp/options_list.$$`

    $options_list

}


RUNSERVER () {

setup_dhcp_start_end
}


setup_dhcp_start_end () {

#  echo "ip_address: ${ip_address}"
#  echo "subnet_mask: ${subnet_mask}"
#  echo "dhcp_startip: ${dhcp_startip}"
#  echo "dhcp_endip: ${dhcp_endip}"
#  echo "gateway: ${gateway}"
#  echo "dns_server1: ${dns_server1}"
#  echo "dns_server2: ${dns_server2}"
#  echo "dns_server3: ${dns_server3}"
#  echo "domain: ${domain}"
#
#  sleep 10


  dhcp_startip=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "DHCP Start IP:" 1 1 "${proposed_dhcp_start}" 1 25 25 15 2>&1 >/dev/tty)
  dhcp_endip=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "DHCP End IP:" 1 1 "${proposed_dhcp_end}" 1 25 25 15 2>&1 >/dev/tty)


install_isc_dhcp

}



install_isc_dhcp () {

# Start Installation

# TODO - check if installed already and prompt to reinstall if installed

apt-get install isc-dhcp-server -y


configure_isc_dhcp
}


configure_isc_dhcp () {

echo "TBD"

  # /etc/default/isc-dhcp-server

        # make copy (.anybackup)

        cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.anybackup

        # replace interface (ipv4)

        sed -i -e "/INTERFACESv4=/ s/=.*/=anybr0/" /etc/default/isc-dhcp-server # TODO - USE DYNAMIC BRIDGE


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
option domain-name "anydeploy";
# Use Google public DNS server (or use faster values that your internet provider gave you!):
option domain-name-servers 8.8.8.8, 8.8.4.4;
# Set up our desired subnet:
subnet 192.168.1.0 netmask 255.255.255.0 {
    range 192.168.1.101 192.168.1.254;
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.168.1.255;
    option routers 192.168.1.254;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}
default-lease-time 600;
max-lease-time 7200;
# Show that we want to be the only DHCP server in this network:
authoritative;
EOF

        # restart isc dhcp

        service isc-dhcp-server restart

        # Enable server

        systemctl enable isc-dhcp-server

restart_networking

}


restart_networking () {
  service networking restart
  cleanup
}

cleanup () {
  echo "cleaning up"
}


dhcpsetup
