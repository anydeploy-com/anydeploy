#!/bin/bash


# Add gitignore files

touch iso/.gitignore

echo "*.iso" >> iso/.gitignore

touch tmp/.gitignore

echo "*" >> tmp/.gitignore

# Single file installer  will go here.

# Setup Folders

# Setup user, user variables

# Fix permissions

# Download virtio iso


# TODO check if virtio-win.iso exists

# https://fedoraproject.org/wiki/Windows_Virtio_Drivers#Direct_download

cd iso
wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso --show-progress
cd ..
# Download dependencies



# Compile iPXE

# Install TFTP Server

# Inatall IPXE

# Install DHCP / Explain how to setup dhcp + install netboot part

# Install LEMP Stack
