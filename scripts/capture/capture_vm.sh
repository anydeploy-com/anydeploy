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

# check if exists in losetup
source_losetup_devname=$(losetup | grep "${source}" | grep -v "deleted" | awk '{print $1}')

echo ${source_losetup_devname}

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
# Partitions_array_id
selected_disk_partition_ids=($(sfdisk -l ${selected_disk_path} | grep "${selected_disk_path}" | grep -v "Disk" | awk '{print $1}'))
# Partitions count <number>
selected_disk_partitions_count="${#selected_disk_partition_ids[@]}"



# Sector Count



##############################################

echo "source=\"${source}\""
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
  #Available columns (for -o):
  # gpt: Device Start End Sectors Size Type Type-UUID Attrs Name UUID
  # dos: Device Start End Sectors Cylinders Size Type Id Attrs Boot End-C/H/S Start-C/H/S
  selected_disk_partition_sizes[${i}]=$(fdisk -l -o Device,Size | grep "${selected_disk}" | grep "${selected_disk_partition_ids[${i}]}" | awk '{print $2}')
  selected_disk_partition_types[${i}]=$(fdisk -l -o Device,Type | grep "${selected_disk}" | grep "${selected_disk_partition_ids[${i}]}" | awk '{print $2}')
  echo "Partition Size: ${selected_disk_partition_sizes[${i}]}"
  echo "Partition Type: ${selected_disk_partition_types[${i}]}"
  echo ""   # echoing empty line for readability

  # Sample Cloning

  #partclone.ntfs -c -d -s /dev/loop1p2 -o p2.img

done


# List partitions
