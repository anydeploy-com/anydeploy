#!/bin/bash

# TODO - verify if run as root (attach script)

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
  read -p " * - Do you want to restore default config ? (y/n)? " restore_config
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
    # Used to create USB Sticks / DVD
    syslinux \
    # Used to create USB Sticks / DVD / Legacy PXE boot (non iPXE EFI)
    syslinux-efi \
    #  Legacy PXE boot (non iPXE)
    pxelinux \
    # Hosting PXE boot files (iPXE)
    tftpd-hpa
    # Building Sources (ie. iPXE)
    build-essential \
    # Building Sources (ie. iPXE)
    mtools \
    # Perl
    perl \
    # Building Sources (ie. iPXE)
    binutils \
    # Building Sources (ie. iPXE)
    liblzma-dev \
    # Iptables Persistent for Postrouting
    iptables-persistent \
    # Webserver (nginx)
    nginx \
    # PHP parser for Webserver (nginx)
    php-fpm \
    # DNS Management
    resolvconf \
    # NFS Server
    nfs-kernel-server \
    # Used to download SDIO torrent
    aria2 \
    # Synchronise / copy certain dirs (ie drivers)
    rsync
    )

  check_deps

  ##############################################################################
  #                               Check Conflicts                              #
  ##############################################################################

  # TODO - find if they exists first (dpkg -l) and then run remove

  start_spinner "Removing conflicting packages"
  apt-get remove netplan network-manager -y > /dev/null
  stop_spinner $?



  # Clear global.conf to default
  if [ ${restore_config} = "Y" ] || [ ${restore_config} = "y" ]; then
  start_spinner "Restoring default global.conf config file"
  cp ${install_path}/assets/defaults/global.conf ${install_path}/global.conf
  rm -rf /nfs/
  rm -rf ${install_path}/sources/ipxe
  sleep 5
  stop_spinner $?
  fi
  if [ ! -d "/nfs" ]; then
    mkdir /nfs
  fi

  echo "##############################################################################"
  echo "#                        Starting Dialog Setup                               #"
  echo "##############################################################################"
  echo ""



  # Select Interface for networking
  cd ${install_path}/scripts/setup/
  . ${install_path}/scripts/setup/1_select_interface.sh
  . ${install_path}/scripts/setup/2_setup_interface.sh
  clear
  . ${install_path}/scripts/setup/3_setup_tftp.sh
  . ${install_path}/scripts/setup/4_setup_ipxe.sh
  . ${install_path}/scripts/setup/5_debootstrap.sh
  . ${install_path}/scripts/setup/6_setup_nfs.sh
  . ${install_path}/scripts/setup/7_setup_nginx_php.sh
  . ${install_path}/scripts/setup/8_setup_dhcp.sh




  # TODO - add updatepciids script
