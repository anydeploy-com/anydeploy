#!/bin/bash

function check_root {

# Detect if run as root and do so if not

if [[ $EUID -ne 0 ]]; then
   echo_fail "This script must be run as root"
   exit 1
else
  echo_pass "Running as root / sudo"
fi
}



# Prompt for update and upgrade

read -p "Do you want to update your operating system first - recommended (y/n)? " choice
case "$choice" in
  y|Y ) echo "OS Update chosen - updating";;
  n|N ) echo "Skipping upgrades - updating packages list only";;
  * ) echo "invalid";;
esac


# Install Git



# Clone repository



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

# Install CUPS Print Server

# Install TFTP Server

# Inatall IPXE

# Install DHCP / Explain how to setup dhcp + install netboot part

# Install LEMP Stack
