#!/bin/bash

disk_tempfile="/anydeploy/tmp/tempdisks.csv"
disk_tempfile_tab="/anydeploy/tmp/tempdisks_tab.tsv"

## Remove md* from filtering to enable intel Raid ? (test)
#export PHYSICALDISKS=($(grep -Hv ^1$ /sys/block/*/removable | grep -v "sys/block/ram*" | grep -v "sys/block/loop*" | grep -v "sys/block/td*" | grep -v "sys/block/dm*" | grep -v "sys/block/nbd*" | grep -v "/sys/block/md*" | cut -d / -f 4 | sed 's/!/\//'))


#new array from lsblk

PHYSICALDISKS=($(lsblk -d | grep "disk" | awk '{print $1}')) # Works also in Linux Containers / VM's
#echo ${arr[1]}

echo Physical Disk Devices found: ${#PHYSICALDISKS[@]}

# give disk numbers in array (current num +1)
#lsblk -d -o KNAME,MODEL,VENDOR,TYPE | grep -v "loop" | grep -v "rom" | grep -v "KNAME"


 for ((i=0; i < ${#PHYSICALDISKS[@]}; i++))
    do
		DISK_NUM[$i]=$(( $i + 1 ))
    echo "1"
		DISK_SIZE[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "User Capacity" | cut -d "[" -f2 | cut -d "]" -f1 | xargs)
    echo "2"
		DISK_SIZE_VAL[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "User Capacity" | cut -d "[" -f2 | cut -d "]" -f1 | tr -dc '0-9' | xargs)
    echo "3"
    DISK_SIZE_MEAS[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "User Capacity" | cut -d "[" -f2 | cut -d "]" -f1 |  tr -d '0-9' | xargs)
    echo "4"
    DISK_MODEL[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "Device Model" | awk '{print $3,$4,$5,$6}' | xargs)
    echo "5"
    DISK_MODEL_FAMILY[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "Model Family" | awk '{print $3,$4,$5,$6}')
    echo "6"
    DISK_RPM[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "Rotation Rate" | awk '{print $3,$4,$5,$6}' | xargs)
    echo "7"
    DISK_SERIAL[$i]=$(smartctl -i /dev/${PHYSICALDISKS[$i]} | grep "Serial Number" | awk '{print $3,$4,$5,$6}' | xargs)
    echo "8"
    DISK_SMART[$i]=$(smartctl -a /dev/${PHYSICALDISKS[$i]} | grep "SMART overall-health self-assessment test result" | awk '{print $6}')
    echo "9"
    DISK_IS_SSD[$i]=""

	# write seperate for LSI 3ware / Areca / HighPoint, HP CCISS, LSI MegaRAID, Intel Matrix/Rapid, Adaptec SAS


    done

# TODO - change to if exists then remove

rm ${disk_tempfile}
rm ${disk_tempfile_tab}


# generate temp csv

for ((i=0; i < ${#PHYSICALDISKS[@]}; i++))
    do
	#TODO if no name found then loop  raid ie -d cciss,0 + -d cciss,1
	#TODO if no rpm found then curl google  model + 5400 / 7200 / 1000 rpm and compare results (higher = rpm of the drive)

	# sample search
	#curl -sA "Chrome" -L 'https://www.google.co.uk/search?q=ST3250310AS+7200rpm&oq=ST3250310AS+7200rpm' -o search_temp7200.html
	#curl -sA "Chrome" -L 'https://www.google.co.uk/search?q=ST3250310AS+5400rpm&oq=ST3250310AS+5400rpm' -o search_temp5400.html

	echo -e "DISK${DISK_NUM[$i]},${PHYSICALDISKS[$i]},${DISK_SIZE[$i]},${DISK_MODEL[$i]},${DISK_SERIAL[$i]},${DISK_MODEL_FAMILY[$i]},${DISK_SMART[$i]},${DISK_RPM[$i]}" >> $disk_tempfile
    done


# convert to tab delimated

cat $disk_tempfile | sed 's/\"//g' | column -t -s, | less -S >> "$disk_tempfile_tab"


# echo tempfile tsv

cat $disk_tempfile_tab
