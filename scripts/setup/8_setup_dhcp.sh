#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions


##############################################################################
#                  Dialog box to select what to use for dhcp                 #
##############################################################################

  echo "running dialog"
  #which_dhcp=($(dialog --title 'Example' --default-item '2' --menu 'Select:' 0 0 0 1 'ABC' 2 'DEF' 3 'GHI'))

dhcp_type=$(dialog --backtitle "DHCP Setup - Type" \
                   --cancel-label "Help" \
                   --menu "Please Select what option for DHCP server is suitable for you." 30 100 10 \
                   "dnsmasq" "Use dnsmasq as dhcp proxy (easy - no additional config required)" \
                   "isc-dhcp" "Install DHCP server - you must disable your current dhcp server first" \
                   "none"  "Use your own DHCP Server (Experts only)" 2>&1 >/dev/tty)


# TODO - ADD HELP


      if test $? -eq 0
      then
         echo "ok pressed"
      else
dialog --backtitle "DHCP Setup - Help" --msgbox \
" dnsmasq - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean lacinia urna sed lobortis cursus. Curabitur mauris augue, faucibus quis fringilla vitae, tempus sed lorem. Vivamus a bibendum ex. Ut ante ligula, posuere vel enim nec, hendrerit efficitur purus. Sed pulvinar quis arcu ut tristique. \n\n \
isc-dhcp - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean lacinia urna sed lobortis cursus. Curabitur mauris augue, faucibus quis fringilla vitae, tempus sed lorem. Vivamus a bibendum ex. Ut ante ligula, posuere vel enim nec, hendrerit efficitur purus. Sed pulvinar quis arcu ut tristique. \n\n \
none - Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean lacinia urna sed lobortis cursus. Curabitur mauris augue, faucibus quis fringilla vitae, tempus sed lorem. Vivamus a bibendum ex. Ut ante ligula, posuere vel enim nec, hendrerit efficitur purus. Sed pulvinar quis arcu ut tristique." \
          30 100
         . ${install_path}/scripts/setup/8_setup_dhcp.sh
      fi

echo ${dhcp_type}
