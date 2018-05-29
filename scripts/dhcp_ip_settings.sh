#!/bin/bash

dialog --backtitle "DHCP IP Settings" --title "Dialog - Form" \
--form "\nDialog Sample Label and Values" 25 60 16 \
"Server IP Address:" 1 1 "10.1.1.1" 1 25 25 30 \
"DHCP Start IP:" 2 1 "10.1.1.50" 2 25 25 30 \
"DHCP End IP:" 3 1 "10.1.1.250" 3 25 25 30 \
"Gateway:" 4 1 "10.1.1.254" 4 25 25 30 \
2>/tmp/form.$$
