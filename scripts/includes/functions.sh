#!/bin/bash

# Formatting functions
# special characters: ✔/▰/✘

function echo_pass {
echo "$(tput setaf 2) ✔$(tput sgr0) - $1"
}

function echo_warn {
echo "$(tput setaf 3) ▰$(tput sgr0) - $1"
}

function echo_fail {
echo "$(tput setaf 1) ✘$(tput sgr0) - $1"
}

# Enchanced exec

function logexec {
$1 &>> log.txt
}

function check_root {

# Detect if run as root and do so if not

if [[ $EUID -ne 0 ]]; then
   echo_fail "This script must be run as root"
   exit 1
else
  echo_pass "Running as root / sudo"
fi
}



function check_deps
# Define dependencies and verify them
{
# Update packages list first
echo "updating with apt-get" > /anydeploy/logs/log.txt
apt-get update &>> /anydeploy/logs/log.txt
for i in "${deps[@]}"
do
dpkg_query=$(dpkg -l 2>/dev/null $i | grep $i | awk '{print $2}' )
dpkg_version=$(dpkg -l 2>/dev/null $i | grep $i | awk '{print $3}')
if [ "$dpkg_query" = $i ]; then
echo_pass "Dependency $i is installed - version: ${dpkg_version}"
echo "Dependency $i is installed - version: ${dpkg_version}" >> /anydeploy/logs/log.txt
else
echo_warn "Dependency $i is not installed"
	read -p " Do you want me to install $i (y/n)? " CONT
	if [ "$CONT" = "y" ]; then
	echo_warn "Installing $i";
	apt install $i &>> /anydeploy/logs/log.txt
	else
	echo_fail "Cancelled script due to depencency missing ($i)";
	exit 1
	fi
fi
done
}

function remove_interface {

# Define interface to remove variable (from input)
iface_to_remove=${1}
echo "iface to remove = ${iface_to_remove}"

# Detect if there are any bridges setup on selected interface

iface_to_remove_bridge=$(brctl show | grep "${1}" | awk '{print $1}')


# If exists - remove selected interface bridges from /etc/network/interfaces
if [ ! -z "${iface_to_remove_bridge}" ] ; then
echo "iface to remove bridge found - removing ${iface_to_remove_bridge}"
sed -i "/${iface_to_remove_bridge}/,/^$/d" /etc/network/interfaces
else
echo "no bridge found"
fi

# Removes selected interface from /etc/network/interfaces
echo "removing interface ${iface_to_remove}"
sed -i "/${iface_to_remove}/,/^$/d" /etc/network/interfaces

}


function check_dirs {
echo "TODO"
  }


# Detect if client or server
  rootmount_type_nfs=$(mount | grep "on / " | grep "nfs")

  if [ ! -z "${rootmount_type_nfs}" ]; then
  devtype="client"
  else
  devtype="server"
  fi
