#!/bin/bash

# Change TTY - > chvt 2


# Wipe Partition Map from current partitions
wipefs /dev/sda -a

# Create Partitions using sfdisk
sfdisk /dev/sda < /anydeploy/scripts/win10_efi_partitionmap

# Install deps
apt install wimtools build-essential dosfstools -y

# Create directory to mount iso

umount /mnt/iso && rmdir /mnt/iso && mkdir /mnt/iso

# Mount Windows ISO

mount /anydeploy/iso/Win10_1803_English_x64.iso /mnt/iso/


# Select Index

    # TODO DIALOG
    # wiminfo /mnt/iso/sources/install.wim
    # 6 for windows 10 pro

# Extract Main partition using wimextract to C: (/dev/sda4)

mkfs.ntfs /dev/sda4 --quick && wimapply /mnt/iso/sources/install.wim 6 /dev/sda4 --no-acls

# Mkdir for C:
umount /mnt/win_c && rmdir /mnt/win_c && mkdir /mnt/win_c

# Mount C: (dev/sda4)

mount /dev/sda4 /mnt/win_c


# Format Recovery Partition to NTFS

mkfs.ntfs /dev/sda1 --quick

# Mount recovery partition

umount /mnt/recovery_partition && rmdir /mnt/recovery_partition && mkdir /mnt/recovery_partition

mount -t ntfs-3g -o uid=$(id -u) /dev/sda1 /mnt/recovery_partition
mkdir /mnt/recovery_partition/Recovery
mkdir /mnt/recovery_partition/Recovery/WindowsRE
cp /mnt/win_c/Windows/System32/Recovery/Winre.wim /mnt/recovery_partition/Recovery/WindowsRE


# Format EFI
mkfs.fat -F32 /dev/sda2

# Copy efi files

mkdir /mnt/efi

mount /dev/sda2 /mnt/efi



#bootrec /fixmbr
#bootrec /rebuildbcd -Y # TODO skip question

#bootrec /ScanOs

# DISKPART

diskpart
select disk 0
list vol
select vol 3
#delete volume override
#list vol
#list partition
#create partition efi size=200
#format quick fs=fat32
#assign letter=G:
#md EFI\Microsoft\Boot
bootrec /rebuildbcd
