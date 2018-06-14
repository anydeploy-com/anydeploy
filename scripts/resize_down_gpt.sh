#!/bin/bash

# Save SFDISK Info to file

mkdir /nfs/images/test_win10_kvm
sfdisk --dump /dev/sda > /nfs/images/test_win10_kvm/partition_table
sfdisk --json /dev/sda > /nfs/images/test_win10_kvm/partition_table_json

resize_start_sector=$(cat /nfs/images/test_win10_kvm/partition_table | grep "/dev/sda4" | awk '{print $4}' | tr -d ",")


# TODO MODIFY TO USE GDISK FOR GPT AND FDISK FOR MBR (PROBLEMS WITH PARTITIONS NOT HIDDEN ETC)

# root@anylive_x64:~# sfdisk /dev/sda -l >
# Disk /dev/sda: 465.8 GiB, 500107862016 bytes, 976773168 sectors
# Units: sectors of 1 * 512 = 512 bytes
# Sector size (logical/physical): 512 bytes / 4096 bytes
# I/O size (minimum/optimal): 4096 bytes / 4096 bytes
# Disklabel type: gpt
# Disk identifier: 96A4F2A9-3DAB-4CEB-9977-DC311F8909AA

# Device       Start      End  Sectors  Size Type
# /dev/sda1     2048  1023999  1021952  499M Windows recovery environment
# /dev/sda2  1024000  1226751   202752   99M EFI System
# /dev/sda3  1226752  1259519    32768   16M Microsoft reserved
# /dev/sda4  1259520 62912511 61652992 29.4G Microsoft basic data




#NTFS

# Save NTFS Info to file

ntfsresize --info /dev/sda4 > /nfs/images/test_win10_kvm/sda4_ntfs_info && cat /nfs/images/test_win10_kvm/sda4_ntfs_info_old
ntfs_space_in_use=$(grep "Space in use" /nfs/images/test_win10_kvm/sda4_ntfs_info | awk '{print $5}')
ntfs_space_to_add="2000"
new_ntfs_size=$((${ntfs_space_in_use} + ${ntfs_space_to_add}))
new_ntfs_size_m="${new_ntfs_size}M"


# root@anylive_x64:/nfs/images/test_win10_kvm# cat ntfsinfo_sda4
# ntfsresize v2016.2.22AR.1 (libntfs-3g)
# Device name        : /dev/sda4
# NTFS volume version: 3.1
# Cluster size       : 4096 bytes
# Current volume size: 31566328320 bytes (31567 MB)
# Current device size: 31566331904 bytes (31567 MB)
# Checking filesystem consistency ...
# 100.00 percent completed
# Accounting clusters ...
# Space in use       : 10640 MB (33.7%)
# Collecting resizing constraints ...
# You might resize at 10639765504 bytes or 10640 MB (freeing 20927 MB).
# Please make a test run using both the -n and -s options before real resizing!



# Resizedown


  # Run ntfsresize test

  ntfsresize --no-action --size ${new_ntfs_size_m} /dev/sda4 > /nfs/images/test_win10_kvm/sda4_ntfs_resizetest && cat /nfs/images/test_win10_kvm/sda4_ntfs_resizetest

  # Actual resize

  ntfsresize --force --size ${new_ntfs_size_m} /dev/sda4 > /nfs/images/test_win10_kvm/sda4_ntfs_resize && cat /nfs/images/test_win10_kvm/sda4_ntfs_before_resize

  # Verify if done and display log if not


  # Run physical partition resize (sfdisk) needed ??

  # get amount of sectors for sfdisk - divide current device size by 512 + (3 x 1024 )

  # $current_volume_size / 512 + (1024 * 3) = 24983537

  #new_sector_size = $current_volume_size / 512 + (1024 * 3) = 24983537







# Resizeup

# Run sfdisk to resize up (delete + resize partition back with maximum size)

partition_number=$(sfdisk -l /dev/sda | grep "/dev/sda" | grep -v "Disk" | grep -n "/dev/sda4" | cut -f1 -d:)







# Delete Partition

echo "Removing Partition ${partition_number}"
sfdisk --delete /dev/sda ${partition_number}

# Create copy of partition table

cp /nfs/images/test_win10_kvm/partition_table /nfs/images/test_win10_kvm/new_partition_table

# Replace partition size in new file

echo "Replacing size in new partitions file"

ntfsresize --info -f /dev/sda4 > /nfs/images/test_win10_kvm/sda4_ntfs_info_after_resize && cat /nfs/images/test_win10_kvm/sda4_ntfs_info_after_resize

old_partition_size=$(cat /nfs/images/test_win10_kvm/partition_table | grep "/dev/sda4" | awk '{print $6}' | tr -d ",")

new_size_ntfs=$(cat /nfs/images/test_win10_kvm/sda4_ntfs_info_after_resize | grep "Current volume size" | awk '{print $4}')

#new_partition_size = new_size_ntfs / 512 + (1024 * 3)
new_partition_size=$(($new_size_ntfs / 512 + (1024*3)))

sed -i "s/${old_partition_size}/${new_partition_size}/g" /nfs/images/test_win10_kvm/new_partition_table

# make efi hidden (visible after resizing)






# Recreate Partition with maximum size
echo "Recreating Partition with new size (old size is #TODO -add)"
sfdisk /dev/sda < /nfs/images/test_win10_kvm/new_partition_table
