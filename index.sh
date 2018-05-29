#!/bin/bash

          # Include functions
          . /anydeploy/scripts/includes/functions.sh

          # Include global config
          . /anydeploy/settings/global.sh

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
          trap "echo Removed temp" 0 1 2 5 15


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




# Display Main Menu

main_menu () {

IFS=$'\n'

      dialog --menu "Please choose template to work with:" 20 55 15 \
        ${template_list[@]} \
        new "Create New Template" \
        newos "Add New OS (virtual machine)" \
        settings "Global Settings" \
        shell "Open Shell" \
        restart "Restart" \
        exit "Shutdown" 2> tmp/template_list.$$

IFS=$SAVEIFS

menu_selection=`cat tmp/template_list.$$`

echo "selected menu:" $menu_selection # Echo for debugging

}

#echo "Template filenames: ${template_filenames[0]}"
#echo "Template names: ${template_names[0]}"
#echo "Template List: ${template_list[1]}"

main_menu
