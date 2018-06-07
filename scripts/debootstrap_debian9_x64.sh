#!/bin/bash

. /anydeploy/scripts/includes/functions.sh
. /anydeploy/settings/global.sh

anynet_amd64="/nfs/any64"

# Create NFS share dir
mkdir "/nfs"
# Create Dir for netboot anydeploy OS
mkdir "/nfs/any64"
# Add Working Dir variable


debootstrap --components=main,non-free --include=linux-image-amd64,openssh-server,nano,python,initramfs-tools,syslinux-common,firmware-linux,firmware-realtek,firmware-bnx2,firmware-atheros,firmware-iwlwifi,firmware-intelwimax,firmware-qlogic,firmware-netxen,locales \
stretch /nfs/any64 http://deb.debian.org/debian/

# Edit Fstab

cat >"${anynet_amd64}/etc/fstab" << EOF
proc /proc proc defaults 0 0
/dev/nfs / nfs defaults 1 1
none /tmp tmpfs defaults 0 0
none /run tmpfs defaults 0 0
#none /run/lock tmpfs defaults 0 0
none /var/tmp tmpfs defaults 0 0
EOF

# Edit init to boot from NFS

echo "BOOT=nfs" >> ${anynet_amd64}/etc/initramfs-tools/initramfs.conf

echo "setting up nfs"

apt-get install nfs-kernel-server nfs-common -y


touch /etc/exports
# TODO CHECK IF NOT EXISTS ALREADY
echo "/nfs/any64 *(rw,no_root_squash,async,insecure,no_subtree_check,fsid=1)" >> /etc/exports

exportfs -a
service nfs-kernel-server restart

cat >"${anynet_amd64}/fixlocales.sh" << EOF
# Fix Locales
    echo "LANGUAGE=en_GB.UTF-8" > /etc/default/locale
    echo "LANG=en_GB.UTF-8" >> /etc/default/locale
    echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    TZ='Europe/London'; export TZ
EOF

cat >"${anynet_amd64}/postinstall.sh" << EOF
# Setup Hostname

    echo "anylive_x64" > "/etc/hostname"
    hostnamectl set-hostname anylive64

# Fix Nameservers (resolv.conf)

    echo "nameserver 8.8.8.8" > "/etc/resolv.conf"
    echo "nameserver 8.8.4.4" >> "/etc/resolv.conf"
# Update OS
            apt update -y && apt upgrade -y

# Disable installation of recommended packages
                echo 'APT::Install-Recommends "false";' >"/etc/apt/apt.conf.d/50norecommends"

# Install Software

            apt install -y initramfs-tools

# Setup Password

            echo "root:anydeploy" | chpasswd


# Create User
  # TODO
# Add SSH KEY
  # TODO
EOF

# Enable Autologin (root)

startexec="-\/sbin\/agetty --skip-login --login-options \"-f root\" %I 38400 linux"
sed -i "/ExecStart=/ s/=.*/=${startexec}/" ${anynet_amd64}/lib/systemd/system/getty@.service


chmod +x ${anynet_amd64}/fixlocales.sh
chmod +x ${anynet_amd64}/postinstall.sh

LANG=C.UTF-8 chroot /nfs/any64 /bin/bash -c "./fixlocales.sh"
LANG=en_GB.UTF-8 chroot /nfs/any64 /bin/bash -c "./postinstall.sh"
LANG=en_GB.UTF-8 chroot /nfs/any64 /bin/bash -c "update-initramfs -u"

rm ${anynet_amd64}/fixlocales.sh
rm ${anynet_amd64}/postinstall.sh

cp ${anynet_amd64}/vmlinuz /anydeploy/www/
cp ${anynet_amd64}/initrd.img /anydeploy/www/
