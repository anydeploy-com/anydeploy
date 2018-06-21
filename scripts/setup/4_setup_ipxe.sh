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


      touch demo.ipxe

cat >"anydeploy.ipxe" << EOF
#!ipxe
dhcp
chain http://192.168.1.254/menu.ipxe
EOF
      sleep 1
stop_spinner $?

##############################################################################
#                          Build iPXE                                        #
##############################################################################

start_spinner "Building iPXE (UEFI)"
      make bin/undionly.kpxe EMBED=anydeploy.ipxe >/dev/null 2>&1
stop_spinner $?

start_spinner "Building iPXE (BIOS)"
      make bin-x86_64-efi/ipxe.efi EMBED=anydeploy.ipxe >/dev/null 2>&1
stop_spinner $?

# Go back to previous directory after building
cd ${install_path}/scripts/setup


# TODO  verify if done succesfully



# copy undionly file
start_spinner "Copying iPXE binaries to TFTP location"
      cp ${install_path}/sources/ipxe/src/bin/undionly.kpxe ${install_path}/tftp/
      cp ${install_path}/sources/ipxe/src/bin-x86_64-efi/ipxe.efi ${install_path}/tftp/
      sleep 1
stop_spinner $?
