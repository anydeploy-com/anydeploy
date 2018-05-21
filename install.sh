#!/bin/bash

            # Include functions
            . /anydeploy/settings/functions.sh

            # Include global config
            . /anydeploy/settings/global.sh

            # Clear for readability
            clear

            # Check if run as root

            check_root

            # Declare dependencies

            deps=( debootstrap sudo dmidecode lspci cups )

            # Check dependencies

            check_deps

            # Load Config File (Dialog)


# Add gitignore files

          touch iso/.gitignore

          echo "*.iso" >> iso/.gitignore

          touch tmp/.gitignore

          echo "*" >> tmp/.gitignore

# Single file installer  will go here.

# Setup Folders

          if [ ! -d "tmp/mount" ]; then
          echo_warn "Directory tmp/mount DOES NOT exists, creating."
          mkdir tmp/mount
          fi

          if [ ! -d "tmp/extracted" ]; then
          echo_warn "Directory tmp/extracted DOES NOT exists, creating."
          mkdir tmp/extracted
          fi



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
