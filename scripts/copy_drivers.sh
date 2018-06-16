#!/bin/bash

# Check if exists and make dir C:\postinstall

if [ ! -d "/ntfs/postinstall" ]; then
echo "Directory /ntfs/postinstall DOES NOT exists, creating."
mkdir /ntfs/postinstall
fi

# Check if exists and make dir C:\postinstall\drivers

if [ ! -d "/ntfs/postinstall/drivers" ]; then
echo "Directory /ntfs/postinstall/drivers DOES NOT exists, creating."
mkdir /ntfs/postinstall/drivers
fi

# Copy LAN Drivers to C:\postinstall\drivers from network location

# Extract LAN Drivers

    # Intel
    7za x DP_LAN_Intel* -aoa
    # Realtek
    7za x DP_LAN_Realtek* -aoa
    # Other
    7za x DP_LAN_Others* -aoa
