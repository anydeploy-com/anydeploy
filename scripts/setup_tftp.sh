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

# SETUP BIOS

          # Copy PXELINUX BIOS

          mkdir /anydeploy/tftp/bios
          cp /usr/lib/PXELINUX/pxelinux.0 /anydeploy/tftp/bios/
          cp /usr/lib/syslinux/modules/bios/ldlinux.c32 /anydeploy/tftp/bios/

          # Mkdir bios

          mkdir /anydeploy/tftp/bios

          #mkdir pxelinux.cfg

          mkdir /anydeploy/tftp/bios/pxelinux.cfg

          # Create Config File

          touch /anydeploy/tftp/bios/pxelinux.cfg/default


          # Copy Libraries for BIOS

          cp /usr/lib/syslinux/modules/bios/menu.c32 /anydeploy/tftp/bios/
          cp /usr/lib/syslinux/modules/bios/libutil.c32 /anydeploy/tftp/bios/
          cp /usr/lib/syslinux/modules/bios/libcom32.c32 /anydeploy/tftp/bios/
          cp /usr/lib/syslinux/modules/bios/vesamenu.c32 /anydeploy/tftp/bios/


# SETUP EFI32

# TODO



# SETUP EFI64

# TODO






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


# Restart TFTPD

service tftpd-hpa restart

}


setup_tftp
