#!/bin/bash

# install nginx

apt install nginx

# install php-fpm

apt install php-fpm

# setup nginx


# Clear default config

rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default

rm /etc/nginx/sites-enabled/anydeploy
rm /etc/nginx/sites-available/anydeploy

touch /etc/nginx/sites-available/anydeploy

ln -s /etc/nginx/sites-available/anydeploy /etc/nginx/sites-enabled/anydeploy

cat >"/etc/nginx/sites-available/anydeploy" << EOF
server {
	listen 80 default_server;
	listen [::]:80 default_server;

	root /anydeploy/www;

	index index.php index.html index.htm index.nginx-debian.html;

	server_name _;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		try_files \$uri \$uri/ =404;
	}

	# pass PHP scripts to FastCGI server
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
		fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
	}

}
EOF

# remove www if exists

rm -rf /anydeploy/www

mkdir /anydeploy/www
# Clone PHP menu


touch /anydeploy/www/index.php


 # TODO - change ip 192.168.1.254 to ${next-server} ipxe variable

cat >"/anydeploy/www/index.php" << EOF
<?php
 phpinfo();
?>
EOF

touch /anydeploy/www/menu.ipxe

cat >"/anydeploy/www/menu.ipxe" << EOF
#!ipxe
menu anyDeploy PXE menu
item anydeploy Anydeploy

choose --default anydeploy --timeout 15000 target && goto ${target}
#choose os && goto ${os}

:anydeploy

kernel http://192.168.1.254/vmlinuz initrd=initrd.img nfsroot=192.168.1.254:/nfs/any64 rw ip=dhcp net.ifnames=0
initrd http://192.168.1.254/initrd.img
boot
EOF


#rm /etc/nginx/sites-enabled/default
#ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default


# Copy kernel (ln doesnt work well)
cp /nfs/any64/vmlinuz /anydeploy/www/vmlinuz

# Copy init (ln doesnt work well)
cp /nfs/any64/initrd.img /anydeploy/www/initrd.img

# Restart nginx

service nginx restart

# Restart php fpm

service php7.0-fpm restart
