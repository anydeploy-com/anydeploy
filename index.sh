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

deploy () {
  echo "TO BE DONE"
}

capture () {
  echo "TO BE DONE"
}

tests () {
  echo "TO BE DONE"
}

specs () {
  echo "TO BE DONE"
}

print () {
  echo "TO BE DONE"
}



tasks () {
  echo "TO BE DONE"
}

options () {
  echo "TO BE DONE"
}

shell () {
  exit 1
}

poweroff () {
  # TODO - Uncomment
  echo "poweroff disabled (need to be uncommented in index.sh)"
  #poweroff
}

main_menu () {


IFS=$'\n'

        dialog --backtitle "anydeploy - Main Menu" --menu "Main Menu - select task:" 20 55 15 \
          ${template_list[@]} \
          deploy "Deploy OS" \
          capture "Capture OS" \
          tests "Run Tests" \
          specs "Display Specification" \
          print "Print Specification" \
          tasks "Other Tasks" \
          options "Open Settings" \
          shell "Open Linux Shell" \
          poweroff "Shutdown System" 2> tmp/template_list.$$


IFS=$SAVEIFS

menu_selection=`cat tmp/template_list.$$`

$menu_selection

}

#echo "Template filenames: ${template_filenames[0]}"
#echo "Template names: ${template_names[0]}"
#echo "Template List: ${template_list[1]}"

main_menu
