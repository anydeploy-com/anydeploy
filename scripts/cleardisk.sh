#!/bin/bash

echo "Clearing disk for Windows UEFI"

#Sample Windows 10 Disk


#root@anylive_x64:/anydeploy# gdisk -l /dev/sda
#GPT fdisk (gdisk) version 1.0.1

#The protective MBR's 0xEE partition is oversized! Auto-repairing.

#Partition table scan:
#  MBR: protective
#  BSD: not present
#  APM: not present
#  GPT: present

#Found valid GPT with protective MBR; using GPT.
#Disk /dev/sda: 41943040 sectors, 20.0 GiB
#Logical sector size: 512 bytes
#Disk identifier (GUID): A674208A-B8EE-4691-B868-C3B9A67B4B47
#Partition table holds up to 128 entries
#First usable sector is 34, last usable sector is 41943006
#Partitions will be aligned on 2048-sector boundaries
#Total free space is 4029 sectors (2.0 MiB)

#Number  Start (sector)    End (sector)  Size       Code  Name
#   1            2048         1023999   499.0 MiB   2700  Basic data partition
#   2         1024000         1226751   99.0 MiB    EF00  EFI system partition
#   3         1226752         1259519   16.0 MiB    0C01  Microsoft reserved ...
#   4         1259520        41940991   19.4 GiB    0700  Basic data partition



sgdisk -o /dev/sda # clear disk as gpt
sgdisk -n 1:2048:1023999 -c 1:"Basic data partition" -t 1:2700 /dev/sda # Create Recovery Partition
sgdisk -n 2:1024000:1226751 -c 2:"EFI system partition" -t 2:EF00 /dev/sda # Create Recovery Partition
sgdisk -n 3:1226752:1259519 -c 3:"Microsoft reserved" -t 3:0C01 /dev/sda # Create Recovery Partition
sgdisk -n 4:1259520:41940991 -c 4:"Basic data partition" -t 4:0700 /dev/sda # Create Recovery Partition


# DIALOG DD clone

# (pv -n /dev/sda | dd of=/dev/sdb bs=128M conv=notrunc,noerror) 2>&1 | dialog --gauge "Running dd command (cloning), please wait..." 10 70 0

# Capture Partitions

#dd if=/dev/sda1 of=/nfs/images/sda1 status=progress
#dd if=/dev/sda1 of=/nfs/images/sda1 status=progress
#dd if=/dev/sda1 of=/nfs/images/sda1 status=progress
#dd if=/dev/sda1 of=/nfs/images/sda1 status=progress


# Capture Partitions (Partclone)

# partclone.ntfs -c -s /dev/sda1 -o /nfs/images/sda1_partclone --ncurses
# partclone.fat32 -c -s /dev/sda2 -o /nfs/images/sda2_partclone --ncurses
# partclone.dd -s /dev/sda3 -o /nfs/images/sda3_partclone --ncurses



# Recover Partitions

#dd if=/nfs/images/sda1 of=/dev/sda1 status=progress
#dd if=/nfs/images/sda2 of=/dev/sda2 status=progress
#dd if=/nfs/images/sda3 of=/dev/sda3 status=progress
#dd if=/nfs/images/sda4 of=/dev/sda4 status=progress
