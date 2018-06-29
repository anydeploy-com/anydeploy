#!/bin/bash

# Restore mbr

echo "restoring mbr"
dd if="/nfs/images/Windows 7/mbr.img" of=/dev/sda status=progress
sleep 2

# Restore Partition Table
echo "partition table"
sfdisk /dev/sda < "/nfs/images/Windows 7/partition_table"
sleep 2

# Restoring Partitions

partclone.restore --ncurses --source p1.img --output /dev/sda1
partclone.restore --ncurses --source p2.img --output /dev/sda2
