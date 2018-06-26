#!/bin/bash

##############################################################################
#                            Include functions                               #
##############################################################################

  source ../../global.conf                              # Include Global Conf
  source ${install_path}/scripts/includes/functions.sh  # Include Functions


##############################################################################
#                              Define Arrays                                 #
##############################################################################

SAVEIFS=$IFS

IFS=$'\n'

iso_list=($(ls ${iso_path}/*.iso | grep -v "autounattend" | grep -v "virtio"))
#iso_menu=$(ls ${iso_path}/*.iso | grep -v "autounattend" | grep -v "virtio" | awk '{print v++,$1}')
iso_name=($(ls ${iso_path}/*.iso | grep -v "autounattend" | grep -v "virtio" | sed 's:.*/::'))



##############################################################################
#                Verify if there is at least single ISO                      #
##############################################################################

if [ ! ${#iso_list[@]} -gt 0 ]; then
	echo ""
    echo "You must have at least 1 iso in $working_dir/iso"
    echo "Exiting..."
    exit 1
fi


##############################################################################
#                       Mount all ISO's                                      #
##############################################################################


# Create dirs

for i in ${iso_name[@]}; do
  echo "mountpoint for ${i} exists - unmounting and deleting"
  umount "${temp_path}/${i}"
  rm -rf "${temp_path}/${i}"
  mkdir "${temp_path}/${i}"
done

# mount iso's

for i in ${!iso_list[@]}; do
  iso_mountpath+=(${temp_path}/${iso_name[${i}]}/)
  mount -o ro ${iso_list[${i}]} ${iso_mountpath[${i}]}
done

##############################################################################
#                           Get ISO's info                                   #
##############################################################################

for i in ${!iso_list[@]}; do
  # Windows Operating Systems
  # Check if install.wim exists - if yes = Windows
  if [ -f "${iso_mountpath[${i}]}/sources/install.wim" ]; then
    iso_iswindows[$i]="yes"
    iso_system_name[$i]=$(wiminfo ${iso_mountpath[${i}]}/sources/install.wim | grep "Display Name:" | awk '{print $3,$4}' | uniq | xargs)
    iso_architecture[$i]=$(wiminfo ${iso_mountpath[${i}]}/sources/install.wim | grep "Architecture:" | uniq | awk '{print $2}' | xargs)
    IFS=$'\n' iso_system_editions=($(wiminfo ${iso_mountpath[${i}]}/sources/install.wim | grep "Display Name:" | awk '{$1=$2=""; print $0}' | sed "s/^[ \t]*//"))
  # Add other OS'es here
  else
    iso_iswindows[$i]="no"
    iso_system_name+="Unknown"
    iso_architecture[$i]="x86"
  fi


  echo ""
  echo iso_id: ${i}
  echo iso_name: ${iso_name[$i]}
  echo iso_mountpath: ${iso_mountpath[$i]}
  echo iso_iswindows: ${iso_iswindows[$i]}
  echo iso_system_name: "${iso_system_name[$i]}"
  echo iso_architecture: "${iso_architecture[$i]}"
  echo
done


for i in "${!iso_list[@]}"; do
  # Interface Dialog Name
iso_dialog_name+=("$i" "${iso_name[${i}]} / ${iso_system_name[${i}]} / ${iso_architecture[${i}]} ")
done




##############################################################################
#                            Dialog - ISO Selection                          #
##############################################################################



chosen_iso_id=$(dialog --backtitle "Anydeploy - Select ISO for VM Creation" \
            --menu "Please select ISO below to create VM" 30 100 10 ${iso_dialog_name[@]} 2>&1 >/dev/tty)
IFS=$'\n' export iso_system_editions=($(wiminfo ${iso_mountpath[${chosen_iso_id}]}/sources/install.wim | grep "Display Name:" | awk '{$1=$2=""; print $0}' | sed "s/^[ \t]*//"))

      # Fix back IFS
      IFS=$SAVEIFS

    iso_install_script_path="${install_path}/systems/${iso_architecture[${chosen_iso_id}]}/${iso_system_name[${chosen_iso_id}]}/install.sh"

echo Chosen ISO ID: ${chosen_iso_id}
echo Chosen ISO Path: ${iso_list[${chosen_iso_id}]}
echo Chosen ISO Operating System: ${iso_system_name[${chosen_iso_id}]}
echo Chosen ISO InstallPath: ${iso_architecture[${chosen_iso_id}]}
echo Chosen ISO Editions: ${iso_system_editions[@]}
echo Install Script Path: ${iso_install_script_path[@]}
bash "${iso_install_script_path[@]}" ${iso_list[${chosen_iso_id}]}


##############################################################################
#                 Umount all ISO's after getting info                        #
##############################################################################

for i in ${iso_name[@]}; do
    umount "${temp_path}/${i}"
    rm -rf "${temp_path}/${i}"
done


##############################################################################
#                        Get Selected ISO Information                        #
##############################################################################


#echo "chosen iso path=$chosen_iso"

#isoinfo -d -i $chosen_iso >> /anydeploy/tmp/isoinfo.$$

#cat /anydeploy/tmp/isoinfo.$$
