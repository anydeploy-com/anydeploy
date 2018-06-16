#!/bin/bash

disk_tempfile="/anydeploy/tmp/tempdisks.csv"
disk_tempfile_tab="/anydeploy/tmp/tempdisks_tab.tsv"

## Remove md* from filtering to enable intel Raid ? (test)
#export PHYSICALDISKS=($(grep -Hv ^1$ /sys/block/*/removable | grep -v "sys/block/ram*" | grep -v "sys/block/loop*" | grep -v "sys/block/td*" | grep -v "sys/block/dm*" | grep -v "sys/block/nbd*" | grep -v "/sys/block/md*" | cut -d / -f 4 | sed 's/!/\//'))


  # Reset to default - in case of re-run

    PHYSICALDISKS=()
    DISK_NUM=()
    DISK_SIZE=()
    DISK_SIZE_VAL=()
    DISK_SIZE_MEAS=()
    DISK_MODEL=()
    DISK_MODEL_FAMILY=()
    DISK_RPM=()
    DISK_SERIAL=()
    DISK_SMART=()
    DISK_IS_SSD=""

#new array from lsblk

PHYSICALDISKS=($(lsblk -d | grep "disk" | awk '{print $1}')) # Works also in Linux Containers / VM's
#echo ${arr[1]}

if [ ${#PHYSICALDISKS[@]} -eq 0 ]; then
    echo "No disks detected"
    sleep 5
else
  echo Physical Disk Devices found: ${#PHYSICALDISKS[@]}

  # give disk numbers in array (current num +1)
  #lsblk -d -o KNAME,MODEL,VENDOR,TYPE | grep -v "loop" | grep -v "rom" | grep -v "KNAME"


   for ((i=0; i < ${#PHYSICALDISKS[@]}; i++))
      do
  	DISK_NUM[$i]=$(( $i + 1 ))
  	DISK_SIZE[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "User Capacity" | cut -d "[" -f2 | cut -d "]" -f1 | xargs)
  	DISK_SIZE_VAL[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "User Capacity" | cut -d "[" -f2 | cut -d "]" -f1 | tr -dc '0-9' | xargs)
    DISK_SIZE_MEAS[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "User Capacity" | cut -d "[" -f2 | cut -d "]" -f1 |  tr -d '0-9' | xargs)
    DISK_MODEL[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "Device Model" | awk '{print $3,$4,$5,$6}' | xargs)
    DISK_MODEL_FAMILY[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "Model Family" | awk '{print $3,$4,$5,$6}')
    DISK_RPM[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "Rotation Rate" | awk '{print $3,$4,$5,$6}' | xargs)
    DISK_SERIAL[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "Serial Number" | awk '{print $3,$4,$5,$6}' | xargs)
    DISK_SMART[$i]=$(smartctl -a /dev/${PHYSICALDISKS[$i]} | grep "SMART overall-health self-assessment test result" | awk '{print $6}')
    DISK_IS_SSD[$i]=""
    #DISK_DIALOG[$i]=( "${PHYSICALDISKS[$i]}" "${DISK_MODEL[$i]}" )

  	# write seperate for LSI 3ware / Areca / HighPoint, HP CCISS, LSI MegaRAID, Intel Matrix/Rapid, Adaptec SAS


      done

fi
