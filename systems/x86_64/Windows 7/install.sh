#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  # Go to script path
  MY_PATH="`dirname \"$0\"`"
  cd "${MY_PATH}"

  source ../../../global.conf                           # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions



##############################################################################
#                       Usage Warning if no path specified                   #
##############################################################################

# TODO

##############################################################################
#                         Virtual Machine Settings                           #
##############################################################################

vm_isopath=$1
vm_name=Windows7_x64
vm_ramamount=
vm_mem_model=
vm_useballoon=
vm_disk_bus=
vm_disksize=32G
vm_netmodel=
vm_bridgename=
vm_accelerate=
vm_uefi=#dialog
vm_capture_resize="yes"


echo "vm_isopath=$vm_isopath"

##############################################################################
#                         Generate Install Tasks                             #
##############################################################################

# Generate ID (used to identify os after deployment done and call deployment_done.sh)
# task_id=$(echo $$)
# get TTY of current window and save as parameter to show parclone output on it
# server_tty=$(tty)


# items to be passed to deployment script

# task_id
# server_tty
# image_path









##############################################################################
#                            Create VM LibVirt                               #
##############################################################################

echo "running windows 7 amd 64 installer"

# Create Raw Image
rm -rf /var/lib/libvirt/images/test.img

dd if=/dev/zero of=/var/lib/libvirt/images/test.img bs=1 count=0 seek=30G

# Format as GPT if UEFI


# Create QCOW2 Image

#qemu-img create -f qcow2 /var/lib/libvirt/images/win10home_mbr$$.qcow2 30G

# Add VM to Libvirt

virt-install \
--name "${vm_name}" \
--ram=2048 \
--memory 2048,maxmemory=4096 \
--memballoon model=virtio \
--disk ${vm_isopath},device=cdrom --check path_in_use=off \
--disk "/var/lib/libvirt/images/test.img",format=raw,bus=sata,cache=none \
--network=bridge:anybr0,model=e1000 \
--events "on_poweroff=preserve" \
--os-variant "win7" \
--vcpus 2 \
--accelerate --noapic &
