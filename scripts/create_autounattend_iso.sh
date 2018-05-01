#!/bin/bash

##############################################################################
#                            User Variables                                  #
##############################################################################

dependencies=( genisoimage dialog )

# TODO - add all the formatting functions

# List dependencies

# TODO - actually ask to install + format nicer


##############################################################################
#                            Dependencies                                    #
##############################################################################

# TODO - add all the formatting functions

# List dependencies

# TODO - actually ask to install + format nicer

echo "Dependencies listed below:"
 for ((i=0; i < ${#dependencies[@]}; i++))
    do
		echo " - ${dependencies[i]}"
    done

##############################################################################
#                            Prepare                                         #
##############################################################################


# Get Script Dir (in case of path change later on)

script_path=`dirname $0`
script_dir="${PWD}/${script_path}"
main_dir=`cd $script_dir && cd .. && echo ${PWD}` # TODO - fix, seems ugly but works
iso_dir="${main_dir}/iso}"
temp_dir="${main_dir}/tmp"
# Create Mount Dir

cd ${main_dir}

if [ ! -d "tmp/mount" ]; then
echo "Directory tmp/mount DOES NOT exists, creating."
mkdir tmp/mount
fi

# Detect ISO's

iso_list=(`find ${iso_dir}/ -maxdepth 1 -name "*.iso"`)
iso_menu=`ls ${iso_dir}/*.iso | awk '{print v++,$1}'`

##############################################################################
#                            Debugging                                       #
##############################################################################

echo "temp_dir = \"${temp_dir}\""
echo "iso_dir = \"${iso_dir}\""



##############################################################################
#                            Dialog - ISO Selection                          #
##############################################################################



#dialog --clear --title "Select ISO" \
#       --menu "Move using [UP] [DOWN} Arrow keys, Hit [ENTER] key to select." 20 70 5 $iso_menu 2> ${temp_dir}/chosen_iso.$$

#menu_choice=`cat ${temp_dir}/chosen_iso.$$`
