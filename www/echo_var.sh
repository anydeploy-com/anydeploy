#!/bin/bash

for ARGUMENT in "$@"
do

    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
            vmid)              vmid=${VALUE} ;;
            task)    task=${VALUE} ;;
            *)
    esac


done

echo "vmid = $vmid"
echo "task = $task"
