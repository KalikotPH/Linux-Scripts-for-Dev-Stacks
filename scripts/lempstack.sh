#!/bin/bash
# Script author: Bytes Crafter
# Script site: https://www.bytescrafter.net
# Script date: 19-04-2020
# Script ver: 1.0
# Script use to install LEMP stack on Debian 10
#--------------------------------------------------
# Software version:
# 1. OS: 10.3 (Buster) 64 bit
# 2. Nginx: 1.14.2
# 3. MariaDB: 10.3
# 4. PHP 7: 7.3.3-1+0~20190307202245.32+stretch~1.gbp32ebb2
#--------------------------------------------------
# List function:
# 1. bc_checkroot: check to make sure script can be run by user root
# 2. bc_update: update all the packages
# 3. bc_install: funtion to install LEMP stack
# 4. bc_init: function use to call the main part of installation
# 5. bc_main: the main function, add your functions to this place

# Function check user root
bc_checkroot() {
    if (($EUID == 0)); then
        # If user is root, continue to function bc_init
        bc_init
    else
        # If user not is root, print message and exit script
        echo "Bytes Crafter: Please run this script by user root ."
        exit
    fi
}

# Function update os
bc_update() {
    echo "Bytes Crafter: Initiating Update and Upgrade..."
    echo ""
    sleep 1
        apt update
        apt upgrade -y
    echo ""
    sleep 1
}

# Function install LEMP stack
bc_install() {

    ########## INSTALL NGINX ##########
    echo ""
    echo "Bytes Crafter: Installing NGINX..."
    echo ""
    sleep 1
        apt install nginx -y
        systemctl enable nginx && systemctl restart nginx
    echo ""
    sleep 1

    ########## INSTALL MARIADB ##########
    echo "Bytes Crafter: Installing MYSQL..."
    echo ""
    sleep 1
        apt install mariadb-server -y
        systemctl enable mysql && systemctl restart mysql
    echo ""
    sleep 1

    echo "Bytes Crafter: CREATING DB and USER ..."
    echo ""
        mysql -uroot -proot -e "CREATE DATABASE wordpress /*\!40100 DEFAULT CHARACTER SET utf8 */;"
        mysql -uroot -proot -e "CREATE USER wordpress@localhost IDENTIFIED BY 'wordpress';"
        mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';"
        mysql -uroot -proot -e "FLUSH PRIVILEGES;"
    echo ""
    sleep 1

    ########## INSTALL PHP7 ##########
    # This is unofficial repository, it's up to you if you want to use it.
    echo "Bytes Crafter: Installing PHP 7.3..."
    echo ""
    sleep 1
        apt install php7.3 php7.3-cli php7.3-common php7.3-fpm php7.3-gd php7.3-mysql -y
    echo ""
    sleep 1

    ########## MODIFY GLOBAL CONFIGS ##########
    echo "Bytes Crafter: Modifying Global Configurations..."
    echo ""
    sleep 1
        sed -i 's:# Basic Settings:client_max_body_size 24m;:g' /etc/nginx/nginx.conf
        sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 12M/g' /etc/php/7.3/fpm/php.ini
        sed -i 's/post_max_size = 2M/post_max_size = 12M/g' /etc/php/7.3/fpm/php.ini
    echo ""
    sleep 1

    ########## PREPARE DIRECTORIES ##########
    echo "Bytes Crafter: Preparing WordPress directory..."
    echo ""
    sleep 1
        mkdir /var/www/wordpress
        echo "<?php phpinfo(); ?>" >/var/www/wordpress/info.php
        chown -R www-data:www-data /var/www/wordpress
    echo ""
    sleep 1

    ########## MODIFY VHOST CONFIG ##########
    echo "Bytes Crafter: Modifying Default VHost for Nginx..."
    echo ""
    sleep 1
cat >/etc/nginx/sites-enabled/default <<"EOF"
server {
    listen 80;
    listen [::]:80;

    root /var/www/wordpress;
    index index.php index.html index.htm;

    server_name _;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ ^/wp-json/ {
        # if permalinks not enabled
        rewrite ^/wp-json/(.*?)$ /?rest_route=/$1 last;
    }

    location ~ \.php$ {
        include         fastcgi_params;
        fastcgi_pass    unix:/run/php/php7.3-fpm.sock;
        fastcgi_param   SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_index   index.php;
    }
}
EOF
    echo ""
    sleep 1

    ########## RESTARTING NGINX AND PHP ##########
    echo "Bytes Crafter: Restarting Nginx & PHP..."
    echo ""
    sleep 1
        systemctl restart nginx
        systemctl restart php7.3-fpm
    echo ""
    sleep 1

    ########## INSTALLING WORDPRESS ##########
    echo "Bytes Crafter: Installing WordPress..."
    echo ""
        wget -c http://wordpress.org/latest.tar.gz
        tar -xzvf latest.tar.gz
        rsync -av wordpress/* /var/www/wordpress/
        chown -R www-data:www-data /var/www/wordpress/
        chmod -R 755 /var/www/wordpress/
    echo ""
    sleep 1

    ########## ENDING MESSAGE ##########
    sleep 1
    echo ""
        local start="Bytes Crafter: You can access http://"
        local mid=`ip a | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
        local end="/ to setup your WordPress."
        echo "Bytes Crafter: $start$mid$end"
        echo "Bytes Crafter: MySQL db: wordpress user:wordpress pwd: wordpress "
        echo "Bytes Crafter: Thank you for using our script, Bytes Crafter! ..."
    echo ""
    sleep 1

}

# initialized the whole installation.
bc_init() {
    bc_update
    bc_install
}

# primary function check.
bc_main() {
    bc_checkroot
}
bc_main
exit
