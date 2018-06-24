#!/bin/bash

# printer list ( TODO AS ARRAY)
lpstat -p | grep "printer" | awk '{print $2}'

# printer info ( TODO AS for each)
lpstat -l -p dell


# check if printer is available remotely
lpstat -h 10.1.1.1:631 -p dell

# print remotely # REQUIRES cups-bsd

echo "dupa" | lpr -H 10.1.1.1 -P dell
lpr -H 10.1.1.1 -P dell $filename
