#!/bin/bash

##############################################################################
#                            User Variables                                  #
##############################################################################

dependencies=( genisoimage dialog )

# TODO - add must run as root / sudo suggestion

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
iso_dir="${main_dir}/iso"
temp_dir="${main_dir}/tmp"

# Create Mount Dir

cd ${main_dir}

if [ ! -d "tmp/mount" ]; then
echo "Directory tmp/mount DOES NOT exists, creating."
mkdir tmp/mount
fi
Actual ISO Creation
# Detect ISO's

iso_list=(`find ${iso_dir}/ -maxdepth 1 -name "*.iso"`)
iso_menu=`ls ${iso_dir}/*.iso | grep -v "autounattend" | awk '{print v++,$1}'`

if [ ! ${#iso_list[@]} -gt 0 ]; then
	echo ""
    echo "You must have at least 1 iso in $working_dir/iso"
    echo "Exiting..."
    exit 1
fi

##############################################################################
#                            Debugging                                       #
##############################################################################

echo "temp_dir = \"${temp_dir}\""
echo "iso_dir = \"${iso_dir}\""



##############################################################################
#                            Dialog - ISO Selection                          #
##############################################################################



dialog --clear --title "Select ISO" \
      --menu "Move using [UP] [DOWN} Arrow keys, Hit [ENTER] key to select." 20 70 5 $iso_menu 2> ${temp_dir}/chosen_iso.$$

menu_choice=`cat ${temp_dir}/chosen_iso.$$`

# Save Selection info to temp

chosen_iso=`echo "$iso_menu" | grep "${menu_choice} ." | awk '{print $2}'`

isoinfo -d -i $chosen_iso >> ${temp_dir}/isoinfo.$$

# cat ${temp_dir}/isoinfo.$$ # DEBUG - display iso info


##############################################################################
#                       Mount selected ISO                                   #
##############################################################################

#umount anything from mount location

if mount | grep "/anydeploy/tmp/mount";
then
echo "iso mounted already, unmounting"
sudo umount /anydeploy/tmp/mount
fi

# mount selected iso

sudo mount ${chosen_iso} /anydeploy/tmp/mount

##############################################################################
#                       User Input - ISO type                                #
##############################################################################

wiminfo /anydeploy/tmp/mount/sources/install.wim | grep "Name" | awk '{$1=$2=""; print $3}' >> ${temp_dir}/os_version_list.$$



# TODO TODO TODO  add part with os version selection + generate all the variables
# TODO OUTPUT AS ARRAY OF VERSIONS SO CAN DO MULTIPLE IN ORDER
# TODO ASK TO MAKE BIOS / UEFI IMAGES + OUTPUT AS ARRAY AND RUN FOREACH IN ORDER FOR DEPLOYMENT PART


# types of iso's

# seperate iso file - used for fast reference os creation

# TODO check if current one exists
# ask to overwrite

# combined iso - can be used to install seperate systems with single dvd / usb / virtual image ( takes longer)
# TODO check if current one exists
# ask to overwrite

# TODO get all the values for profiling (profile save for later usage)

##############################################################################
#                      Generate unattend file                            #
##############################################################################

sudo rm /anydeploy/tmp/extracted/*

# for home needs manual input for COA

# TODO - get / generate unattend file for detected windows version and copy to

# Read Template and replace given variables.

# use Sigil for templating

export key="7J2V8-R94WD-VV6RK-GG96B-RX9VX"

#cp /anydeploy/systems/Windows/unattend_files/autounattend_win10_mbr_audit.xml /anydeploy/tmp/extracted/autounattend.xml
sh /anydeploy/scripts/render_template.sh /anydeploy/systems/Windows/unattend_files/autounattend_win10_mbr_audit_template.xml >> /anydeploy/tmp/extracted/autounattend.xml


## Convert to DOS compatible
#    echo " * Converting Sysprep to Windows compatible (DOS)"
#    cat /anydeploy/tmp/extracted/autounattend_unix.xml | awk 'sub("$", "\r")' /anydeploy/tmp/extracted/autounattend_unix.xml > /anydeploy/tmp/extracted/autounattend.xml
#    sleep 1



##############################################################################
#                            autunattend.iso creation                        #
##############################################################################

rm /anydeploy/iso/autounattend.iso
mkisofs -o /anydeploy/iso/autounattend.iso -joliet-long -relaxed-filenames /anydeploy/tmp/extracted/.

##############################################################################
#                            Cleanup                                         #
##############################################################################

rm /anydeploy/tmp/chosen_iso.*
rm /anydeploy/tmp/isoinfo.*
rm /anydeploy/tmp/os_version_list.*


# TODO - clear generated files + temp folders (only generated by this script)
