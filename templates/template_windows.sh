#!/bin/bash

templatename="Windows 10 Test Template"

. /anydeploy/settings/functions.sh

install_dependencies="prompt" # "yes","no","prompt"
operating_system="auto" # "auto", "<options below>"
# "Windows"
# "Debian"
# "CentOS"
# "Ubuntu"
# "Fedora"
# "Red Hat Enterprise Linux"
# "Mac OS X"
# "OS X"
# "macOS"
operating_system_edition="prompt" # "prompt", "<options below>"
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
operating_system_fullname="automatic" # "automatic", "<name>"
architecture="" # "x86" or "amd64"
# Directories
main_dir="/anydeploy" # "default" or "<path>"
iso_dir="${main_dir}/iso" # "default" or "<path>"
temp_dir="${main_dir}/tmp" # "default" or "<path>"
script_dir="${main_dir}/scripts" # "default" or "<path>"

system_firmware="auto" # "auto", "UEFI", "EFI", "BIOS"
disk_format="auto" # "auto", "mbr", "gpt"


# Windows Related
create_vm="yes" # "yes","no"
# Virtual machine settings
virt_vcpus="2" # "<value>"
virt_name="autodetect" # "autodetect", "prompt", "<name>"
virt_ram="2048" # "prompt", "<value>"
virt_ram_max="4096" # "prompt", "<value>"
virt_memballon="yes" # "yes","no"
virt_disk_type="qcow2" # "qcow2","lvm","physical","raw"
virt_disk_path="/var/lib/libvirt/images/${virt_name}.qcow2"
virt_use_autounattend="yes" #"yes","no"
virt_use_virtio="yes" # "yes","no"
virt_os_variant="yes" # "auto","prompt","<value>"
virt_noapic="yes" # "yes","no"
virt_accelerate="yes" # "yes","no"


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
EOF `
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
EOF `
sysprep_audit_InstallFrom_Key="/IMAGE/INDEX"
sysprep_audit_InstallFrom_value="${chosen_edition_index}"
sysprep_audit_InstallToPartitionID_mbr="2"
sysprep_audit_InstallToPartitionID_gpt="4"
sysprep_audit_arch="${architecture}"
sysprep_audit_DriverPath="F:" # Virtio Drivers for VM's
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
sysprep_audit_FirstLogonCommands=`cat <<EOF
<FirstLogonCommands>
  <!-- Disable network selection after sysprep  -->
  <SynchronousCommand wcm:action=\"add\">
        <CommandLine>REG ADD \"HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff\" /F</CommandLine>
        <Description>No New Network Block</Description>
        <Order>1</Order>
        <RequiresUserInput>true</RequiresUserInput>
    </SynchronousCommand>
    <!-- Allow powershell Scripts -->
    <SynchronousCommand wcm:action=\"add\">
        <CommandLine>cmd.exe /c powershell -Command \"Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force\"</CommandLine>
        <Description>Set Execution Policy 64 Bit</Description>
        <Order>2</Order>
        <RequiresUserInput>true</RequiresUserInput>
    </SynchronousCommand>
    <SynchronousCommand wcm:action=\"add\">
        <CommandLine>REG ADD \"HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main\" /f /v PreventFirstRunPage /t REG_DWORD /d 1</CommandLine>
        <Description>Disable Microsoft Edge First Run Page</Description>
        <Order>3</Order>
        <RequiresUserInput>true</RequiresUserInput>
    </SynchronousCommand>
</FirstLogonCommands>
EOF `
sysprep_audit_ComputerName=
sysprep_audit_TimeZone=
sysprep_audit_RegisteredOwner=""
sysprep_audit_SkipAutoActivation="true"

# Sysprep
