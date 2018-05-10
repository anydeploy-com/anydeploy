#!/bin/bash

# "Windows"
# "Debian"
# "CentOS"
# "Ubuntu"
# "Fedora"
# "Red Hat Enterprise Linux"
# "Mac OS X"
# "OS X"
# "macOS"
operating_system=""

# "Windows Vista"
# "Windows 7"
# "Windows 8"
# "Windows 8.1"
# "Windows 10"
# "Windows Server 2008"
# "Windows Server 2008 R2"
# "Windows Server 2012"
# "Windows Server 2012 R2"
# "Windows Server 2016"
operating_system_edition=""


architecture="" # "x86" or "amd64"
iso_directory=""
iso_filename=""
system_firmware="" # "UEFI" "EFI" "BIOS"
disk_format="" # "mbr", "gpt"




# Windows Related

# Sysprep (audit)
sysprep_audit_diskconfiguration_mbr=`cat <<EOF
<DiskConfiguration>
    <Disk wcm:action="add">
        <CreatePartitions>
            <CreatePartition wcm:action="add">
                <Order>1</Order>
                <Type>Primary</Type>
                <Size>100</Size>
              </CreatePartition>
            <CreatePartition wcm:action="add">
                <Extend>true</Extend>
                <Order>2</Order>
                <Type>Primary</Type>
            </CreatePartition>
          </CreatePartitions>
              <ModifyPartitions>
                  <ModifyPartition wcm:action="add">
                      <Active>true</Active>
                      <Format>NTFS</Format>
                      <Label>System Reserved</Label>
                      <Order>1</Order>
                      <PartitionID>1</PartitionID>
                      <TypeID>0x27</TypeID>
                    </ModifyPartition>
                    <ModifyPartition wcm:action="add">
                      <Active>true</Active>
                      <Format>NTFS</Format>
                      <Label>OS</Label>
                      <Letter>C</Letter>
                      <Order>2</Order>
                      <PartitionID>2</PartitionID>
                    </ModifyPartition>
                </ModifyPartitions>
      <DiskID>0</DiskID>
      <WillWipeDisk>true</WillWipeDisk>
    </Disk>
</DiskConfiguration>
EOF
`
#echo "DiskConfigurationMBR: ${sysprep_audit_diskconfiguration_mbr}"

sysprep_audit_diskconfiguration_gpt=`cat <<EOF
<DiskConfiguration>
              <Disk wcm:action="add">
                <DiskID>0</DiskID>
                <WillWipeDisk>true</WillWipeDisk>
              <CreatePartitions>
            <!-- Windows RE Tools partition -->
                    <CreatePartition wcm:action="add">
                          <Order>1</Order>
                          <Type>Primary</Type>
                          <Size>300</Size>
                    </CreatePartition>
                    <!-- System partition (ESP) -->
                    <CreatePartition wcm:action="add">
                          <Order>2</Order>
                          <Type>EFI</Type>
                          <Size>100</Size>
                    </CreatePartition>
                    <!-- Microsoft reserved partition (MSR) -->
                    <CreatePartition wcm:action="add">
                          <Order>3</Order>
                          <Type>MSR</Type>
                          <Size>128</Size>
                    </CreatePartition>
                    <!-- Windows partition -->
                    <CreatePartition wcm:action="add">
                          <Order>4</Order>
                          <Type>Primary</Type>
                          <Extend>true</Extend>
                    </CreatePartition>
            </CreatePartitions>
            <ModifyPartitions>
                  <!-- Windows RE Tools partition -->
                  <ModifyPartition wcm:action="add">
                        <Order>1</Order>
                        <PartitionID>1</PartitionID>
                        <Label>WINRE</Label>
                        <Format>NTFS</Format>
                  </ModifyPartition>
                  <!-- System partition (ESP) -->
                  <ModifyPartition wcm:action="add">
                        <Order>2</Order>
                        <PartitionID>2</PartitionID>
                        <Label>System</Label>
                        <Format>FAT32</Format>
                  </ModifyPartition>
                  <!-- MSR partition does not need to be modified -->
                  <ModifyPartition wcm:action="add">
                        <Order>3</Order>
                        <PartitionID>3</PartitionID>
                  </ModifyPartition>
                  <!-- Windows partition -->
                  <ModifyPartition wcm:action="add">
                        <Order>4</Order>
                        <PartitionID>4</PartitionID>
                        <Label>OS</Label>
                        <Letter>C</Letter>
                        <Format>NTFS</Format>
                  </ModifyPartition>
                </ModifyPartitions>
            </Disk>
            </DiskConfiguration>
EOF
`
#echo "DiskConfigurationMBR: ${sysprep_audit_diskconfiguration_gpt}"
sysprep_audit_InstallFrom_Key="/IMAGE/INDEX"
sysprep_audit_InstallFrom_value="${chosen_edition_index}"
sysprep_audit_InstallToPartitionID_mbr="2"
sysprep_audit_InstallToPartitionID_gpt="4"
sysprep_audit_arch="$architecture"
sysprep_audit_DriverPath="F:" # Virtio Drivers for VM's
sysprep_audit_DriverPath="" # Regular deployment drivers
sysprep_audit_InputLocale_PE="en-US" # DO NOT CHANGE THIS
sysprep_audit_SystemLocale_PE="en-US" # DO NOT CHANGE THIS
sysprep_audit_UIlanguage_PE="en-US" # DO NOT CHANGE THIS
sysprep_audit_UserLocale_PE="en-US" # DO NOT CHANGE THIS
sysprep_audit_WillWipeDisk="true"
sysprep_audit_AcceptEula="true"
sysprep_audit_FullName=
sysprep_audit_Organization=
sysprep_audit_ProductKey=
sysprep_audit_WillShowUI=
sysprep_audit_InputLocale=
sysprep_audit_SystemLocale=
sysprep_audit_UILanguage=
sysprep_audit_UILanguageFallback=
sysprep_audit_UserLocale=
sysprep_audit_HideEULAPage=
sysprep_audit_HideWirelessSetupInOOBE=
sysprep_audit_NetworkLocation=
sysprep_audit_ProtectYourPC=
sysprep_audit_SkipUserOOBE=
sysprep_audit_Autologon_Password=
sysprep_audit_Autologon_Password_Plaintext="false"
sysprep_audit_FirstLogonCommands_1="REG ADD "HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff" /F"
sysprep_audit_FirstLogonCommands_1_Description="No New Network Block"
sysprep_audit_FirstLogonCommands_1_RequiresUserInput="true"
sysprep_audit_FirstLogonCommands_2="cmd.exe /c powershell -Command \"Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force\""
sysprep_audit_FirstLogonCommands_2_Description="Set Execution Policy 64 Bit"
sysprep_audit_FirstLogonCommands_2_RequiresUserInput="true"
sysprep_audit_FirstLogonCommands_3="REG ADD "HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /f /v PreventFirstRunPage /t REG_DWORD /d 1"
sysprep_audit_FirstLogonCommands_3_Description="Disable Microsoft Edge First Run Page"
sysprep_audit_FirstLogonCommands_3_RequiresUserInput="true"
sysprep_audit_FirstLogonCommands_4=""
sysprep_audit_FirstLogonCommands_4_Description="Execute Postinstall Script"
sysprep_audit_FirstLogonCommands_4_RequiresUserInput="true"
sysprep_audit_ComputerName=
sysprep_audit_TimeZone=
sysprep_audit_RegisteredOwner=
sysprep_audit_SkipAutoActivation="true"

# Sysprep
