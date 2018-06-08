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


  #echo "selected disk partitions array: ${SELECTED_DISK_PARTITIONS[@]}"
  #echo "selected disk partitions array start sector: ${SELECTED_DISK_PARTITIONS_STARTSECTOR[@]}"
  #echo "selected disk partitions array end sector: ${SELECTED_DISK_PARTITIONS_ENDSECTOR[@]}"
  #echo "selected disk partitions array sectorcount: ${SELECTED_DISK_PARTITIONS_SECTORCOUNT[@]}"
  #echo "selected disk partitions array size: ${SELECTED_DISK_PARTITIONS_SIZE[@]}"
  #echo "selected disk partitions array name: ${SELECTED_DISK_PARTITIONS_NAME[@]}"



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
