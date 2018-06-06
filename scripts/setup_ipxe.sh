#!/bin/bash

setup_ipxe () {

echo "setup ipxe"


# Create sources dir
mkdir /anydeploy/sources



# Clone ipxe
touch /anydeploy/sources/.gitignore
echo "*" > "/anydeploy/sources/.gitignore"

git clone git://git.ipxe.org/ipxe.git /anydeploy/sources/ipxe

# Install building deps


}

setup_ipxe
