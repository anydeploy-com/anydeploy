#!/bin/bash

 IFS=$SAVEIFS

# Include functions
. /anydeploy/scripts/includes/functions.sh

# Include global config
. /anydeploy/settings/global.sh

  # Detect Disks

  . /anydeploy/scripts/detect_disks.sh

  # Stop if no disks detected

if [ ${#PHYSICALDISKS[@]} -eq 0 ]; then
      sleep 1
else

  # Reset to default - in case of re-run
  DISK_DIALOG=()




  # If server prompt if physical disk or VM
  # TODO

  # Select Disk ( array + dialog)


  SAVEIFS=$IFS

      IFS=$'\n'

  for i in "${!PHYSICALDISKS[@]}"; do DISK_DIALOG+=( "${PHYSICALDISKS[${i}]}" "${DISK_MODEL[${i}]} / ${DISK_MODEL_FAMILY[${i}]} [${DISK_SIZE[${i}]}] " ); done





  export selected_disk=$(dialog --backtitle "anydeploy ${devtype} - Capture - Select Disk" \
                      --menu "Select Disk" 30 100 10 ${DISK_DIALOG[@]} 2>&1 >/dev/tty)




  if [ ! -z "$selected_disk" ]; then
    echo "Selected Disk: ${selected_disk}"
    sleep 2

  SELECTED_DISK_PARTITIONS=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $1}'))


  SELECTED_DISK_PARTITIONS_STARTSECTOR=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $2}'))
  SELECTED_DISK_PARTITIONS_ENDSECTOR=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $3}'))
  SELECTED_DISK_PARTITIONS_SECTORCOUNT=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $4}'))
  SELECTED_DISK_PARTITIONS_SIZE=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $5}'))
  SELECTED_DISK_PARTITIONS_NAME=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{$1=$2=$3=$4=$5=""; print $0}' | sed 's/^ *//'))

# Detect System Partitions
  for i in "${SELECTED_DISK_PARTITIONS_NAME[@]}"; do
    echo ${i}
    if [ "${i}" = "Microsoft basic data" ]; then
    echo "system partition - ${i}"
    fi
  done


  IFS=$SAVEIFS


  echo "Partitions found on ${selected_disk}: ${#SELECTED_DISK_PARTITIONS[@]}"


# Windows Recovery

# Windows Recovery Environment (RE) partition (hidden NTFS partition type 07h)

# gdisk type = 2700 (regular partition is 0700)

  # sample Windows 10 (proper install )



  # /dev/sda1     2048  1023999  1021952  499M Windows recovery environment
# /dev/sda2  1024000  1226751   202752   99M EFI System
# /dev/sda3  1226752  1259519    32768   16M Microsoft reserved
# /dev/sda4  1259520 41940991 40681472 19.4G Microsoft basic data



  #echo "selected disk partitions array: ${SELECTED_DISK_PARTITIONS[@]}"
  #echo "selected disk partitions array start sector: ${SELECTED_DISK_PARTITIONS_STARTSECTOR[@]}"
  #echo "selected disk partitions array end sector: ${SELECTED_DISK_PARTITIONS_ENDSECTOR[@]}"
  #echo "selected disk partitions array sectorcount: ${SELECTED_DISK_PARTITIONS_SECTORCOUNT[@]}"
  #echo "selected disk partitions array size: ${SELECTED_DISK_PARTITIONS_SIZE[@]}"
  #echo "selected disk partitions array name: ${SELECTED_DISK_PARTITIONS_NAME[@]}"


echo "SAMPLE PARTITION MAKING"

# DO NOT RUN IF YOU DONT KNOW WHAT ARE YOU DOING








#sgdisk -og $1 # CAREFUL CLEARS PARTITION TABLE
#sgdisk -n 1:2048:4095 -c 1:"BIOS Boot Partition" -t 1:ef02 $1
#sgdisk -n 2:4096:413695 -c 2:"EFI System Partition" -t 2:ef00 $1
#sgdisk -n 3:413696:823295 -c 3:"Linux /boot" -t 3:8300 $1
#ENDSECTOR=`sgdisk -E $1`
#sgdisk -n 4:823296:$ENDSECTOR -c 4:"Linux LVM" -t 4:8e00 $1
#sgdisk -p $1



  sleep 2

    # Mount + detect OS / Version / Codename / Revision / Architecture / Boot Type



    # Generate name and prompt if okay

    # Create folder with name

    # Save textfile with name

    # Save output of fdisk for partition information

    # Save mbr

    # Detect OS partition and prompt to resize

    # Run Partclone for each partition and name them part1 part2 part3 etc.
  else
    echo "disk not selected"
    sleep 5
  fi
fi
