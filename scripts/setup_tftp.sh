#!/bin/bash

. /anydeploy/scripts/includes/functions.sh
. /anydeploy/settings/global.sh

setup_tftp () {
    echo "setting up tftp"


# Download Syslinux and PxeLinux
apt-get install syslinux syslinux-efi pxelinux tftpd-hpa -y


# Create TFTP directory
mkdir /anydeploy/tftp
touch /anydeploy/tftp/.gitignore

echo "*" > /anydeploy/tftp/.gitignore

# Edit /etc/default/tftpd-hpa (TFTP_DIRECTORY=/anydeploy/tftp)


rm /etc/default/tftpd-hpa
touch /etc/default/tftpd-hpa
cat >"/etc/default/tftpd-hpa" << EOF
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/anydeploy/tftp"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="-s"
EOF


# Copy PXELINUX BIOS

mkdir /anydeploy/tftp/bios
cp /usr/lib/PXELINUX/pxelinux.0 /anydeploy/tftp/bios/
cp /usr/lib/syslinux/modules/bios/ldlinux.c32 /anydeploy/tftp/bios/

# Copy UEFI{32,64} Syslinux

#mkdir /anydeploy/tftp/{efi32,efi64}
#cp /usr/lib/SYSLINUX.EFI/efi32/syslinux.efi /anydeploy/tftp/efi32/syslinux32.efi
#cp /usr/lib/syslinux/modules/efi32/ldlinux.e32 /anydeploy/tftp/efi32/
#cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /anydeploy/tftp/efi64/syslinux.efi
#cp /usr/lib/syslinux/modules/efi64/ldlinux.e64 /anydeploy/tftp/efi64/


# Mkdir bios

mkdir /anydeploy/tftp/bios

#mkdir pxelinux.cfg

mkdir /anydeploy/tftp/bios/pxelinux.cfg

# Create Config File

touch /anydeploy/tftp/bios/pxelinux.cfg/default


# Add config

cat >"/anydeploy/tftp/bios/pxelinux.cfg/default" << EOF
default menu.c32
prompt 0
timeout 300 # 300 = 30 sec
ONTIMEOUT local

MENU TITLE anyDeploy Menu

LABEL anyDeploy
        MENU LABEL Anydeploy
        kernel images/pmagic/bzImage
        append noapic initrd=images/pmagic/initrd.gz root=/dev/ram0 init=/linuxrc ramdisk_size=100000
EOF



# Copy Libraries for BIOS

cp /usr/lib/syslinux/modules/bios/menu.c32 /anydeploy/tftp/bios/
cp /usr/lib/syslinux/modules/bios/libutil.c32 /anydeploy/tftp/bios/
cp /usr/lib/syslinux/modules/bios/libcom32.c32 /anydeploy/tftp/bios/
cp /usr/lib/syslinux/modules/bios/vesamenu.c32 /anydeploy/tftp/bios/


# Copy Libraries for EFI32

# TODO

# Copy Libraries for EFI64

# TODO



# Restart TFTPD

service tftpd-hpa restart

}


setup_tftp
