#!/bin/bash

# Fix - mkisofs doesnt exist in debian
ln -s /usr/bin/genisoimage /usr/bin/mkisofs

# Copy memdisk
cp /usr/lib/syslinux/memdisk /anydeploy/www/

# Mount windows iso
mkdir /media/winimg
mount /anydeploy/iso/Win10_1803_English_x64.iso /media/winimg


# Go to temp directory
cd /anydeploy/tmp

# Create start.cmd

echo "cmd" > start.cmd

# Create WinpeIMG

mkwinpeimg --windows-dir=/media/winimg --start-script=start.cmd winpe.img

# create dir to mount winpe img

mkdir winpe_mount

# mount winpe
umount winpe_mount
sleep 2
mount winpe.img winpe_mount/


# Create dir for ipxe boot

mkdir /anydeploy/www/custom_winpe

# Copy Winpe files required to boot over ipxe

cp winpe_mount/boot/{bcd,boot.sdi} /anydeploy/www/custom_winpe/
cp winpe_mount/sources/boot.wim /anydeploy/www/custom_winpe/

# Add menu

# ADD item "custom_winpe Custom WIN_PE" after last item* (new line)

# ADD
