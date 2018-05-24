#!/bin/bash


function os_update {
  # GET CURRENT REPOS LIST
#grep -h ^deb /etc/apt/sources.list /etc/apt/sources.list.d/* >> /anydeploy/tmp/current.repos.list


echo_warn "Updating OS"
apt update -y
}

dialog --title "OS Packages Update" \
--backtitle "anydeploy Installer - Step 1 of 15" \
--yesno "Do you want to update your system packages first? \nThis is equivalent of running apt update \n Recommended" 7 60

# Get exit status
# 0 means user hit [yes] button.
# 1 means user hit [no] button.
# 255 means user hit [Esc] key.
response=$?
case $response in
   0) os_update;;
   1) echo "Skipped OS Update.";;
   255) echo "[ESC] key pressed.";;
esac
