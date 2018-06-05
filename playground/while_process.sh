#!/bin/bash


spin[0]="-"
spin[1]="\\"
spin[2]="|"
spin[3]="/"



dhcpcd -T eno1 &> /anydeploy/tmp/dhcp_discover.$$ &
clear
pid=$(ps aux | grep dhcpcd -T | grep -v grep | awk '{print $2}')

spin='-\|/'

i=0
while kill -0 $pid 2>/dev/null
do
  i=$(( (i+1) %4 ))
  printf " - Detecting Current DHCP Settings\r${spin:$i:1}"
  sleep .1
done
