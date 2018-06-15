#!/bin/bash

# Install deps

apt install qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin

# Add /etc/network/interfaces.d as ramdisk

mount -t tmpfs -o size=10m tmpfs /etc/network/interfaces.d

# /etc/network/interfaces.d/anybr0

auto lo
iface lo inet loopback

iface eno0 inet manual

auto anybr0
iface anybr0 inet static
	address 192.168.1.128        ## set up/netmask/broadcast/gateway as per your setup
	broadcast 192.168.1.255
	netmask 255.255.255.0
	gateway 192.168.1.254
	bridge_ports eth0    # replace eth0 with your actual interface name
	bridge_stp off       # disable Spanning Tree Protocol
        bridge_waitport 0    # no delay before a port becomes available
        bridge_fd 0          # no forwarding delay
