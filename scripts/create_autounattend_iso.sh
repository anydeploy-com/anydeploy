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

#how many indexes (for array usage)
amount_of_indexes=`wiminfo install.wim | grep "Index" | grep -Eo '[0-9]+' | sort -rn | head -n 1`

wiminfo /anydeploy/tmp/mount/sources/install.wim | grep "Display Name:" | awk '{$1=$2=""; print $0}' | sed "s/^[ \t]*//" >> ${temp_dir}/os_version_list.$$

# Convert OS Versions to array

IFS=$'\n' os_edition_num=($(cat /anydeploy/tmp/os_version_list.$$ | awk '{print NR,$0}' | awk '{print $1}'))
#IFS=$'\n' os_edition_num=($(cat /anydeploy/tmp/os_version_list.$$ | awk '{print v++,$0}' | awk '{print $1}'))
IFS=$'\n' os_edition_name=($(cat /anydeploy/tmp/os_version_list.$$))

          SELECTIONINFO=()

          # Combine Arrays for Dialog Output

    for i in "${!os_edition_name[@]}"; do SELECTIONINFO+=( "${os_edition_num[${i}]}" "${os_edition_name[${i}]}" ); done

    # Display Dialog for OS Selection

    dialog --clear \
        --cancel-label "BACK" \
        --title "Some Windows Edition" \
        --menu "$banner2080" 20 80 10 "${SELECTIONINFO[@]}" 2> /anydeploy/tmp/chosen_edition.$$





    IFS=$'\r\n' GLOBIGNORE='*' command eval 'os_list=($(cat /anydeploy/tmp/os_version_list.$$))'

    #TODO check if ei.cfg exists, check edition



##############################################################################
#                      Generate unattend file                                #
##############################################################################

sudo rm /anydeploy/tmp/extracted/*

# for home needs manual input for COA

export chosen_edition_index=`cat /anydeploy/tmp/chosen_edition.$$`

# Select Key for chosen edition



export chosen_edition_name=`cat /anydeploy/tmp/os_version_list.$$ | sed -n ${chosen_edition_index}p`



echo "chosen edition index: $chosen_edition_index"
echo "chosen edition name: $chosen_edition_name"

# pickup right COA Key

chosen_edition_key=`cat /anydeploy/systems/Windows/KMS_Keys_List.md | grep "$chosen_edition_name |" | sed 's/\||//g' | sed -e "s/$chosen_edition_name//" | xargs`

echo "chosen edition key: $chosen_edition_key"


##############################################################################
#                      Dialog MBR / GPT                                      #
##############################################################################






# Check if matching sysprep file exists

#  TODO IMPORTANT match sysprep file based on edition selected

# Windows 7 Test
#cp /anydeploy/systems/Windows/unattend_files/autounattend_win7_mbr_audit.xml /anydeploy/tmp/extracted/autounattend.xml

#Windows 10 Generate
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
#rm /anydeploy/tmp/os_version_list.*


# TODO - clear generated files + temp folders (only generated by this script)
