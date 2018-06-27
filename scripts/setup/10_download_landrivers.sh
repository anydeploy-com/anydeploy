#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions

##############################################################################
#                            Download Snappy Driver FULL                     #
##############################################################################

#read -p " * - Do you want to download Snappy Driver Origin (might take long time) ? (y/n)? " snappy_driver
#if [ ${snappy_driver} = "Y" ] || [ ${snappy_driver} = "y" ]; then

# Download Full Snappy Driver

#    if [ ! -d /nfs/drivers ]; then
#      mkdir /nfs/drivers
#    fi
#    cd /nfs/drivers
#    aria2c https://snappy-driver-installer.org/downloads/SDIO_Update.torrent

# Download Network Drivers ( SamDrivers)

#mkdir /nfs/tmp
#cd /nfs/tmp
#aria2c --seed-time=0 http://driveroff.net/SamDrivers_18.6_LAN.torrent
#7z x SamDrivers_18.6_LAN.7z
#mkdir /nfs/landrivers
#cp drivers/* /nfs/landrivers
#cd /nfs/landrivers
#rm -rf /nfs/tmp
#rm DP_WLAN-WiFi*
  #Extract all
#for archive in *.7z; do 7z x -o"`basename \"$archive\" .7z`" "$archive"; done
#rm *.7z


# Exceptions Naming -

    #Allx86
    #Allx64
    #WinAll
    #All81x86x64
    #All10x86x64
    #All7x86x64

  # Create Array of needed drivers

SAVEIFS=$IFS

# Change IFS for proper device names (contain spaces)
IFS=$'\n'

driver_array_w7=($(find /nfs/landrivers/ -type d -name "*7x64*"))
driver_array_w7+=($(find /nfs/landrivers/ -type d -name "*All7x86x64*"))
driver_array_w7+=($(find /nfs/landrivers/ -type d -name "*WinAll*"))
driver_array_w7+=($(find /nfs/landrivers/ -type d -name "*Allx64*"))

# Fix back IFS
IFS=$SAVEIFS

#echo ${driver_array_w7[3]}

echo "amount of driver folders to copy: ${#driver_array_w7[@]}"
if [ ! -d "/nfs/win7_x64_drivers" ]; then
   mkdir /nfs/win7_x64_drivers
 fi


echo "copying windows 7 x64 lan drivers only"

for i in ${!driver_array_w7[@]}; do

driverpath_destination+=($(echo ${driver_array_w7[$i]} | sed "s/\/nfs\/landrivers/ /"))
#echo "${driver_array_w7[${i}]} to /nfs/win7_x64_drivers${driverpath_destination[${i}]}"
mkdir -p "/nfs/win7_x64_drivers"${driverpath_destination[$i]}
#echo ${driver_array_w7[$i]}/* ${driverpath_destination[$i]}/
cp -R ${driver_array_w7[$i]} "/nfs/win7_x64_drivers"${driverpath_destination[$i]}
done
#echo "driverpath destination"





# Win10x86
# find /nfs/landrivers/ -type d -name "*10x86*"

# Win10x64
# find /nfs/landrivers/ -type d -name "*10x64*"
