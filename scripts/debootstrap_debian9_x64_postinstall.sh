# Edit Sources
  # looks fine
  # Fix Hostname
  rm "${ANYNET_DIR}/etc/hostname"
  echo "anylive_x64" >> "${ANYNET_DIR}/etc/hostname"
  # Fix Nameservers (resolv.conf)
  rm "${ANYNET_DIR}/etc/resolv.conf"
  touch "${ANYNET_DIR}/etc/resolv.conf"
  cat >"${ANYNET_DIR}/etc/resolv.conf" << EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
  # Fix Locales
  export LANGUAGE="en_GB.UTF-8"
  echo "LANGUAGE=\"en_GB.UTF-8\"" >> "${ANYNET_DIR}/etc/default/locale"
  echo "LC_ALL=\"en_GB.UTF-8\"" >> "${ANYNET_DIR}/etc/default/locale"
  echo "LC_ALL=\"en_GB.utf8\"" >> "${ANYNET_DIR}/etc/environment"
  # Setup mounts (fstab)
  rm "${ANYNET_DIR}/etc/fstab"
  touch "${ANYNET_DIR}/etc/fstab"
  cat >"${ANYNET_DIR}/etc/fstab" << EOF
proc /proc proc defaults 0 0
/dev/nfs / nfs defaults 1 1
none /tmp tmpfs defaults 0 0
none /run tmpfs defaults 0 0
none /var/tmp tmpfs defaults 0 0
none /media   tmpfs defaults 0 0
none /var/log tmpfs defaults 0 0
hostname anylive_x64
EOF
  # Disable installation of recommended packages
  echo 'APT::Install-Recommends "false";' >"${ANYNET_DIR}/etc/apt/apt.conf.d/50norecommends"

  # Change initramfs options to be netboot compatible

      #change MODULES=netboot in chrooted "/etc/initramfs-tools/initramfs.conf"

      sed -i "/MODULES=/ s/=.*/=netboot/" ${ANYNET_DIR}/etc/initramfs-tools/initramfs.conf


      #add BOOT=nfs to chrooted "/etc/initramfs-tools/initramfs.conf"

      echo "BOOT=nfs" >> ${ANYNET_DIR}/etc/initramfs-tools/initramfs.conf

  # Configure Networking

  # Run chroot tasks

  # TODO ADD TRAP TO REMOVE  CHROOT POSTINSTALL SCRIPT

  # Generate chroot postinstall script
  touch ${ANYNET_DIR}/chrootpostinstall.sh
  # Add content to it
  # TODO - echo output to postinstall.log and verify afterwards
  cat >"${ANYNET_DIR}/chrootpostinstall.sh" << EOF
#!/bin/bash
hostnamectl set-hostname anylive64
apt-get install locales -y
locale-gen en_GB.UTF-8
#dpkg-reconfigure locales
apt update -y && apt upgrade -y
apt install -y nfs-common initramfs-tools
touch /postinstall_log.txt
echo "postinstall finished" >> /postinstall_log.txt
TZ='Europe/London'; export TZ
update-initramfs -u
EOF
  # Make it executable
  chmod +x ${ANYNET_DIR}/chrootpostinstall.sh
  # Execute postinstall chroot script within chroot
  chroot ${ANYNET_DIR} ./chrootpostinstall.sh
  # Remove postinstall chroot script
  rm ${ANYNET_DIR}/chrootpostinstall.sh
  # Fix original hostname
  hostnamectl set-hostname anydeploy
  # Restart bash to apply original hostname to prompt
  bash
  # Verify if postinstall script run succesfully - ${ANYNET_DIR}/postinstall_log.txt
  # du -sh /anydeploy/nfs/anynetlive_amd64/ - verify size (~750MiB)
  # check if files exist
  # TODO
  # Create User
  # TODO
  # Add SSH KEY
  # TODO
