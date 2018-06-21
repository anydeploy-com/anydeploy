#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions

##############################################################################
#                          Create TFTP Directory                             #
##############################################################################

start_spinner "Preparing TFTP Server"
if [ ! -d "${install_path}/tftp" ]; then
mkdir "${install_path}/tftp"
fi

if [ ! -d "${install_path}/tftp/.gitignore" ]; then
touch /anydeploy/tftp/.gitignore
echo "*" > /anydeploy/tftp/.gitignore
fi
sleep 1
stop_spinner $?
##############################################################################
#                          Replace Default Config                            #
##############################################################################

start_spinner "Generating TFTP Server Config"
rm /etc/default/tftpd-hpa
touch /etc/default/tftpd-hpa
cat >"/etc/default/tftpd-hpa" << EOF
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="${install_path}/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="-s"
EOF
sleep 1
stop_spinner $?
##############################################################################
#                          Restart Service                                   #
##############################################################################
start_spinner "Restarting TFTP Server"
service tftpd-hpa restart
sleep 1
stop_spinner $?
