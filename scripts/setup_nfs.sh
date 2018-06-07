#!/bin/bash

. /anydeploy/includes/functions.sh
. /anydeploy/settings/global.sh

setup_nfs () {
echo "setting up nfs"

apt-get install nfs-kernel-server nfs-common -y
}

touch /etc/exports
echo "/nfs/any64 *(rw,no_root_squash,async,insecure,no_subtree_check,fsid=1)" >> /etc/exports

exportfs -a
service nfs-kernel-server restart

setup_nfs
