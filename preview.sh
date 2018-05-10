




-------- Forwarded Message --------
Subject: 	script install anydeploy
Date: 	Tue, 6 Feb 2018 16:27:16 +0000
From: 	Martin Plocinski <martin@ldcd.co.uk>
To: 	martinplocinski@gmail.com


#!/bin/bash

  # Clear for readability
  clear

  # Display information about scripts

  echo ""
  echo " I provide no responsibility for this script ..."
  echo ""

  # Declare dependencies

  deps=( debootstrap sudo )

  # Formatting functions
  # special characters: ✔/▰/✘

  function echo_pass {
  echo "$(tput setaf 2) ✔$(tput sgr0) - $1"
  }

  function echo_warn {
  echo "$(tput setaf 3) ▰$(tput sgr0) - $1"
  }

  function echo_fail {
  echo "$(tput setaf 1) ✘$(tput sgr0) - $1"
  }

  # Enchanced exec

  function logexec {
  $1 &>> log.txt
  }

  # check if run as root

  if [[ $EUID -ne 0 ]]; then
     echo_fail "This script must be run as root"
     exit 1
  else
    echo_pass "Running as root / sudo"
  fi

# Define dependencies and verify them

for i in "${deps[@]}"
do
  if which $i >/dev/null; then
  echo_pass "Dependency $i is installed"
else
  echo_warn "Dependency $i is not installed"
    read -p " Do you want me to install $i (y/n)? " CONT
    if [ "$CONT" = "y" ]; then
    echo_warn "Installing $i";
    apt-update &>> log.txt
    apt install $i &>> log.txt
    else
    echo_fail "Cancelled script due to depencency missing ($i)";
    exit 1
    fi
fi
done

spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Create directory for debootstrap

#--arch=i386
#--arch=amd64
mkdir /nfs
mkdir /nfs/anydeploy_i386 &>> log.txt

# Download Ubuntu Base i686

printf " Downloading AnyDeploy base - might take a while" &
debootstrap --arch=i386 xenial /nfs/anydeploy_i386
http://archive.ubuntu.com/ubuntu/ &>> log.txt &
spinner $!

# Verify if bootstrap installed sucessfully

if grep -q "Base system installed successfully" "log.txt"; then
echo_pass "Base System installed successfully"
else
echo_fail "Failed to install base system"
fi

echo " Running chroot commands"
cp /proc/cpuinfo /nfs/anydeploy_i386/proc/cpuinfo


echo -e "#!/bin/bash

sudo apt-mark hold grub* grub*:i386
apt update
apt install -y locales dialog
locale-gen en_GB.UTF-8  # or your preferred locale
apt install -y nano sudo linux-generic
rm /etc/hostname
echo \"anydeploy32\" >> /etc/hostname
hostname anydeploy32
/etc/init.d/hostname.sh start
sed -i 's/^MODULES=.*/MODULES=netboot/' /etc/initramfs-tools/initramfs.conf
echo \"BOOT=nfs\" >> /etc/initramfs-tools/initramfs.conf
update-initramfs -u
echo -e \"ukcp12\nukcp12\" | passwd root">> /nfs/anydeploy_i386/chroot.sh



# check if apache2 is installed (which apache2 ? )

# install apache2 if not installed // use nginx ?



chmod +x /nfs/anydeploy_i386/chroot.sh
chroot "/nfs/anydeploy_i386" ./chroot.sh


echo -e "<VirtualHost *:80>
    KeepAlive Off
    ServerName 10.1.2.250/anydeploy_i386
    DocumentRoot /var/www/anydeploy_i386/
    <Directory /var/www/anydeploy_i386>
        Options -Indexes
    </Directory>
</VirtualHost>">> /etc/apache2/sites-available/003-anydeploy_i386.conf

# check if /var/www exists

mkdir /var/www/anydeploy_i386
ln -s /nfs/anydeploy_i386/initrd.img /var/www/anydeploy_i386/initrd.img
ln -s /nfs/anydeploy_i386/vmlinuz /var/www/anydeploy_i386/vmlinuz
ln -s /nfs/anydeploy_i386/vmlinuz /var/www/anydeploy_i386/vmlinuz.efi
chown www-data:www-data /var/www/anydeploy_i386/initrd.img
chown www-data:www-data /var/www/anydeploy_i386/vmlinuz
chown www-data:www-data /var/www/anydeploy_i386/vmlinuz.efi


a2ensite 003-anydeploy_i386.conf
service apache2 restart

echo "/nfs/anydeploy_i386
*(rw,no_root_squash,async,insecure,no_subtree_check,fsid=8)" >> /etc/exports
service nfs-kernel-server restart

# Finish script info

echo ""
echo "Thank you for using anydeploy"
echo ""
