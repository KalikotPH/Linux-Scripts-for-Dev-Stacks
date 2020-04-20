#!/bin/bash
# Script author: Bytes Crafter
# Script site: https://www.bytescrafter.net
# Script date: 19-04-2020
# Script ver: 1.0
# Script use to install Redis and Node including NPM.
#--------------------------------------------------
# Software version:
# 1. OS: 10.3 (Buster) 64 bit
# 2. REDIS: 5.0.2
# 3. NODEJS: 12.16.2
# 4. NPM: 6.*
#--------------------------------------------------
# List function:
# 1. f_check_root: check to make sure script can be run by user root
# 2. f_install_all: check to make sure script can be run by user root

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

# Installng nodejs, npm, and redis.
f_install_all() {
    echo "USocketNet: Installing Node and Redis ..."
    echo ""
    sleep 1
    apt install redis-server -y
    apt install curl software-properties-common -y
    curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
    apt install nodejs -y
    echo "USocketNet: NodeJS version is "
    node -v
    echo "USocketNet: NPM version is "
    npm -v
    echo ""
    sleep 1

    echo "USocketNet: Installing Node and Redis ..."
    echo ""
    sleep 1
    apt install sudo ufw net-tools vim -y
    sudo ufw allow 22
    sudo ufw allow 80
    sudo ufw allow 19090
    sudo ufw allow 6060
    sudo ufw allow 9090
    sudo ufw enable -y
    sudo ufw reload
    echo ""
    sleep 1
}

# The main function
f_main() {
    f_check_root
    f_install_all
}
f_main

exit