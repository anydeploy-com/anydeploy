#!/bin/bash

##############################################################################
#                            Prepare                                         #
##############################################################################


# Get Script Dir (in case of path change later on)

script_path=`dirname $0`
script_dir="${PWD}/${script_path}"
main_dir=`cd $script_dir && cd .. && echo ${PWD}` # TODO - fix, seems ugly but works
iso_dir="${main_dir}/iso"
temp_dir="${main_dir}/tmp"

# Create Mount Dir

cd ${main_dir}

if [ ! -d "tmp/mount" ]; then
echo "Directory tmp/mount DOES NOT exists, creating."
mkdir tmp/mount
fi

if [ ! -d "tmp/extracted" ]; then
echo "Directory tmp/extracted DOES NOT exists, creating."
mkdir tmp/extracted
fi

# Actual ISO Creation
# Detect ISO's

iso_list=(`find ${iso_dir}/ -maxdepth 1 -name "*.iso"`)
iso_menu=`ls ${iso_dir}/*.iso | grep -v virtio | grep -v "autounattend" | awk '{print v++,$1}'`

if [ ! ${#iso_list[@]} -gt 0 ]; then
	echo ""
    echo "You must have at least 1 iso in $working_dir/iso"
    echo "Exiting..."
    exit 1
fi



##############################################################################
#                            Dialog - ISO Selection                          #
##############################################################################



dialog --clear --title "Select ISO" \
      --menu "Move using [UP] [DOWN} Arrow keys, Hit [ENTER] key to select." 20 70 5 $iso_menu 2> ${temp_dir}/chosen_iso.$$

menu_choice=`cat ${temp_dir}/chosen_iso.$$`

# Save Selection info to temp

chosen_iso=`echo "$iso_menu" | grep "${menu_choice} ." | awk '{print $2}'`

isoinfo -d -i $chosen_iso >> ${temp_dir}/isoinfo.$$

# cat ${temp_dir}/isoinfo.$$ # DEBUG - display iso info


##############################################################################
#                       Mount selected ISO                                   #
##############################################################################

#umount anything from mount location

if mount | grep "/anydeploy/tmp/mount";
then
echo "iso mounted already, unmounting"
sudo umount /anydeploy/tmp/mount
fi

# mount selected iso

sudo mount ${chosen_iso} /anydeploy/tmp/mount

##############################################################################
#                       User Input - ISO type                                #
##############################################################################

#how many indexes (for array usage)
amount_of_indexes=`wiminfo install.wim | grep "Index" | grep -Eo '[0-9]+' | sort -rn | head -n 1`



## Convert to DOS compatible
#    echo " * Converting Sysprep to Windows compatible (DOS)"
#    cat /anydeploy/tmp/extracted/componentautounattend_unix.xml | awk 'sub("$", "\r")' /anydeploy/tmp/extracted/autounattend_unix.xml > /anydeploy/tmp/extracted/autounattend.xml
#    sleep 1
wiminfo /anydeploy/tmp/mount/sources/install.wim | grep "Display Name:" | awk '{$1=$2=""; print $0}' | sed "s/^[ \t]*//" >> ${temp_dir}/os_version_list.$$

# Convert OS Versions to array

IFS=$'\n' os_edition_num=($(cat /anydeploy/tmp/os_version_list.$$ | awk '{print NR,$0}' | awk '{print $1}'))
#IFS=$'\n' os_edition_num=($(cat /anydeploy/tmp/os_version_list.$$ | awk '{print v++,$0}' | awk '{print $1}'))
IFS=$'\n' os_edition_name=($(cat /anydeploy/tmp/os_version_list.$$))

          SELECTIONINFO=()

          # Combine Arrays for Dialog Output

    for i in "${!os_edition_name[@]}"; do SELECTIONINFO+=( "${os_edition_num[${i}]}" "${os_edition_name[${i}]}" ); done
    # Display Dialog for OS Selection

    dialog --clear \
        --cancel-label "BACK" \
        --title "Some Windows Edition" \
        --menu "$banner2080" 20 80 10 "${SELECTIONINFO[@]}" 2> /anydeploy/tmp/chosen_edition.$$





    IFS=$'\r\n' GLOBIGNORE='*' command eval 'os_list=($(cat /anydeploy/tmp/os_version_list.$$))'

    #TODO check if ei.cfg exists, check edition



##############################################################################
#                      Generate unattend file                                #
##############################################################################

sudo rm /anydeploy/tmp/extracted/*

# for home needs manual input for COA

export chosen_edition_index=`cat /anydeploy/tmp/chosen_edition.$$`

# Select Key for chosen edition


## Convert to DOS compatible
#    echo " * Converting Sysprep to Windows compatible (DOS)"
#    cat /anydeploy/tmp/extracted/autounattend_unix.xml | awk 'sub("$", "\r")' /anydeploy/tmp/extracted/autounattend_unix.xml > /anydeploy/tmp/extracted/autounattend.xml
#    sleep 1



export chosen_edition_name=`cat /anydeploy/tmp/os_version_list.$$ | sed -n ${chosen_edition_index}p`



echo "chosen edition index: $chosen_edition_index"
echo "chosen edition name: $chosen_edition_name"

# pickup right COA Key

chosen_edition_key=`cat /anydeploy/systems/Windows/KMS_Keys_List.md | grep "$chosen_edition_name |" | sed 's/\||//g' | sed -e "s/$chosen_edition_name//" | xargs`

echo "chosen edition key: $chosen_edition_key"


##############################################################################
#                      Dialog MBR / GPT                                      #
##############################################################################






# Check if matching sysprep file exists

#  TODO IMPORTANT match sysprep file based on edition selected

# TODO ADD CHOOSE MBR / EFI + autodetection

# Windows 7 Test
#cp /anydeploy/systems/Windows/unattend_files/autounattend_win7_mbr_audit.xml /anydeploy/tmp/extracted/autounattend.xml


#Windows 10 Generate
sh /anydeploy/scripts/render_template.sh /anydeploy/systems/Windows/unattend_files/autounattend_win10_mbr_audit_template.xml >> /anydeploy/tmp/extracted/autounattend.xml


# Add postinstall script

echo "Taskkill /IM MicrosoftEdge.exe /F" >> /anydeploy/tmp/extracted/postinstall_unix.cmd
echo "choco install googlechrome adobereader flashplayerplugin flashplayeractivex jre8 sdio -y --force" >> /anydeploy/tmp/extracted/postinstall_unix.cmd
echo "REG DELETE HKLM\Software\Microsoft\Windows\CurrentVersion\Run /v Setup /f" >> /anydeploy/tmp/extracted/postinstall_unix.cmd

## Convert generated batch file to DOS format
echo " * Converting Generated Script to DOS compatible format"
cat /anydeploy/tmp/extracted/postinstall_unix.cmd | awk 'sub("$", "\r")' > /anydeploy/tmp/extracted/postinstall.cmd
sleep 1



cat >"/anydeploy/tmp/extracted/anydeploy_sdio_unix.bat" << EOF
:: Create DUMMY files
@copy /y NUL drivers\DP_LAN_Intel_17062.7z
@copy /y NUL drivers\DP_LAN_Others_17075.7z
@copy /y NUL drivers\DP_LAN_Realtek-NT_17075.7z
@copy /y NUL drivers\DP_LAN_Realtek-XP_17023.7z
:: Create update app script
@copy /y NUL scripts\anydeploy-update-app.txt
@echo activetorrent 1 > scripts\anydeploy-update-app.txt
@echo checkupdates >> scripts\anydeploy-update-app.txt
@echo get indexes >> scripts\anydeploy-update-app.txt
@echo end >> scripts\anydeploy-update-app.txt
:: Create update indexes script
@copy /y NUL scripts\anydeploy-update-indexes.txt
@echo activetorrent 1 > scripts\anydeploy-update-app.txt
@echo checkupdates >> scripts\anydeploy-update-app.txt
@echo get indexes >> scripts\anydeploy-update-app.txt
@echo end >> scripts\anydeploy-update-app.txt
:: Create update drivers script
@copy /y NUL scripts\anydeploy-update-drivers.txt
@echo init > scripts\anydeploy-update-drivers.txt
@echo activetorrent 2 >> scripts\anydeploy-update-drivers.txt
@echo checkupdates >> scripts\anydeploy-update-drivers.txt
@echo get driverpacks updates >> scripts\anydeploy-update-drivers.txt
@echo end >> scripts\anydeploy-update-drivers.txt
:: Execute Scripts
@echo ==============================
@echo Snappy Driver Installer Origin
@echo       updating app
@echo ==============================
@SDIO_x64_R667.exe -script:scripts\anydeploy-update-app.txt
@echo ==============================
@echo Snappy Driver Installer Origin
@echo       updating indexes
@echo ==============================
@SDIO_x64_R667.exe -script:scripts\anydeploy-update-indexes.txt
@echo ==============================
@echo Snappy Driver Installer Origin
@echo       updating drivers
@echo ==============================
@SDIO_x64_R667.exe -script:scripts\anydeploy-update-drivers.txt
sleep 10
EOF


## Convert generated batch file to DOS format
echo " * Converting Generated Script to DOS compatible format"
cat /anydeploy/tmp/extracted/anydeploy_sdio_unix.bat | awk 'sub("$", "\r")' > /anydeploy/tmp/extracted/anydeploy_sdio.bat
sleep 1



##############################################################################
#                            autunattend.iso creation                        #
##############################################################################

rm /anydeploy/iso/autounattend.iso
genisoimage -o /anydeploy/iso/autounattend.iso -joliet-long -relaxed-filenames /anydeploy/tmp/extracted/.


##############################################################################
#                            Create VM LibVirt                               #
##############################################################################

# TODO EXPERIMENTAL - Fix variables


# Create QCOW2 Image

qemu-img create -f qcow2 /var/lib/libvirt/images/win10home_mbr$$.qcow2 30G

# Add VM to Libvirt

virt-install \
--name "Win10Home_MBR$$" \
--ram=2048 \
--memory 2048,maxmemory=4096 \
--memballoon model=virtio \
--disk /anydeploy/iso/Win10_1803_English_x64.iso,device=cdrom --check path_in_use=off \
--disk /anydeploy/iso/autounattend.iso,device=cdrom --check path_in_use=off \
--disk /anydeploy/iso/virtio-win.iso,device=cdrom --check path_in_use=off \
--disk "/var/lib/libvirt/images/win10home_mbr$$.qcow2",format=qcow2,bus=virtio,cache=none \
--network=bridge:anybr0,model=virtio \
--events "on_poweroff=preserve" \
--os-variant "win10" \
--vcpus 2 \
--accelerate --noapic &


# List OS Variants

#virt-install --os-variant list


#--memballoon model=virtio


#--graphics vnc,password=foobar,port=5910,keymap=ja
#-p, --paravirt        This guest should be a paravirtualised guest
#--noautoconsole --wait=-1

##############################################################################
#                            Cleanup                                         #
##############################################################################

rm /anydeploy/tmp/chosen_iso.*
rm /anydeploy/tmp/isoinfo.*
#rm /anydeploy/tmp/os_version_list.*


# TODO - clear generated files + temp folders (only generated by this script)
