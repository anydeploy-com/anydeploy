#!/bin/bash

# Save SFDISK Info to file

sfdisk --dump /dev/sda > /nfs/images/test_win10_kvm/partition_table
sfdisk --json /dev/sda > /nfs/images/test_win10_kvm/partition_table_json

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


resize_start_sector=$(cat /nfs/images/test_win10_kvm/partition_table | grep "/dev/sda4" | awk '{print $4}' | tr -d ",")
resize_end_sector=

#NTFS

# Save NTFS Info to file

ntfsresize --info /dev/sda4 > /nfs/images/test_win10_kvm/sda4_ntfs_info

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






ntfs_error=
ntfs_space_in_use=
ntfs_resize_size=$ntfs_space_in_use+2000 #TODO


# Resizedown


  # Run ntfsresize test

  ntfsresize --no-action --size 12640M /dev/sda4 > /nfs/images/test_win10_kvm/sda4_ntfs_resizetest

  # Actual resize

  ntfsresize --force --size 12640M /dev/sda4 > /nfs/images/test_win10_kvm/sda4_ntfs_resizetest

  # Verify if done and display log if not


  # Run physical partition resize (sfdisk) needed ??


# Resizeup


  # Run sfdisk to resize up (delete + resize partition back with maximum size)

partition_number=$(sfdisk -l /dev/sda | grep "/dev/sda" | grep -v "Disk" | grep -n "/dev/sda4" | cut -f1 -d:)







# Delete Partition

echo "Removing Partition ${partition_number}"
sfdisk --delete /dev/sda ${partition_number}

# Create copy of partition table

cp /nfs/images/test_win10_kvm/partition_table /nfs/images/test_win10_kvm/partition_table_new

# Recreate Partition with maximum size
echo "Recreating Partition with new size (old size is #TODO -add)"
echo "n,4,1259520,62914526,w" | sfdisk /dev/sda -N${partition_number}
