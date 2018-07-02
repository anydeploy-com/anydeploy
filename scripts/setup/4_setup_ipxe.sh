#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions

##############################################################################
#                          Create Sources Dir                                #
##############################################################################

start_spinner "Preparing iPXE"

      if [ ! -d "${install_path}/sources" ]; then
      mkdir "${install_path}/sources"
      fi

      if [ ! -d "${install_path}/sources/.gitignore" ]; then
      touch ${install_path}/sources/.gitignore
      echo "*" > "${install_path}/sources/.gitignore"
      fi
      sleep 1
stop_spinner $?

# Clone ipxe
start_spinner "Downloading (git) iPXE"

      git clone --quiet git://git.ipxe.org/ipxe.git ${install_path}/sources/ipxe

stop_spinner $?


start_spinner "Creating iPXE script"
      # go into ipxe folder

# Save directory to go back later
SAVE_DIR=$(pwd)

      cd ${install_path}/sources/ipxe/src
      touch ${install_path}/sources/ipxe/src/anydeploy.ipxe

cat >"anydeploy.ipxe" << EOF
#!ipxe
dhcp
chain http://${ip_address}/menu.ipxe
EOF
      sleep 1
stop_spinner $?

##############################################################################
#                          Enable NFS Support                                #
##############################################################################

 echo "#define DOWNLOAD_PROTO_NFS" > config/local/general.h

##############################################################################
#                          Build iPXE                                        #
##############################################################################


# TODO BUild efi32/syslinux32.efi
# TODO Build ipxe 32 bit

start_spinner "Building iPXE 64 bit (BIOS)"
      make bin/undionly.kpxe EMBED=anydeploy.ipxe >/dev/null 2>&1
stop_spinner $?

start_spinner "Building iPXE 64 bit (UEFI)"
      make bin-x86_64-efi/ipxe.efi EMBED=anydeploy.ipxe >/dev/null 2>&1
stop_spinner $?

# Go back to previous directory after building
cd ${install_path}/scripts/setup


# TODO  verify if done succesfully



# copy undionly file
start_spinner "Copying iPXE binaries to TFTP location"
      cp ${install_path}/sources/ipxe/src/bin/undionly.kpxe /tftp/
      cp ${install_path}/sources/ipxe/src/bin-x86_64-efi/ipxe.efi /tftp/
      # must be linked within local directory since tftp deamon runs in chrooted dir
      cd /tftp
      if [ -f "undionly.0" ]; then
        rm "undionly.0"
      fi
      if [ -f "ipxe.0" ]; then
        rm "ipxe.0"
      fi
      ln -s undionly.kpxe undionly.0
      ln -s ipxe.efi ipxe.0
      # Go back to previous directory
      cd ${install_path}/scripts/setup
      chmod -R 777 /tftp/*
      sleep 1
stop_spinner $?
