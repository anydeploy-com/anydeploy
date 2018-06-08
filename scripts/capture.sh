#!/bin/bash

  # Detect Disks

  . /anydeploy/scripts/detect_disks.sh

  # Select Disk ( array + dialog)


  SAVEIFS=$IFS

      IFS=$'\n'

  for i in "${!PHYSICALDISKS[@]}"; do DISK_DIALOG+=( "${PHYSICALDISKS[${i}]}" "${DISK_MODEL[${i}]} / ${DISK_MODEL_FAMILY[${i}]} [${DISK_SIZE[${i}]}] " ); done





  selected_disk=$(dialog --backtitle "anydeploy ${devtype} - Capture - Select Disk" \
                      --menu "Select Disk" 30 100 10 ${DISK_DIALOG[@]} 2>&1 >/dev/tty)

  echo "Selected Disk: ${selected_disk}"


      IFS=$SAVEIFS

  # Mount + detect OS / Version / Codename / Revision / Architecture / Boot Type

  echo "Listing Parts on ${selected_disk}"

sfdisk -l /dev/sda | grep "/dev/" | grep -v "Disk"

  # Generate name and prompt if okay

  # Create folder with name

  # Save textfile with name

  # Save output of fdisk for partition information

  # Save mbr

  # Detect OS partition and prompt to resize

  # Run Partclone for each partition and name them part1 part2 part3 etc.
