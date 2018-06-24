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
        # Selected OK
        if [ "$dhcp_type" = "dnsmasq" ]; then
            echo "running dnsmasq script"
            apt-get install -y dnsmasq

            touch /etc/dnsmasq.d/ltsp.conf


cat >"/etc/dnsmasq.d/ltsp.conf" << EOF
# Don't function as a DNS server:
port=0

# Log lots of extra information about DHCP transactions.
log-dhcp

# Set the root directory for files available via FTP.
tftp-root=/tftp

# The boot filename, Server name, Server Ip Address
dhcp-boot=undionly.kpxe,,${ip_address}

# Disable re-use of the DHCP servername and filename fields as extra
# option space. That's to avoid confusing some old or broken DHCP clients.
dhcp-no-override

# PXE menu.  The first part is the text displayed to the user.  The second is the timeout, in seconds.
pxe-prompt="Booting anyDeploy", 1

# The known types are x86PC, PC98, IA64_EFI, Alpha, Arc_x86,
# Intel_Lean_Client, IA32_EFI, BC_EFI, Xscale_EFI and X86-64_EFI
# This option is first and will be the default if there is no input from the user.

pxe-service=X86PC, "Boot BIOS", undionly
pxe-service=X86-64_EFI, "Boot UEFI", ipxe
pxe-service=BC_EFI, "BOOT UEFI PXE-BC", ipxe

dhcp-range=${ip_address},proxy
EOF


# TODO ECHO DNS TO RESOLVCONF
# TODO ENABLE RESOLVCONF SERVICE


service dnsmasq restart



        elif [ "$dhcp_type" = "isc-dhcp" ]; then
            echo "running isc-dhcp script"
        elif [ "$dhcp_type" = "none" ]; then
              echo "selected none - exiting"
        else
            echo "nothing"
        fi
      else
        # Selected Help (cancel)
      dhcp_type=()
      . ${install_path}/scripts/setup/8_setup_dhcp_help.sh
      fi
