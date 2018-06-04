#!/bin/bash

. /anydeploy/includes/functions.sh


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
  rm /anydeploy/tmp/dhcp_discover.$$
  rm /anydeploy/tmp/ip_settings_form.$$
}


select_interface
