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
            if [ "$dpkg_version" = "<none>" ]; then
                    echo_warn "Dependency $i is not installed"
                    	read -p " Do you want me to install $i (y/n)? " CONT
                    	if [ "$CONT" = "y" ]; then
                    	echo_warn "Installing $i";
                    	apt install $i &>> /anydeploy/logs/log.txt
                    	else
                    	echo_fail "Cancelled script due to depencency missing ($i)";
                    	exit 1
                    	fi
            else
              echo_pass "Dependency $i is installed - version: ${dpkg_version}"
              echo "Dependency $i is installed - version: ${dpkg_version}" >> /anydeploy/logs/log.txt
            fi
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


  # Author: Tasos Latsas

  # spinner.sh
  #
  # Display an awesome 'spinner' while running your long shell commands
  #
  # Do *NOT* call _spinner function directly.
  # Use {start,stop}_spinner wrapper functions

  # usage:
  #   1. source this script in your's
  #   2. start the spinner:
  #       start_spinner [display-message-here]
  #   3. run your command
  #   4. stop the spinner:
  #       stop_spinner [your command's exit status]
  #
  # Also see: test.sh

  function _spinner() {
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
      unset _sp_pid
  }


# Detect if client or server
  rootmount_type_nfs=$(mount | grep "on / " | grep "nfs")

  if [ ! -z "${rootmount_type_nfs}" ]; then
  devtype="client"
  else
  devtype="server"
  fi
