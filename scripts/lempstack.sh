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
# 1. f_check_root: check to make sure script can be run by user root
# 2. f_update_os: update all the packages
# 3. f_install_lemp: funtion to install LEMP stack
# 4. f_sub_main: function use to call the main part of installation
# 5. f_main: the main function, add your functions to this place

# Function check user root
f_check_root() {
    if (($EUID == 0)); then
        # If user is root, continue to function f_sub_main
        f_sub_main
    else
        # If user not is root, print message and exit script
        echo "USocketNet: Please run this script by user root ."
        exit
    fi
}

# Function update os
f_update_os() {
    echo "USocketNet: Trying to update the system ..."
    echo ""
    sleep 1
    apt update
    apt upgrade -y
    echo ""
    sleep 1
}

# Function install LEMP stack
f_install_lemp() {
    # Install and start nginx
    echo ""
    echo "USocketNet: Installing NGINX ..."
    echo ""
    sleep 1
    apt install nginx -y
    systemctl enable nginx && systemctl restart nginx
    echo ""
    sleep 1

    ########## INSTALL MARIADB ##########
    echo "USocketNet: Installing MYSQL ..."
    echo ""
    sleep 1
    apt install mariadb-server -y
    systemctl enable mysql && systemctl restart mysql
    echo ""
    sleep 1

    echo "USocketNet: CREATING DB AND USER ..."
    echo ""
    mysql -uroot -proot -e "CREATE DATABASE usocketnet /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -uroot -proot -e "CREATE USER usocketnet@localhost IDENTIFIED BY 'usocketnet';"
    mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON usocketnet.* TO 'usocketnet'@'localhost';"
    mysql -uroot -proot -e "FLUSH PRIVILEGES;"
    echo ""
    sleep 1

    ########## INSTALL PHP7 ##########
    # This is unofficial repository, it's up to you if you want to use it.
    echo "USocketNet: Installing PHP 7 ..."
    echo ""
    sleep 1
    apt install php7.3 php7.3-cli php7.3-common php7.3-fpm php7.3-gd php7.3-mysql -y
    echo ""
    sleep 1

    # Config to make PHP-FPM working with Nginx
    # echo "SocketNet: Binding PHP-FPM with Nginx ..."
    # echo ""
    # sleep 1
    # sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /etc/php/7.3/fpm/php.ini
    # sed -i 's:user = www-data:user = nginx:g' /etc/php/7.3/fpm/pool.d/www.conf
    # sed -i 's:group = www-data:group = nginx:g' /etc/php/7.3/fpm/pool.d/www.conf
    # sed -i 's:listen.owner = www-data:listen.owner = nginx:g' /etc/php/7.3/fpm/pool.d/www.conf
    # sed -i 's:listen.group = www-data:listen.group = nginx:g' /etc/php/7.3/fpm/pool.d/www.conf
    # sed -i 's:;listen.mode = 0660:listen.mode = 0660:g' /etc/php/7.3/fpm/pool.d/www.conf

    # Increase max upload size on php.
    sed -i 's:# Basic Settings:client_max_body_size 24m;:g' /etc/nginx/nginx.conf
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 12M/g' /etc/php/7.3/fpm/php.ini
    sed -i 's/post_max_size = 2M/post_max_size = 12M/g' /etc/php/7.3/fpm/php.ini
    systemctl restart php7.3-fpm

    # Create web root directory and php info file
    echo "USocketNet: Createing demo PHP info file ..."
    echo ""
    sleep 1
    mkdir /var/www/usocketnet
    echo "<?php phpinfo(); ?>" >/var/www/usocketnet/info.php
    chown -R www-data:www-data /var/www/usocketnet

    # Create demo nginx vhost config file
    echo "USocketNet: Creating demo Nginx vHost config file ..."
    echo ""
    sleep 1r
    cat >/etc/nginx/sites-enabled/default <<"EOF"
server {
    listen 80;
    listen [::]:80;

    root /var/www/usocketnet;
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

    # Restart nginx and php-fpm
    echo "SocketNet: Restarting Nginx & PHP ..."
    echo ""
    sleep 1
    systemctl restart nginx
    systemctl restart php7.3-fpm

    #Install WordPress here latest.
    echo "SocketNet: Installing WordPress ..."
    echo ""
    wget -c http://wordpress.org/latest.tar.gz
    tar -xzvf latest.tar.gz
    rsync -av wordpress/* /var/www/usocketnet/
    chown -R www-data:www-data /var/www/usocketnet/
    chmod -R 755 /var/www/usocketnet/
    echo ""
    sleep 1

    echo ""
    echo "You can access http://YOUR-SERVER-IP/ to setup your WordPress."
    echo "MySQL db: usocketnet user:usocketnet pwd: usocketnet "
    echo "Thank you for using our script, Bytes Crafter! ..."
    echo "http://www.bytescrafter.net ..."
    echo ""
    sleep 1

}



# The sub main function, use to call neccessary functions of installation
f_sub_main() {
    f_update_os
    f_install_lemp
}

# The main function
f_main() {
    f_check_root
    f_sub_main
}
f_main

exit
