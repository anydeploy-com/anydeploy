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



function check_deps {
for i in "${deps[@]}"
do
if which $i >/dev/null; then
echo_pass "Dependency $i is installed"
elif which cupsd >/dev/null; then # cups exception
echo_pass "Dependency $i is installed" # cups exception
elif which netstat >/dev/null; then
echo_pass "Dependency $i is installed" # netstat exception
elif which ifconfig >/dev/null; then
echo_pass "Dependency $i is installed" # ifconfig exception
else
echo_warn "Dependency $i is not installed"
  read -p " Do you want me to install $i (y/n)? " CONT
  if [ "$CONT" = "y" ]; then
  echo_warn "Installing $i";
  apt-update &>> log.txt
  apt install $i &>> log.txt
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
