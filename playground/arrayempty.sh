#!/bin/bash

PHYSICALDISKS=($(lsblk -d | grep "disk" | awk '{print $1}'))

if [ ${#PHYSICALDISKS[@]} -eq 0 ]; then
    echo "No disks detected"
fi

