#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source global.conf                          # Include Global Conf
  source scripts/includes/functions.sh        # Include Functions

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

  ##############################################################################
  #                               Install Dependencies                         #
  ##############################################################################

  deps=( \
    # Dialog - Foundation of server management
    dialog \
    # Debootstrap - Used to create net version of anydeploy (netboot)
    debootstrap \
    # Sudo - might be used in some scripts
    sudo \
    # Dmidecode - Used in Specs Scripts
    dmidecode \
    # USBUtils - Used in Specs Scripts
    usbutils \
    # PCIUtils - Used in Specs Scripts
    pciutils \
    # CUPS - Used in Specs Scripts (Print)
    cups \
    # Net-Utils - Networking
    net-tools \
    # DHCPD - Networking
    dhcpcd5 \
    # Qemu - Virtualisation
    qemu-kvm \
    # Virtualisation Dependency
    libvirt-clients \
    # Virtualisation Dependency
    libvirt-daemon-system \
    # Virtualisation Dependency
    bridge-utils \
    # Virtualisation Dependency
    libguestfs-tools \
    # Virtualisation Dependency
    virtinst \
    # Virtualisation Dependency
    libosinfo-bin \
    # GenISO - used to generate iso for autounattend + combined iso's + anydeploy CD
    genisoimage \
    # Used for updates / cloning etc.
    git \
    )

  check_deps

  ##############################################################################
  #                               Check Conflicts                              #
  ##############################################################################


  # TODO Remove netplan, network-manager (check if installed - dpkg -l and remove using apt purge)


  echo "##############################################################################"
  echo "#                        Starting Dialog Setup                               #"
  echo "##############################################################################"
  echo ""

  # Select Interface for networking
  . ${install_path}/scripts/setup/select_interface.sh
  . ${install_path}/scripts/setup/detect_dhcp.sh




  # TODO - add updatepciids script
