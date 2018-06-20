#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source global.conf                        # Include Global Configuration File
  source scripts/includes/functions.sh                      # Include Functions

##############################################################################
#                               Ask Questions                                #
##############################################################################

  clear # Clear First for readability
  echo "##############################################################################"
  echo "#                        Anydeploy Installer Alpha                           #"
  echo "##############################################################################"

  echo ""
  read -p " * - Do you want to update your operating system first - recommended (Y/n)? " update_upgrade
  read -p " * - Do you want to install dependencies automatically - recommended (Y/n)? " autoinstall_deps
  echo ""

##############################################################################
#                               Run Functions                                #
##############################################################################

echo "##############################################################################"
echo "#                        Starting Installer                                  #"
echo "##############################################################################"
echo ""
  # Check if internet connection exists

  check_network

  # Update / Upgrade Operating System

  update_upgrade_os

  # Install Dependencies

  deps=( dialog debootstrap sudo dmidecode usbutils pciutils cups net-tools dhcpcd5 qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils libguestfs-tools genisoimage virtinst libosinfo-bin git )

  check_deps
