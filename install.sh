#!/bin/bash

# Include functions
. /anydeploy/settings/functions.sh

# Include global config
. /anydeploy/global.conf



          function check_log {
            # if log exists then rename to current date one
          echo "checking if log file exists"
            #bash script.sh > "/var/log/$(date +%Y-%m-%d_%H:%M).log"
          }





          function install_git {
          echo_warn "Installing git"
          apt install -y git

          sleep 5
          # Verify if git installed successfully or cancel
        }

          function clone_testing_repo {
          echo_warn "cloning testing repo"
          # Check if /anydeploy exists

          # Doesn't exist - clone
          git clone https://github.com/anydeploy-com/anydeploy /anydeploy

          # Exists - prompt to replace / update

          }

          # Verify Internet connection

          function check_network {

          echo_warn "Verifying if internet connection exists"

          if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
            echo_pass "Internet Is connected"
          else
            echo "Your internet connection is down - exiting"
            exit 1
          fi

          }

          function update_upgrade_os {

          # Prompt for update and upgrade
          read -p " * - Do you want to update your operating system first - recommended (Y/n)? " choice
          case "$choice" in
            y|Y )
            echo_warn "OS Update chosen - updating"
            echo_warn "Updating Packages (apt update)"
            apt-get update -y
            sleep 5
            os_upgrade
            sleep 5
            ;;
            n|N )
            echo_warn "Skipping upgrades - updating packages list only"
            echo_warn "Updating OS"
            apt-get upgrade -y
            sleep 5
            ;;
            * )
            echo "invalid";;
          esac
          }


          function git_postclone {


            # Add gitignore files

          touch /anydeploy/iso/.gitignore

          echo "*.iso" >> /anydeploy/iso/.gitignore

          touch /anydeploy/tmp/.gitignore

          echo "*" >> /anydeploy/tmp/.gitignore

          # Single file installer  will go here.

          # Setup Folders

          if [ ! -d "/anydeploy/tmp/mount" ]; then
          echo_warn "Directory tmp/mount DOES NOT exists, creating."
          mkdir /anydeploy/tmp/mount
          fi

          if [ ! -d "/anydeploy/tmp/extracted" ]; then
          echo_warn "Directory tmp/extracted DOES NOT exists, creating."
          mkdir /anydeploy/tmp/extracted
          fi
          }

          function debootstrap_debian9_x64 {
            . scripts/debootstrap_debian9_x64.sh
          }

          function debootstrap_debian9_x64_postinstall {
          . scripts/debootstrap_debian9_x64_postinstall.sh
          }

          function install_dhcp_package {
          apt install -y isc-dhcp-server
          }

          function install_dhcp_selectinterface {
            . scripts/dhcp_select_interface.sh
          }


# Prompt for OS update / upgrade

      update_upgrade_os & sleep 5

# Install Git

      install_git & sleep 5

# Verify Git

      check_deps git & sleep 5

# Clone repository

      clone_testing_repo & sleep 5

# Git Postclone function

      git_postclone

# Declare dependencies

      deps=( dialog debootstrap sudo dmidecode lsusb lspci cups net-tools dhcpcd5 qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin )

# Check dependencies

      check_deps

# Setup user, user variables

      # TODO - for system + live (chroot)


# Install DHCP Server
      # TODO ADD PROMPT to install or use dnsmasq

      install_dhcp_selectinterface


# Create Anylive 64 bit environment

      debootstrap_debian9_x64

# Configure Anylive 64 bit environment

      debootstrap_debian9_x64_postinstall

# Fix permissions

# Download virtio iso


# TODO check if virtio-win.iso exists

# https://fedoraproject.org/wiki/Windows_Virtio_Drivers#Direct_download

      #cd iso
      #wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso --show-progress
      #cd ..

# Download dependencies



# Compile iPXE

# Install CUPS Print Server

# Install TFTP Server

# Inatall IPXE

# Install DHCP / Explain how to setup dhcp + install netboot part

# Install LEMP Stack
