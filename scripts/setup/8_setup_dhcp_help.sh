#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions


##############################################################################
#                  Dialog box to select what to use for dhcp                 #
##############################################################################

dialog --backtitle "DHCP Setup - Help" --msgbox \
" dnsmasq - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean lacinia urna sed lobortis cursus. Curabitur mauris augue, faucibus quis fringilla vitae, tempus sed lorem. Vivamus a bibendum ex. Ut ante ligula, posuere vel enim nec, hendrerit efficitur purus. Sed pulvinar quis arcu ut tristique. \n\n \
isc-dhcp - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean lacinia urna sed lobortis cursus. Curabitur mauris augue, faucibus quis fringilla vitae, tempus sed lorem. Vivamus a bibendum ex. Ut ante ligula, posuere vel enim nec, hendrerit efficitur purus. Sed pulvinar quis arcu ut tristique. \n\n \
none - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean lacinia urna sed lobortis cursus. Curabitur mauris augue, faucibus quis fringilla vitae, tempus sed lorem. Vivamus a bibendum ex. Ut ante ligula, posuere vel enim nec, hendrerit efficitur purus. Sed pulvinar quis arcu ut tristique." \
          30 100
         . ${install_path}/scripts/setup/8_setup_dhcp.sh
