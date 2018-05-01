#!/bin/bash

dependencies=( genisoimage )

echo "Dependencies listed below:"
 for ((i=0; i < ${#dependencies[@]}; i++))
    do
		echo " - ${dependencies[i]}"
    done

# Get Script Dir (in case of path change later on)

script_path=`dirname $0`
script_dir="${PWD}/${script_path}"
main_dir=`cd $script_dir && cd .. && echo ${PWD}`

# Create Mount Dir

cd $main_dir

if [ ! -d "tmp/mount" ]; then
echo "Directory tmp/mount DOES NOT exists, creating."
mkdir tmp/mount
fi

# Detect ISO's

iso_list=(`find ${main_dir}/iso/ -maxdepth 1 -name "*.iso"`)

echo ${iso_list}
