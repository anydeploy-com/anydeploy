#!/bin/bash

function echo_pass {
echo "$(tput setaf 2) ✔$(tput sgr0) - $1"
}

function echo_warn {
echo "$(tput setaf 3) ▰$(tput sgr0) - $1"
}

function echo_fail {
echo "$(tput setaf 1) ✘$(tput sgr0) - $1"
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

deps=(git sudo)

check_deps
