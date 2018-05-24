# Create NFS share dir
mkdir "/anydeploy/nfs"
# Add gitignore file to nfs dir
touch /anydeploy/nfs/.gitignore
# git ignore anything within /nfs Folder
echo "*" >> /anydeploy/nfs/.gitignore
# Create Dir for netboot anydeploy OS
mkdir "/anydeploy/nfs/anynetlive_amd64"
# Add Working Dir variable
export ANYNET_DIR="/anydeploy/nfs/anynetlive_amd64"
# Remove temp dir when finished
#trap 'rm -rf "${WORK_DIR}"' EXIT

# Debootstrap Debian + Non free + Drivers
# https://packages.debian.org/source/jessie/firmware-nonfree

# Firmware List

# firmware-linux
# firmware-realtek
# firmware-bnx2
# firmware-atheros
# firmware-iwlwifi
# firmware-ipw2x00 - Require license agreement agree (interactive question)
# firmware-intelwimax
# firmware-qlogic
# firmware-ralink - Not required - included in nonfree misc
# firmware-netxen

debootstrap --components=main,non-free --include=linux-image-amd64,openssh-server,nano,python,initramfs-tools,syslinux-common,firmware-linux,firmware-realtek,firmware-bnx2,firmware-atheros,firmware-iwlwifi,firmware-intelwimax,firmware-qlogic,firmware-netxen \
stretch ${ANYNET_DIR} http://deb.debian.org/debian/
