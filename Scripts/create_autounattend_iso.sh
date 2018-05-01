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
main_dir=`$script_dir/..`

# Make ISO dir

echo "main dir = ${main_dir}"

cd ../tmp
