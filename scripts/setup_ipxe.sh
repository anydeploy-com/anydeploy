#!/bin/bash

setup_ipxe () {

echo "setup ipxe"


# Create sources dir + gitignore
mkdir /anydeploy/sources
touch /anydeploy/sources/.gitignore
echo "*" > "/anydeploy/sources/.gitignore"


# Clone ipxe

git clone git://git.ipxe.org/ipxe.git /anydeploy/sources/ipxe

# Install building deps

sudo apt-get install build-essential mtools perl make binutils liblzma-dev genisoimage syslinux -y


# go into ipxe folder

cd /anydeploy/sources/ipxe/src


touch demo.ipxe

cat >"demo.ipxe" << EOF
#!ipxe

dhcp
chain http://192.168.1.254/menu.ipxe
EOF


# build ipxe

make bin/undionly.kpxe EMBED=demo.ipxe
make bin-x86_64-efi/ipxe.efi EMBED=demo.ipxe

# verify if done succesfully

# TODO

# copy undionly file

cp /anydeploy/sources/ipxe/src/bin/undionly.kpxe /anydeploy/tftp/
cp /anydeploy/sources/ipxe/src/bin-x86_64-efi/ipxe.efi /anydeploy/tftp/

}

setup_ipxe
