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


          # Copy Kernel
          cp /nfs/any64/vmlinuz /anydeploy/tftp/bios/vmlinuz
          chmod 777 /anydeploy/tftp/bios/vmlinuz

          # Copy init
          cp /nfs/any64/initrd.img /anydeploy/tftp/bios/initrd.img
          chmod 777 /anydeploy/tftp/bios/vmlinuz

          # Add config

          cat >"/anydeploy/tftp/bios/pxelinux.cfg/default" << EOF
default menu.c32
prompt 0
timeout 50 # 50 = 5 sec
ONTIMEOUT anydeploy_debian

MENU TITLE anyDeploy Menu

label anydeploy_debian
kernel vmlinuz
append rw initrd=initrd.img root=/dev/nfs ip=dhcp nfsroot=192.168.1.254:/anydeploy/nfs/anynetlive_amd64
EOF

# SETUP EFI32

# TODO



# SETUP EFI64

          # Copy PXELINUX EFI64

          mkdir /anydeploy/tftp/efi
          cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /anydeploy/tftp/efi64/
          cp /usr/lib/syslinux/modules/efi64/ldlinux.e64 /anydeploy/tftp/efi64/


          #mkdir pxelinux.cfg

          mkdir /anydeploy/tftp/efi64/pxelinux.cfg

          # Create Config File

          touch /anydeploy/tftp/efi64/pxelinux.cfg/default


          # Copy Modules for EFI64

          cp /usr/lib/syslinux/modules/efi64/* /anydeploy/tftp/efi64/


          # Copy Kernel
          cp /nfs/anyd64/vmlinuz /anydeploy/tftp/efi64/vmlinuz
          chmod 777 /anydeploy/tftp/efi64/vmlinuz

          # Copy init
          cp /nfs/any64/initrd.img /anydeploy/tftp/efi64/initrd.img
          chmod 777 /anydeploy/tftp/efi64/vmlinuz


          # Add config

          cat >"/anydeploy/tftp/efi64/pxelinux.cfg/default" << EOF
default menu.c32
prompt 0
timeout 50 # 50 = 5 sec
ONTIMEOUT anydeploy_debian

MENU TITLE anyDeploy Menu

label anydeploy_debian
kernel vmlinuz
append rw initrd=initrd.img root=/dev/nfs ip=dhcp nfsroot=192.168.1.254:/anydeploy/nfs/anynetlive_amd64
EOF





# Restart TFTPD

service tftpd-hpa restart

}

# Copy Kernel and init




setup_tftp
