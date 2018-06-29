#!/bin/bash


          # Go to script path
          MY_PATH="`dirname \"$0\"`"
          cd "${MY_PATH}"

          # Include functions
          . /anydeploy/scripts/includes/functions.sh

          # Include global config
          . /anydeploy/global.conf

          # Clear for readability
          clear

          # Check if run as root

          check_root

          # Define the dialog exit status codes
          : ${DIALOG_OK=0}
          : ${DIALOG_CANCEL=1}
          : ${DIALOG_HELP=2}
          : ${DIALOG_EXTRA=3}
          : ${DIALOG_ITEM_HELP=4}
          : ${DIALOG_ESC=255}

          # Define temp file and trap to remove it later
          tmp_file=$(tempfile 2>/dev/null) || tmp_file=tmp/template_list.$$
          trap "rm -f $tmp_file" 0 1 2 5 15


SAVEIFS=$IFS



# Template Filenames Array
        template_filenames=($(ls -lh templates/ | grep -v "total" | awk '{print $9}'))

IFS=$'\n'

# Template Names Array
        for i in "${template_filenames[@]}"
        do
          template_names+=($(cat templates/${i} | grep "templatename" | cut -d "=" -f 2 | sed 's/\"//g'))
        done



# Combine Arrays for dialog display
        for i in "${!template_filenames[@]}"; do
          template_list+=("${template_filenames[${i}]}" "${template_names[${i}]}")
        done

IFS=$SAVEIFS

#        selected_template=$(dialog --backtitle "anydeploy Installer - Step X of Y" \
#                            --menu "please pick interfaces for dhcp server to listen on" 30 100 10 ${template_list[@]} 2>&1 >/dev/tty)



# If templates in menu disabled in global config then clear array

if [ "${display_templates_in_mainmenu}" = "no" ] ; then
export template_list=()
fi

# Display Main Menu

DEPLOY () {
  echo "TO BE DONE"
}

CAPTURE () {
  . /anydeploy/scripts/capture.sh
  MAIN_MENU
}

CREATEVM () {
  . /anydeploy/scripts/capture/create_vm_new.sh
  MAIN_MENU
}


TESTS () {
  echo "TO BE DONE"
}

SPECS () {
  echo "TO BE DONE"
}

PRINT () {
  echo "TO BE DONE"
}

TASKS () {
  echo "TO BE DONE"
}

OPTIONS () {
  dialog --backtitle "anydeploy ${devtype} - ip: ${ip_address_dialog} - Settings Menu" --menu "Settings Menu - select task:" 20 55 15 \
    INTERFACE "Select Interface" \
    IPADDRESS "Setup Networking" \
    DHCPSERVER "DHCP Server Setup" \
    GLOBAL "Global Settings" \
    MAIN_MENU "Go Back to Main Menu" 2> tmp/options_list.$$

    options_list=`cat tmp/options_list.$$`
    rm /anydeploy/tmp/options_list.$$

    $options_list

}

INTERFACE () {
  . /anydeploy/scripts/setup_interface.sh
  OPTIONS
}

IPADDRESS () {
  . /anydeploy/scripts/setup_ipaddress.sh
  OPTIONS
}

07771808581 - Steve
DHCPSERVER () {
  . /anydeploy/scripts/setup_dhcp_server.sh
  OPTIONS
}


SHELL () {
  cleanup
  exit 1
}

POWEROFF () {
  # TODO - Uncomment
  echo "poweroff disabled (need to be uncommented in index.sh)"
  #poweroff
}

MAIN_MENU () {


IFS=$'\n'
if [ "${devtype}" = "server" ]; then
        dialog --backtitle "anydeploy ${devtype} - ip: ${ip_address_dialog} - Main Menu" --menu "Main Menu - select task:" 20 55 15 \
          DEPLOY "Deploy OS" \
          CAPTURE "Capture OS" \
          CREATEVM "Create VM" \
          TESTS "Run Tests" \
          SPECS "Display Specification" \
          PRINT "Print Specification" \
          TASKS "Other Tasks" \
          OPTIONS "Open Settings" \
          SHELL "Open Linux Shell" \
          POWEROFF "Shutdown System" 2> tmp/template_list.$$
elif [ "${devtype}" = "client" ]; then
        dialog --backtitle "anydeploy ${devtype} - ip: ${ip_address_dialog} - Main Menu" --menu "Main Menu - select task:" 20 55 15 \
          DEPLOY "Deploy OS" \
          CAPTURE "Capture OS" \
          TESTS "Run Tests" \
          SPECS "Display Specification" \
          PRINT "Print Specification" \
          TASKS "Other Tasks" \
          OPTIONS "Open Settings" \
          SHELL "Open Linux Shell" \
          POWEROFF "Shutdown System" 2> tmp/template_list.$$
fi

IFS=$SAVEIFS

menu_selection=`cat tmp/template_list.$$`

$menu_selection

}

cleanup () {
  echo "cleaning up"
  rm /anydeploy/tmp/template_list.$$
}


#echo "Template filenames: ${template_filenames[0]}"
#echo "Template names: ${template_names[0]}"
#echo "Template List: ${template_list[1]}"


MAIN_MENU
cleanup
