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

USAGE_DESC="USAGE: ./deploy.sh [-s | --source] <source> [-d | --destination] <destination>"
USAGE_SAMPLE="SAMPLE: ./deploy.sh -source \"/nfs/images/Windows 7\" -destination \"/dev/sda\" "

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
#                               Run Deployment Script                        #
##############################################################################




echo "Running Deployment Script"
echo ""
echo "Source: ${source}"
echo "Destination: ${destination}"


# Get Partition array for destination ( verify if partition table copied properly)

partitions_destination=($(sfdisk -d /dev/sda | grep -v "device" | grep "/dev/sda" | awk '{print $1}'))

# Unmount any if mounted - destination

echo "Unmounting any partitions from ${destination}"

for i in "${partitions_destination[@]}"; do
  umount ${i}
  sleep 5
done

sleep 2

# TODO Verify if running bios mode matches image - if not prompt what to do

# WipeFS first

echo "Initially wiping filesystem at ${destination}"
wipefs ${destination}
sleep 5

# Write MBR

echo "Source mbr file: ${source}/mbr.img"

if [ -f "${source}/mbr.img" ]; then
echo "DEBUG: mbr image exists - writing"
dd if="${source}/mbr.img" of="${destination}" &>/dev/tty1
sleep 1
else
echo "DEBUG: mbr image missing - cancelling"
sleep 60
exit 1
fi


# Write Partition Table

echo "Source partition_table file: $source/partition_table"

if [ -f "${source}/partition_table" ]; then
echo "DEBUG: partition table exists - writing"
sfdisk "${destination}" < "${source}/partition_table" &>/dev/tty1
else
echo "ERROR: mbr image missing - cancelling"
sleep 60
exit 1
fi

# Get Partition array for source  - dir folder and build array from p*.img files

partitions_source=($(ls "${source}"/p*.img))


echo "DEBUG: Partition Source Amount: ${#partitions_source[@]}"
echo "DEBUG: Partition Source Array: ${partitions_source[@]}"



echo "DEBUG: Partition Destination Amount: ${#partitions_destination[@]}"
echo "DEBUG: Partition Destination Array: ${partitions_destination[@]}"

# Verify if partition array source NO matches partition array destination NO

# Update partitions_destination array after changes
partitions_destination=()
sleep 2
partitions_destination=($(sfdisk -d /dev/sda | grep -v "device" | grep "/dev/sda" | awk '{print $1}'))
sleep 2

if [ ${#partitions_source[@]} = ${#partitions_destination[@]} ]; then
  echo "DEBUG: partitions amount matching - arrays correct, partition map deployed correctly, will continue"
  # Run Partclone
  echo "DEBUG: Running Partclone Tasks"
  for i in "${!partitions_source[@]}"; do
    partclone.restore --ncurses --source "${partitions_source[${i}]}" --output "${partitions_destination[${i}]}"
  done


else
  echo "ERROR: amount of partitions not matching - can't continue"
  sleep 60
  exit 1
fi

# Resize (expand) System Partition
