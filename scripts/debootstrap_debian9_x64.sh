#!/bin/bash

# Include Functions + Global Conf
. /anydeploy/scripts/includes/functions.sh
. /anydeploy/global.conf

# Define folders
    nfs_dir="/nfs"
    anynet_x86="/nfs/any"
    anynet_amd64="/nfs/any64"

# Check Deps
    deps=(debootstrap nfs-kernel-server nfs-common)
    check_deps

# Checking if anynet already exists"
    if [ -d "${anynet_amd64}" ]; then
      echo "anydeploy amd64 already exists"
      # TODO prompt what to do
    else
      echo "anydeploy amd64 doesnt exist, continuing"
    fi

# Create NFS share dir
mkdir "/nfs"
# Create Dir for netboot anydeploy OS
mkdir "/nfs/any64"
# Add Working Dir variable

start_spinner 'Deboostrapping Debian 9'
sleep 2
stop_spinner $?

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


touch /etc/exports

any64_export=$(grep "/nfs/any64" /etc/exports)

if [ ! -z "${any64_export}" ] ; then
echo "/etc/exports already contains entry for any64, skipping"
else
echo "/nfs/any64 *(rw,no_root_squash,async,insecure,no_subtree_check)" >> /etc/exports
fi

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

# Setup Keyboard Layout

cat >"${anynet_amd64}/etc/default/keyboard" << EOF
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="gb"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"
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
              #  echo 'APT::Install-Recommends "false";' >"/etc/apt/apt.conf.d/50norecommends"

# Install Software

            apt install -y initramfs-tools

# Setup Password

            echo "root:anydeploy" | chpasswd


# Create User
  # TODO
# Add SSH KEY
  # TODO

# Install Git
apt-get install git -y

# Install dialog
apt-get install dialog -y

# Install net-tools

apt-get install net-tools -y

# Install Partclone

apt-get install partclone -y

# Install NFS common

apt-get install nfs-common -y

# Install Smart Mon Tools

apt-get install smartmontools -y

# Install less

apt-get install less -y

# Install lspci, lsusb

apt-get install pciutils usbutils -y

# Install ntfs-3g

apt-get install ntfs-3g -y


# Install gdisk

apt-get install gdisk -y

# Install console-setup + keyboard config

DEBIAN_FRONTEND=noninteractive apt-get install keyboard-configuration console-setup -y

# Permit Root Login over ssh (temporary)

echo "PermitRootLogin yes" >> "/etc/ssh/sshd_config"


# Enable autorun
echo "sleep 2" >> /root/.bashrc
echo "cd /anydeploy" >> /root/.bashrc
echo "./index.sh" >> /root/.bashrc


# Setup Keyboard

dpkg-reconfigure --frontend=noninteractive keyboard-configuration
dpkg-reconfigure --frontend=noninteractive console-setup

# Mount NFS exports (fstab)

mkdir /nfs
mkdir /anydeploy



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


mkdir ${anynet_amd64}/anydeploy
check)" >> /etc/exports
fi

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

# Setup Keyboard Layout

cat >"${anynet_amd64}/etc/default/keyboard" << EOF
# KEYBOARD CONFIGURATION FILE

# Consult the keyboard(5) manual page.

XKBMODEL="pc105"
XKBLAYOUT="gb"
XKBVARIANT=""
XKBOPTIONS=""

BACKSPACE="guess"
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
              #  echo 'APT::Install-Recommends "false";' >"/etc/apt/apt.conf.d/50norecommends"

# Install Software

            apt install -y initramfs-tools

# Setup Password

            echo "root:anydeploy" | chpasswd


# Create User
  # TODO
# Add SSH KEY
  # TODO

# Install Git
apt-get install git -y

# Install dialog
apt-get install dialog -y

# Install net-tools

apt-get install net-tools -y

# Install Partclone

apt-get install partclone -y

# Install NFS common

apt-get install nfs-common -y

# Install Smart Mon Tools

apt-get install smartmontools -y

# Install less

apt-get install less -y

# Install lspci, lsusb

apt-get install pciutils usbutils -y


# Install gdisk

apt-get install gdisk -y

# Install console-setup + keyboard config

DEBIAN_FRONTEND=noninteractive apt-get install keyboard-configuration console-setup -y

# Permit Root Login over ssh (temporary)

echo "PermitRootLogin yes" >> "/etc/ssh/sshd_config"


# Enable autorun
echo "sleep 2" >> /root/.bashrc
echo "cd /anydeploy" >> /root/.bashrc
echo "./index.sh" >> /root/.bashrc


# Setup Keyboard

dpkg-reconfigure --frontend=noninteractive keyboard-configuration
dpkg-reconfigure --frontend=noninteractive console-setup

# Mount NFS exports (fstab)

mkdir /nfs
mkdir /nfs/images
mkdir /anydeploy

echo "192.168.1.254:/anydeploy /anydeploy  nfs defaults  0 0" >> /etc/fstab
echo "192.168.1.254:/nfs/images /nfs/images   nfs defaults  0 0" >> /etc/fstab




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


mkdir ${anynet_amd64}/anydeploy
