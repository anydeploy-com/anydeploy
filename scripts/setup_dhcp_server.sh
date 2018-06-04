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

install_isc_dhcp
configure_isc_dhcp
}


install_isc_dhcp () {


  dhcp_startip=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "DHCP Start IP:" 1 1 "${proposed_dhcp_start}" 1 25 25 15 2>&1 >/dev/tty)
  dhcp_endip=$(dialog --backtitle "DHCP Setup - Interface Selection" --form " x" 10 60 2 "DHCP End IP:" 1 1 "${proposed_dhcp_end}" 1 25 25 15 2>&1 >/dev/tty)


  # TODO - check if already installed and prompt what to do

  proposed_dhcp_start="${subnet_pre}.10"
  proposed_dhcp_end="${subnet_pre}.250"


echo "ip_address: ${ip_address}"
echo "subnet_mask: ${subnet_mask}"
echo "dhcp_startip: ${dhcp_startip}"
echo "dhcp_endip: ${dhcp_endip}"
echo "gateway: ${gateway}"
echo "dns_server1: ${dns_server1}"
echo "dns_server2: ${dns_server2}"
echo "dns_server3: ${dns_server3}"
echo "domain: ${domain}"

sleep 20

#        apt-get install isc-dhcp-server -y




configure_isc_dhcp
}


configure_isc_dhcp () {

echo "TBD"

  # /etc/default/isc-dhcp-server

        # make copy (.anybackup)

        cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.anybackup

        # replace interface (ipv4)

        sed -i -e "/INTERFACESv4=/ s/=.*/=vmbr1/" /etc/default/isc-dhcp-server # TODO - USE DYNAMIC BRIDGE


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

        service isc-dhcp-server restart

cleanup

}

cleanup () {
  echo "cleaning up"
}


dhcpsetup
