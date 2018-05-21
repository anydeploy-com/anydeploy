#!/bin/bash

# Include functions
. /anydeploy/settings/functions.sh

# Include global config
. /anydeploy/settings/global.sh

            # Clear for readability
            clear

            # Display information about scripts

            echo ""
            echo " I provide no responsibility for this script ..."
            echo ""

# Check if run as root

check_root

# Declare dependencies

deps=( debootstrap sudo dmidecode lspci cups )

# Check dependencies

check_deps

# Load Config File (Dialog)


#create dialog_folder_function (as array)

export templates_list=$(ls -lh templates/ | grep -v "total" | awk '{print v++,$9}')

echo ${templates_list[@]}

sleep 1

dialog --menu "Please choose template to work with" 15 55 5 $templates_list \
new "Create New Template" \
menu "Go back to main menu" 2> tmp/template_list.$$

choice=`cat tmp/template_list.$$`



## TODO ADD DATE TO LOG FILENAME




# Verify if directories exists

if [ ! -d "tmp/mount" ]; then
echo_warn "Directory tmp/mount DOES NOT exists, creating."
mkdir tmp/mount
fi

if [ ! -d "tmp/extracted" ]; then
echo_warn "Directory tmp/extracted DOES NOT exists, creating."
mkdir tmp/extracted
fi
