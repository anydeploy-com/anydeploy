#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions


##############################################################################
#                               Parse arguments                              #
##############################################################################

ARGUMENT_LIST=(
    "s"
    "d"
)

ARGUMENT_LIST_LONG=(
    "source"
    "destination"
)

USAGE_DESC="USAGE: ./capture [-s | --source] <source> [-d | --destination] <destination>"
USAGE_SAMPLE="SAMPLE: ./capture.sh -source \"/dev/sda\" -destination \"/images/Windows 7/\" "

# read arguments
opts=$(getopt \
    --name "$(basename "$0")" \
    --options "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
    --longoptions "$(printf "%s:," "${ARGUMENT_LIST_LONG[@]}")" \
    -- "$@"
)

required_arguments() {

  if [ -z "${source}" ]; then
    echo "<source> argument must be provided"
  fi

if [ -z "${destination}" ]; then
  echo "<destination> argument must be provided"
fi

if [ -z "${source}" ] || [ -z "${destination}" ]; then
  echo ""
  echo "${USAGE_DESC}"
  echo ""
  exit 1
fi
}

eval set --$opts

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s | --source )
            source="${2}"
            shift 2
            ;;

        -d | --destination )
            destination="${2}"
            shift 2
            ;;

        *)
            required_arguments
            break
            ;;
    esac
done


##############################################################################
#                               Get Disk Info                                #
##############################################################################

# check if exists in losetup
source_losetup_devname=$(losetup | grep "${source}" | grep -v "deleted" | awk '{print $1}')


if [ ! -z "source_losetup_devname" ]; then
echo "exists in losetup, devname=\"${source_losetup_devname}\""
echo "remounting"
losetup -d ${source_losetup_devname}
losetup -Pf ${source}
echo "updating disk loop device name"
source_losetup_devname=$(losetup | grep "${source}" | grep -v "deleted" | awk '{print $1}')
selected_disk=${source_losetup_devname}
else
  echo "doesnt exist in losetup, mounting"
  losetup -Pf ${source}
  echo "updating disk loop device name"
  source_losetup_devname=$(losetup | grep "${source}" | grep -v "deleted" | awk '{print $1}')
fi


selected_disk_path=${source_losetup_devname}
# if does then remove

# if doesnt then use losetup

# find loop id and assign to variable

#selected_disk_path=${source}
# Disklabel Type (gpt / dos)



# Disk Size
selected_disk_size=$(sfdisk -l ${selected_disk_path} | grep "${selected_disk_path}" | grep "Disk" | awk '{print $3,$4}' | cut -d "," -f 1 | xargs)
# Disk Sector Count
selected_disk_sectorcount=$(fdisk -l ${selected_disk_path} | grep "Disk ${selected_disk_path}" | awk '{print $7}')

##############################################################################
#                               Get Partitions Info                          #
##############################################################################

# Partitions_array_id
selected_disk_partition_ids=($(sfdisk -l ${selected_disk_path} | grep "${selected_disk_path}" | grep -v "Disk" | awk '{print $1}'))
# Partitions count <number>
selected_disk_partitions_count="${#selected_disk_partition_ids[@]}"



# Sector Count



##############################################

selected_disk_partition_ids_nodev=($(sfdisk -l ${selected_disk_path} | grep "${selected_disk_path}" | grep -v "Disk" | awk '{print $1}' | sed 's/\/dev\///'))

echo "source=\"${source}\""
echo "destination=\"${destination}\""
echo "selected_disk=\"${selected_disk}\""
echo "selected_disk_size=\"${selected_disk_size}\""
echo "selected_disk_sectorcount=\"${selected_disk_sectorcount}\""
echo "selected_disk_partitions_count=\"${selected_disk_partitions_count}\""
echo ""
echo "Listing partitions parameters:"
echo ""
for i in "${!selected_disk_partition_ids[@]}"; do
  echo Partition ID: ${i}
  echo Partition DEV: ${selected_disk_partition_ids[${i}]}
  echo Partition no_DEV: ${selected_disk_partition_ids_nodev[${i}]}
  #Available columns (for -o):
  # gpt: Device Start End Sectors Size Type Type-UUID Attrs Name UUID
  # dos: Device Start End Sectors Cylinders Size Type Id Attrs Boot End-C/H/S Start-C/H/S

  # TODO -rather use sfdisk --dump and use it's values since they're static and more useful for scripting

  selected_disk_partition_sizes[${i}]=$(fdisk -l -o Device,Size | grep "${selected_disk}" | grep "${selected_disk_partition_ids[${i}]}" | awk '{print $2}')
  selected_disk_partition_types[${i}]=$(fdisk -l -o Device,Type | grep "${selected_disk}" | grep "${selected_disk_partition_ids[${i}]}" | awk '{print $2}')
  selected_disk_partition_fstypes[${i}]=$(lsblk -f | grep "${selected_disk_partition_ids_nodev[${i}]}" | awk '{print $2}' | xargs)
  selected_disk_partition_save_filename[${i}]="$(echo "${selected_disk_partition_ids_nodev[${i}]}" | sed 's/loop1//').img"
  if [ "${selected_disk_partition_fstypes[${i}]}" = "ntfs" ]; then
  selected_disk_partition_command[${i}]="partclone.ntfs --ncurses -c -d -s \"${selected_disk_partition_ids[${i}]}\" -o \"${destination}/${selected_disk_partition_save_filename[${i}]}\" "
else
  #partclone.dd -d -s /dev/loop1p3 -o /nfs/images/win10_efi/p3.img
  selected_disk_partition_command[${i}]="partclone.dd"
fi
  echo "Partition Size: ${selected_disk_partition_sizes[${i}]}"
  echo "Partition Type: ${selected_disk_partition_types[${i}]}"
  echo "Partition FSType: ${selected_disk_partition_fstypes[${i}]}"
  echo "Partition Save_Filename: ${selected_disk_partition_save_filename[${i}]}"
  echo "Partition Command: ${selected_disk_partition_command[${i}]}"
  echo ""   # echoing empty line for readability

  # Sample Cloning

  #partclone.ntfs -c -d -s /dev/loop1p2 -o p2.img
done


##############################################################################
#                               Start Cloning                                #
##############################################################################
echo ""
echo "Cloning Starting"
echo ""
sleep 2

# Create image dir if doesn't exists

if [ -d "${destination}" ]; then
  echo "destination dir exists"
else
  echo "destination dir doesnt exist, creating"
  mkdir -p "${destination}"
fi


# Dump Partition Table
  echo "backing up partition table"
  sfdisk --dump "${selected_disk}" > "${destination}"/partition_table
  sleep 2
# Dump MBR
  echo "backing up mbr"
  dd if=${selected_disk} of="${destination}"/mbr.img bs=466 count=1
  sleep 2

# Saving Bios Mode (bios or efi)
  diskmode=$(fdisk -l ${selected_disk} | grep "Disklabel type:" | awk '{print $3}' | xargs)
  if [ "${diskmode}" = "gpt" ]; then
    vm_bios_mode="efi"
  else
    vm_bios_mode="bios"
  fi
  echo "Saving Bios mode type - ${vm_bios_mode}"
  touch "${destination}"/${vm_bios_mode}


# Start Actual Cloning
for i in "${!selected_disk_partition_ids[@]}"; do
  echo "Cloning Partition $i"
  eval "${selected_disk_partition_command[${i}]}"
done


# Remove from losetup after clone finished
#echo "Removing from losetup"
#sleep 2
#losetup -d ${source}
