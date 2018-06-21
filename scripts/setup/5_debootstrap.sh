#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions

##############################################################################
#                          Define Folders to use                             #
##############################################################################

start_spinner "Preparing AnyLive amd64"

# Create NFS share dir

if [ ! -d "/nfs" ]; then
mkdir "/nfs"
fi
# Create Dir for netboot anydeploy OS
if [ ! -d "/nfs/any64" ]; then
mkdir "/nfs/any64"
fi
# Add Working Dir variable

sleep 2
stop_spinner $?


##############################################################################
#                          Debootstrap                                       #
##############################################################################


function debootstrap_debian_amd64 () {
start_spinner 'AnyLive amd64 - Debootstapping Debian amd64'

debootstrap --components=main,non-free --include=linux-image-amd64,openssh-server,nano,python,initramfs-tools,syslinux-common,firmware-linux,firmware-realtek,firmware-bnx2,firmware-atheros,firmware-iwlwifi,firmware-intelwimax,firmware-qlogic,firmware-netxen,locales \
stretch /nfs/any64 http://deb.debian.org/debian/ > /dev/null

stop_spinner $?
}

function debootstrap_debian_amd64_postconfigure () {

# FOR SAFETY RUN SCRIPT ONLY IF $anynet_amd64 directory exits TO AVOID OVERWRITING /etc/fstab in your system and other stuff

start_spinner 'Creating Fstab'
sleep 0.5
cat >${anynet_amd64}/etc/fstab <<EOF
proc /proc proc defaults 0 0
/dev/nfs / nfs defaults 1 1
none /tmp tmpfs defaults 0 0
none /run tmpfs defaults 0 0
#none /run/lock tmpfs defaults 0 0
none /var/tmp tmpfs defaults 0 0
EOF
sleep 0.5
stop_spinner $?
# Edit init to boot from NFS

start_spinner "Editing initrfamfs"
sleep 0.5
echo "BOOT=nfs" >> ${anynet_amd64}/etc/initramfs-tools/initramfs.conf
sleep 0.5
stop_spinner $?


touch ${anynet_amd64}/fixlocales.sh
touch ${anynet_amd64}/postinstall.sh

start_spinner 'AnyLive amd64 Postinstall - Generating locales'
sleep 0.5
cat >"${anynet_amd64}/fixlocales.sh" <<EOF
# Fix Locales
    echo "LANGUAGE=en_GB.UTF-8" > /etc/default/locale
    echo "LANG=en_GB.UTF-8" >> /etc/default/locale
    echo "en_GB.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    TZ='Europe/London'; export TZ
EOFAdding postinstall
sleep 0.5
stop_spinner $?

start_spinner 'AnyLive amd64 Postinstall - Configuring Keyboard'
sleep 0.5
# Setup Keyboard Layout
cat >"${anynet_amd64}/etc/default/keyboard" <<EOF
# KEYBOARD CONFIGURATION FILE
# Consult the keyboard(5) manual page.
XKBMODEL="pc105"
XKBLAYOUT="gb"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
sleep 0.5
EOF
stop_spinner $?

start_spinner 'AnyLive amd64 Postinstall - Adding postinstall Script'
sleep 0.5
cat >"${anynet_amd64}/postinstall.sh" <<EOF
# Setup Hostname
    echo "anylive_x64" > "/etc/hostname"
    hostnamectl set-hostname anylive64
# Fix Nameservers (resolv.conf)
    echo "nameserver 8.8.8.8" > "/etc/resolv.conf"
    echo "nameserver 8.8.4.4" >> "/etc/resolv.conf"
# Update OS
            apt-get update -y && apt-get upgrade -y
# Disable installation of recommended packages
              #  echo 'APT::Install-Recommends "false";' >"/etc/apt/apt.conf.d/50norecommends"
# Install Software
            apt-get install -y initramfs-tools
# Setup Password
            echo "root:anydeploy" | chpasswd
# Create User
  # TODO
# Add SSH KEY
  # TODO
# Install Apps

DEBIAN_FRONTEND=noninteractive apt-get install -y git dialog net-tools partclone nfs-common smartmontools less pciutils usbutils gdisk keyboard-configuration console-setup

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
sleep 0.5
stop_spinner $?

start_spinner 'AnyLive amd64 Postinstall - Enabling Autologin'
sleep 0.5
# Enable Autologin (root)
startexec="-\/sbin\/agetty --skip-login --login-options \"-f root\" %I 38400 linux"
sed -i "/ExecStart=/ s/=.*/=${startexec}/" ${anynet_amd64}/lib/systemd/system/getty@.service
sleep 0.5
stop_spinner $?

chmod +x ${anynet_amd64}/fixlocales.sh
chmod +x ${anynet_amd64}/postinstall.sh

start_spinner 'AnyLive amd64 Postinstall - Running Locales Fix'
LANG=C.UTF-8 chroot /nfs/any64 /bin/bash -c "./fixlocales.sh" >/dev/null 2>&1
stop_spinner $?
start_spinner 'AnyLive amd64 Postinstall - Running Postinstall Script'
LANG=en_GB.UTF-8 chroot /nfs/any64 /bin/bash -c "./postinstall.sh" >/dev/null 2>&1
stop_spinner $?
start_spinner 'AnyLive amd64 Postinstall - Updating Initramfs'
LANG=en_GB.UTF-8 chroot /nfs/any64 /bin/bash -c "update-initramfs -u" >/dev/null 2>&1
stop_spinner $?
start_spinner 'AnyLive amd64 Postinstall - Cleaning up'
rm ${anynet_amd64}/fixlocales.sh
rm ${anynet_amd64}/postinstall.sh
stop_spinner $?

}



debootstrap_debian_amd64

if [ -d "$anynet_amd64" ]; then
debootstrap_debian_amd64_postconfigure
else
echo "anynet directory not defined"
exit 1
fi
