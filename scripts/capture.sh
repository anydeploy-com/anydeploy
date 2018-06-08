#!/bin/bash      IFS=$SAVEIFS

# Include functions
. /anydeploy/scripts/includes/functions.sh

# Include global config
. /anydeploy/settings/global.sh

  # Detect Disks

  . /anydeploy/scripts/detect_disks.sh


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

  IFS=$SAVEIFS

  echo "Selected Disk: ${selected_disk}"
  sleep 5



  # Mount + detect OS / Version / Codename / Revision / Architecture / Boot Type

  echo "Listing Parts on ${selected_disk}"

sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk"


SELECTED_DISK_PARTITIONS=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $1}'))

echo "selected disk partitions array: ${SELECTED_DISK_PARTITIONS[@]} "

sleep 5

  # Generate name and prompt if okay

  # Create folder with name

  # Save textfile with name

  # Save output of fdisk for partition information

  # Save mbr

  # Detect OS partition and prompt to resize

  # Run Partclone for each partition and name them part1 part2 part3 etc.
