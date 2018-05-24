#!/bin/bash


# Clear input
#exec /usr/bin/fbterm "$@"
clear

# Basic installer functions

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

          function install_font {

            # /lib/systemd/system/getty@.service
            # cp /lib/systemd/system/getty@.service /anydeploy/

            # Show fonts

            #showconsolefont

            # Install font apt
            apt install -y xfonts-terminus
            # Setup as main font
            #apt install fbterm
            #/etc/default/console-setup

            #List of all fonts
            #ls /usr/share/consolefonts/

            #Add /root/.bash_profile

            #dpkg-reconfigure console-setup

#          #
#          # ~/.bash_profile
#          #
#
#          [[ -f ~/.bashrc ]] && . ~/.bashrc
#          fbterm --font-size 18
#
          }

          function check_root {

          # Detect if run as root and do so if not

          if [[ $EUID -ne 0 ]]; then
             echo_fail " * - This script must be run as root"
             exit 1
          else
            echo_pass " * - Running as root / sudo"
          fi
          }

          function check_log {
            # if log exists then rename to current date one
          echo "checking if log file exists"
            #bash script.sh > "/var/log/$(date +%Y-%m-%d_%H:%M).log"
          }



          function os_update {
          echo_warn "Updating OS"
          apt update -y
          }

          function os_upgrade {
          echo_warn "Upgrading OS"
          apt upgrade -y
          }

          function install_git {
          echo_warn "Installing git"
          apt install -y git

          sleep 5
          # Verify if git installed successfully or cancel
        }

          function clone_testing_repo {
          echo_warn "cloning testing repo"
          # Check if /anydeploy exists

          # Doesn't exist - clone
          git clone https://github.com/anydeploy-com/anydeploy /anydeploy

          # Exists - prompt to replace / update

          }

          function check_deps

          # Define dependencies and verify them
          {
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

          # Verify Internet connection

          function check_network {

          echo_warn "Verifying if internet connection exists"

          if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
            echo_pass "Internet Is connected"
          else
            echo "Your internet connection is down - exiting"
            exit 1
          fi

          }

          function update_upgrade_os {

          # Prompt for update and upgrade
          read -p " * - Do you want to update your operating system first - recommended (Y/n)? " choice
          case "$choice" in
            y|Y )
            echo_warn "OS Update chosen - updating"
            os_update
            sleep 5
            os_upgrade
            sleep 5
            ;;
            n|N )
            echo_warn "Skipping upgrades - updating packages list only"
            os_update
            sleep 5
            ;;
            * )
            echo "invalid";;
          esac
          }


          function git_postclone {
            # Include functions
            . /anydeploy/settings/functions.sh

            # Include global config
            . /anydeploy/settings/global.sh

            # Add gitignore files

          touch /anydeploy/iso/.gitignore

          echo "*.iso" >> /anydeploy/iso/.gitignore

          touch /anydeploy/tmp/.gitignore

          echo "*" >> /anydeploy/tmp/.gitignore

          # Single file installer  will go here.

          # Setup Folders

          if [ ! -d "/anydeploy/tmp/mount" ]; then
          echo_warn "Directory tmp/mount DOES NOT exists, creating."
          mkdir /anydeploy/tmp/mount
          fi

          if [ ! -d "/anydeploy/tmp/extracted" ]; then
          echo_warn "Directory tmp/extracted DOES NOT exists, creating."
          mkdir /anydeploy/tmp/extracted
          fi
          }

          function debootstrap_debian9_x64 {
            . scripts/debootstrap_debian9_x64.sh
          }

          function debootstrap_debian9_x64_postinstall {
          . scripts/debootstrap_debian9_x64_postinstall.sh
          }

          function install_dhcp_package {
          apt install -y isc-dhcp-server
          }

          function install_dhcp_selectinterface {
            . scripts/dhcp_select_interface.sh
          }


# Prompt for OS update / upgrade

      update_upgrade_os & sleep 5

# Install Git

      install_git & sleep 5

# Verify Git

      check_deps git & sleep 5

# Clone repository

      clone_testing_repo & sleep 5

# Git Postclone function

      git_postclone

# Declare dependencies

      deps=( dialog debootstrap sudo dmidecode lspci cups net-tools )

# Check dependencies

      check_deps

# Setup user, user variables

      # TODO - for system + live (chroot)


# Install DHCP Server
      # TODO ADD PROMPT to install or use dnsmasq

      install_dhcp_selectinterface


# Create Anylive 64 bit environment

      debootstrap_debian9_x64

# Configure Anylive 64 bit environment

      debootstrap_debian9_x64_postinstall

# Fix permissions

# Download virtio iso


# TODO check if virtio-win.iso exists

# https://fedoraproject.org/wiki/Windows_Virtio_Drivers#Direct_download

      #cd iso
      #wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso --show-progress
      #cd ..

# Download dependencies



# Compile iPXE

# Install CUPS Print Server

# Install TFTP Server

# Inatall IPXE

# Install DHCP / Explain how to setup dhcp + install netboot part

# Install LEMP Stack
