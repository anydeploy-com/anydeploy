#!/bin/bash

          # Include functions
          . /anydeploy/settings/functions.sh

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


# Display Main Menu


        export templates_list=$(ls -lh templates/ | grep -v "total" | awk '{print v++,$9}')
        dialog --menu "Please choose template to work with" 20 55 15 $templates_list \
        new "Create New Template" \
        newos "Add New OS (virtual machine)" \
        settings "Global Settings" \
        shell "Open Shell" \
        exit "Exit" 2> tmp/template_list.$$

choice=`cat tmp/template_list.$$`
