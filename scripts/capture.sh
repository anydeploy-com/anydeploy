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
  SELECTED_DISK_SECTORCOUNT=$(fdisk -l /dev/${selected_disk} | grep "Disk /dev/${selected_disk}" | awk '{print $7}')
  SELECTED_DISK_PART_TYPE=$(udevadm info -q property -n sda | grep "ID_PART_TABLE_TYPE" | awk -F'=' '{print $2}')
  SELECTED_DISK_PARTITIONS=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $1}'))
  SELECTED_DISK_PARTITIONS_STARTSECTOR=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $2}'))
  SELECTED_DISK_PARTITIONS_ENDSECTOR=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $3}'))
  SELECTED_DISK_PARTITIONS_SECTORCOUNT=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $4}'))
  SELECTED_DISK_PARTITIONS_SIZE=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $5}'))
  SELECTED_DISK_PARTITIONS_SIZEUNIT=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{print $5}' | sed 's/[0-9]*//g' | tr -d "."))
  SELECTED_DISK_PARTITIONS_NAME=($(sfdisk -l /dev/${selected_disk} | grep "/dev/" | grep -v "Disk" | awk '{$1=$2=$3=$4=$5=""; print $0}' | sed 's/^ *//'))

  IFS=$SAVEIFS

  echo "Selected Disk Sectorcount: ${SELECTED_DISK_SECTORCOUNT}"
  echo "Partition Table Type is: ${SELECTED_DISK_PART_TYPE}"
  echo "Partitions found on ${selected_disk}: ${#SELECTED_DISK_PARTITIONS[@]}"
  echo "Partitions to Clone:"
  echo ""
  # Detect Filesystems
    for i in "${!SELECTED_DISK_PARTITIONS[@]}"; do
      SELECTED_DISK_PARTITIONS_SIZEVALUE[${i}]=$(echo ${SELECTED_DISK_PARTITIONS_SIZE[${i}]} | cut -f1 -d"." | tr -dc '0-9' )
      SELECTED_DISK_PARTITIONS_DEVNAME[${i}]=$(echo ${SELECTED_DISK_PARTITIONS[${i}]} | sed 's/dev//' | tr -d "/")
      SELECTED_DISK_PARTITIONS_FSTYPE[${i}]=$(lsblk -f | grep ${SELECTED_DISK_PARTITIONS_DEVNAME[${i}]} | awk '{print $2}')
      # TODO IF FSTYPE HAS NO VALUE THEN CALL UNKNOWN OR SOMETHING
  # Decide on resizing / generate cloning command
      if [ "${SELECTED_DISK_PARTITIONS_FSTYPE[${i}]}" = "vfat" ]; then
        SELECTED_DISK_PARTITIONS_CLONECMD[${i}]="partclone.dd" # might use dd because otherwise efi isn't hidden 
        SELECTED_DISK_PARTITIONS_RESIZE[${i}]="no"
        SELECTED_DISK_PARTITIONS_RESIZE_REASON[${i}]="filesystem type not setup to be resized (${SELECTED_DISK_PARTITIONS_FSTYPE[${i}]})"
      elif [ "${SELECTED_DISK_PARTITIONS_FSTYPE[${i}]}" = "ext4" ]; then
        SELECTED_DISK_PARTITIONS_CLONECMD[${i}]="partclone.ext4"
        SELECTED_DISK_PARTITIONS_RESIZE[${i}]="no"
        SELECTED_DISK_PARTITIONS_RESIZE_REASON[${i}]="Linux resizing not implemeneted yet"
      elif [ "${SELECTED_DISK_PARTITIONS_FSTYPE[${i}]}" = "ntfs" ]; then
        SELECTED_DISK_PARTITIONS_CLONECMD[${i}]="partclone.ntfs"
              if [ "${SELECTED_DISK_PARTITIONS_SIZEUNIT[${i}]}" = "M" ]; then
              SELECTED_DISK_PARTITIONS_RESIZE[${i}]="no"
              SELECTED_DISK_PARTITIONS_RESIZE_REASON[${i}]="partition size unit to small - MiB (Megabytes)"
              elif [ "${SELECTED_DISK_PARTITIONS_SIZEUNIT[${i}]}" = "T" ]; then
              SELECTED_DISK_PARTITIONS_RESIZE[${i}]="yes"
              SELECTED_DISK_PARTITIONS_RESIZE_REASON[${i}]="large drive - partition size unit in TiB (Terabytes)"
              elif [ "${SELECTED_DISK_PARTITIONS_SIZEUNIT[${i}]}" = "G" ]; then
                  # Decide on resize based on size - loaded from global config
                  # minimum_resizable_ntfs="15"
                  if [ ${SELECTED_DISK_PARTITIONS_SIZEVALUE[${i}]} -gt ${minimum_resizable_ntfs} ]; then
                  SELECTED_DISK_PARTITIONS_RESIZE[${i}]="yes"
                  SELECTED_DISK_PARTITIONS_RESIZE_REASON[${i}]="partition size in gb is greater than defined (${minimum_resizable_ntfs} GiB)"
                  else
                  SELECTED_DISK_PARTITIONS_RESIZE[${i}]="no"
                  SELECTED_DISK_PARTITIONS_RESIZE_REASON[${i}]="size is less than defined (${minimum_resizable_ntfs} GiB)"
                  fi
              else
                echo "Unknown Size"
              fi
      else
        SELECTED_DISK_PARTITIONS_CLONECMD[${i}]="partclone.dd"
        SELECTED_DISK_PARTITIONS_RESIZE[${i}]="no"
        SELECTED_DISK_PARTITIONS_RESIZE_REASON[${i}]="filesystem type not setup to be resized (${SELECTED_DISK_PARTITIONS_FSTYPE[${i}]})"
      fi
  # Echo Partitions for cloning
      echo "Cloning Partition: ${SELECTED_DISK_PARTITIONS_DEVNAME[${i}]} / ${SELECTED_DISK_PARTITIONS_FSTYPE[${i}]} / ${SELECTED_DISK_PARTITIONS_NAME[${i}]}"
      echo "Command is: ${SELECTED_DISK_PARTITIONS_CLONECMD[${i}]}"
      echo "Size: ${SELECTED_DISK_PARTITIONS_SIZE[${i}]}"
      echo "Size (Value): ${SELECTED_DISK_PARTITIONS_SIZEVALUE[${i}]}"
      echo "Unit of Volume (Size): ${SELECTED_DISK_PARTITIONS_SIZEUNIT[${i}]}"
      echo "Resize: ${SELECTED_DISK_PARTITIONS_RESIZE[${i}]} - ${SELECTED_DISK_PARTITIONS_RESIZE_REASON[${i}]}"
      echo "" # empty echo for readability
      sleep 10
    done


    # Run Resizing





    # Run Cloning


    sleep 10

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


# Identify Type

# lsblk -f | grep sda2 | awk '{print $2}'


# SAMPLE OUTPUT:

# root@anydeploy:/nfs/images# lsblk -f | grep sda2 | awk '{print $2}'
# ext4


###### BIOS ######


## TODO write for each function to detect each partition type and use
## appropriate partclone version otherwise use partclone.dd

# partclone.btrfs        # partclone.ext4dev      # partclone.hfs+         # partclone.ntfs
# partclone.chkimg       # partclone.extfs        # partclone.hfsp         # partclone.ntfsfixboot
# partclone.dd           # partclone.f2fs         # partclone.hfsplus      # partclone.ntfsreloc
# partclone.exfat        # partclone.fat          # partclone.imager       # partclone.reiser4
# partclone.ext2         # partclone.fat12        # partclone.info         # partclone.restore
# partclone.ext3         # partclone.fat16        # partclone.minix        # partclone.vfat
# partclone.ext4         # partclone.fat32        # partclone.nilfs2       # partclone.xfs




# Capture
#mkdir /nfs/images/test_win10_kvm
#sfdisk -d /dev/sda > /nfs/images/test_win10_kvm/partition_table
#dd if=/dev/sda1 of=/nfs/images/test_win10_kvm/sda1.img status=progresss
#dd if=/dev/sda2 of=/nfs/images/test_win10_kvm/sda2.img status=progress
#dd if=/dev/sda of=/nfs/images/test_win10_kvm/mbr.img bs=512 count=1 status=progress

# partclone.ntfs -c -s /dev/sda4 -o /nfs/images/test_win10_kvm/sda4_partclone.img

# Restore
# sfdisk /dev/sda < /nfs/images/test_win10_kvm/partition_table
# dd if=/nfs/images/test_win10_kvm/sda1.img of=/dev/sda1 status=progress
# dd if=/nfs/images/test_win10_kvm/sda2.img of=/dev/sda2 status=progress
# dd if=/nfs/images/test_win10_kvm/mbr.img of=/dev/sda bs=446 count=1
#

# partclone.restore -d -s /nfs/images/test_win10_kvm/sda4_partclone.img -o /dev/sda4




# Resize NTFS Partition  (max size)






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
