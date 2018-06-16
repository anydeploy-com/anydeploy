#!/bin/bash

. /anydeploy/includes/functions.sh
. /anydeploy/settings/global.sh

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

sudo cp -r /usr/lib/syslinux/modules/bios /anydeploy/tftp/boot/isolinux
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
option space PXE;
option PXE.mtftp-ip    code 1 = ip-address;
option PXE.mtftp-cport code 2 = unsigned integer 16;
option PXE.mtftp-sport code 3 = unsigned integer 16;
option PXE.mtftp-tmout code 4 = unsigned integer 8;
option PXE.mtftp-delay code 5 = unsigned integer 8;
option arch code 93 = unsigned integer 16; # RFC4578

use-host-decl-names on;
ddns-update-style interim;
ignore client-updates;
next-server 192.168.1.254;
authoritative;

subnet 192.168.1.0 netmask 255.255.255.0 {
    option subnet-mask 255.255.255.0;
    range dynamic-bootp 192.168.1.10 192.168.1.254;
    default-lease-time 21600;
    max-lease-time 43200;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
    option routers 192.168.1.254;

    class "UEFI-32-1" {
    match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00006";
    filename "efi32/syslinux32.efi";
    }

    class "UEFI-32-2" {
    match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00002";
     filename "efi32/syslinux32.efi";
    }

    class "UEFI-64-1" {
    match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00007";
     filename "ipxe.efi";
    }

    class "UEFI-64-2" {
    match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00008";
    filename "ipxe.efi";
    }

    class "UEFI-64-3" {
    match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00009";
     filename "ipxe.efi";
    }

    class "Legacy" {
    match if substring(option vendor-class-identifier, 0, 20) = "PXEClient:Arch:00000";
    filename "undionly.kpxe";
    }


# naming

# "anyapple" translates to : 61:6e:79:61:70:70:6c:65


    class "Apple-Intel-Netboot" {
    match if substring (option vendor-class-identifier, 0, 14) = "AAPLBSDPC/i386";
    option dhcp-parameter-request-list 1,3,17,43,60;
    if (option dhcp-message-type = 8) {
        option vendor-class-identifier "AAPLBSDPC";
        if (substring(option vendor-encapsulated-options, 0, 3) = 01:01:01) {
            # BSDP List
            option vendor-encapsulated-options 01:01:01:04:02:80:00:07:04:81:00:05:2a:09:0D:81:00:05:2a:08:61:6e:79:61:70:70:6c:65;
        }
        elsif (substring(option vendor-encapsulated-options, 0, 3) = 01:01:02) {
            # BSDP Select
            option vendor-encapsulated-options 01:01:02:08:04:81:00:05:2a:82:0a:4e:65:74:42:6f:6f:74:30:30:31;
            filename "ipxemac.efi";
            next-server 192.168.1.254;
        }
    }
}

}
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
