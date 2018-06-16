#!/bin/bash

# Install deps

apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin

# Add /etc/network/interfaces.d as ramdisk

mount -t tmpfs -o size=10m tmpfs /etc/network/interfaces.d




# /etc/network/interfaces.d/vmbr0

# SETUP ROUTED BRIDGE

auto vmbr0
#private sub network
iface vmbr0 inet static
        address  10.10.10.1
        netmask  255.255.255.0
        bridge_ports none
        bridge_stp off
        bridge_fd 0

        post-up echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up   iptables -t nat -A POSTROUTING -s '10.10.10.0/24' -o eno1 -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '10.10.10.0/24' -o eno1 -j MASQUERADE


# ENABLE POSTROUTING
