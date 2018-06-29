#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions
  source ../specs/detect_disks.sh                       # Detect Disks


  ##############################################################################
  #                       Get Sources (images) List                            #
  ##############################################################################


# Detect if system running in BIOS or UEFI


# Create Array of available images (folders)
SAVEIFS=$IFS

# Change IFS for proper device names (contain spaces)
IFS=$'\n'

if [ "$match_bios" = "yes" ]; then
  echo "showing only ${bios_mode} images"
  menu_desc="please pick image to deploy - showing only compatible \"${bios_mode}\" images"
  images=($(ls -lhd /nfs/images/*/${bios_mode} | awk '{print $9,$10,$11,$12,$13,$14,$15}' | sed "s/\/${bios_mode}//"))
else
  echo "showing all images"
  menu_desc="please pick image to deploy - showing all images (bios + efi)"
  images=($(ls -lhd /nfs/images/* | awk '{print $9,$10,$11,$12,$13,$14,$15}'))
fi


# Create Dialog Menu from array

for i in "${!images[@]}"; do
  # Images Dialog Name
images_dialog+=("${i}" "${images[${i}]}")
done

# Display images - debugging

#for i in ${images[@]}; do
#echo ${i}
#done

echo ${images_dialog[@]}

##############################################################################
#                    Display Sources (images) (dialog)                       #
##############################################################################

selected_image_id=$(dialog --backtitle "anydeploy ${devtype} / ip: ${ip_address_dialog} / biosmode: ${bios_mode} - Deploy Menu" \
                    --menu "${menu_desc}" 30 100 10 ${images_dialog[@]} 2>&1 >/dev/tty)

selected_image_path=${images[$selected_image_id]}

source=${selected_image_path}
echo "Physical Disks: ${PHYSICALDISKS[@]}"


echo "Selected image id: ${selected_image_id}"
echo "Selected Image path": ${selected_image_path}
echo "Source": ${source}
sleep 2

##############################################################################
#                        Get Destination (disks) List                        #
##############################################################################

# Data included with detect_disks.sh script

if [ "$skip_menu_if_single_disk" = "yes" ]; then
  echo "DEBUG: Skipping menu if single disk enabled"
  if [ "${#PHYSICALDISKS[@]}" = "1" ]; then
  echo "DEBUG: single disk detected - skipping menu"
  else
  echo "DEBUG: multiple disks detected - displaying menu"
  sleep 1
  fi
else
  echo "DEBUG: Displaying disk menu even with single disk"

fi




# Fix back IFS
IFS=$SAVEIFS

# Restore mbr

#echo "restoring mbr"
#dd if="/nfs/images/Windows 7/mbr.img" of=/dev/sda status=progress
#sleep 2

# Restore Partition Table
#echo "partition table"
#sfdisk /dev/sda < "/nfs/images/Windows 7/partition_table"
#sleep 2

# Restoring Partitions

#partclone.restore --ncurses --source p1.img --output /dev/sda1
#partclone.restore --ncurses --source p2.img --output /dev/sda2
