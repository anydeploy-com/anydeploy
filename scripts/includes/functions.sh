#!/bin/bash

##############################################################################
#                            Formatting Functions                            #
##############################################################################

  # TODO if available = optional special characters: ✔/▰/✘


function echo_pass() {
echo "$(tput setaf 2) V$(tput sgr0) - $1"
}

function echo_warn() {
echo "$(tput setaf 3) ~$(tput sgr0) - $1"
}

function echo_fail() {
echo >&2 "$(tput setaf 1) X$(tput sgr0) - $1"
}



function _spinner() {

  # Author: Tasos Latsas

    # $1 start/stop
    #
    # on start: $2 display message
    # on stop : $2 process exit status
    #           $3 spinner function pid (supplied from stop_spinner)

    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"

    case $1 in
        start)
            # calculate the column where spinner and status msg will be displayed
            let column=$(tput cols)-${#2}-8
            # display message and position the cursor in $column column
            echo -ne ${2}
            printf "%${column}s"

            # start spinner
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}

            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi

            kill $3 > /dev/null 2>&1

            # inform the user uppon success or failure
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}

function start_spinner {
    # $1 : msg to display
    _spinner "start" "${1}" &
    # set global spinner pid
    _sp_pid=$!
    disown
}

function stop_spinner {
    # $1 : command exit status
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid1>&2;
}

##############################################################################
#                            Enhanced Exec                                   #
##############################################################################

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

##############################################################################
#                            Dependency Checking                             #
##############################################################################

function check_deps
# Define dependencies and verify them
{
# Update packages list first
echo "updating with apt-get" > /anydeploy/logs/log.txt
apt-get update &>> /anydeploy/logs/log.txt
for i in "${deps[@]}"
do
dpkg_status=$(dpkg -l 2>/dev/null $i | grep $i | awk '{print $1}')
dpkg_query=$(dpkg -l 2>/dev/null $i | grep $i | awk '{print $2}')
dpkg_version=$(dpkg -l 2>/dev/null $i | grep $i | awk '{print $3}')
if [ "$dpkg_query" = ${i} ] || [ "$dpkg_query" = ${i}:amd64 ] ; then
            if [ "${dpkg_status}" != "ii" ]; then
                    #echo_warn "Dependency $i is not installed"
                      if [ ${autoinstall_deps} = "Y" ] || [ ${autoinstall_deps} = "y" ] ; then
                          start_spinner "Installing $i"
                          apt-get install -y $i &>> /anydeploy/logs/log.txt
                          sleep 0.3
                          stop_spinner $?
                      else
                        	read -p " Do you want me to install $i (y/n)? " CONT
                            	if [ "$CONT" = "y" ]; then
                            	apt-get install -y $i &>> /anydeploy/logs/log.txt
                              else
                            	echo_fail "Cancelled script due to depencency missing ($i)";
                            	exit 1
                            	fi
                      fi
            else
              start_spinner "Dependency $i is installed - version: ${dpkg_version}"
              echo "Dependency $i is installed - version: ${dpkg_version}" >> /anydeploy/logs/log.txt
              sleep 0.3
              stop_spinner $?
            fi
else
    if [ ${autoinstall_deps} = "Y" ] || [ ${autoinstall_deps} = "y" ] ; then
        start_spinner "Installing $i"
        apt-get install -y $i &>> /anydeploy/logs/log.txt
        sleep 0.3
        stop_spinner $?
    else
        read -p " Do you want me to install $i (y/n)? " CONT
            if [ "$CONT" = "y" ]; then
            apt-get install -y $i &>> /anydeploy/logs/log.txt
            else
            echo_fail "Cancelled script due to depencency missing ($i)";
            exit 1
            fi
    fi
fi
done
}

##############################################################################
#                            Other Functions                                 #
##############################################################################

function check_network {

  start_spinner "Verifying if internet connection exists"
      sleep 1
      ping -q -c 1 -W 1 8.8.8.8 > /dev/null 2>&1
  stop_spinner $?

}


function update_upgrade_os {

# Prompt for update and upgrade

case "${update_upgrade}" in
  y|Y )
    start_spinner "Updating Packages (apt update)"
    apt-get update -y > /dev/null 2>&1
    stop_spinner $?
    sleep 1
    start_spinner "Upgrading Packages (apt upgrade)"
    apt-get upgrade -y > /dev/null 2>&1
    stop_spinner $?
    sleep 1
  ;;
  n|N )
    start_spinner "Skipping upgrades - updating packages list only"
    apt-get upgrade -y > /dev/null 2>&1
    sleep 1
    stop_spinner $?
  ;;
  * )
  echo "invalid";;
esac
}



function remove_interface {

# Define interface to remove variable (from input)
iface_to_remove=$1
echo "iface to remove = ${iface_to_remove}"

# Detect if there are any bridges setup on selected interface

iface_to_remove_bridge=$(brctl show | grep "$1" | awk '{print $1}')


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



##############################################################################
#                        Autorun - Detect Client Type                        #
##############################################################################

# Detect if client or server

  if [ ! -z "$(mount | grep "on / " | grep "nfs")" ]; then
  devtype="client"
  else
  devtype="server"
  fi

  ip_address_dialog=$(ifconfig | grep "inet " | grep -v "127.0.0.1" | grep -v "169*" | awk '{print $2}' | xargs)
