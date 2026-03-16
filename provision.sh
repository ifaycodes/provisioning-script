#!/bin/bash

#update packages
sudo apt update
sudo apt install wget unzip -y

#check and install aws cli
if aws --version 2>/dev/null; then
    echo "AWS CLI is available"
else 
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    echo "$(aws --version)"
fi


#install docker
if docker --version 2>/dev/null; then
    echo "Docker is installed"
else
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo systemctl start docker
    sudo systemctl enable docker
    echo "Docker was successfully installed"
fi

#install docker compose
sudo apt install docker-compose -y

#create the directory the application needs
sudo mkdir -p /srv/www

#check if mysql is mounted
if df -h | grep -q "mysql-data"; then
    echo "storage is mounted"
    #if not, format and mount it
else 
    sudo mkfs -t ext4 /dev/nvme1n1
    sudo cp -r /mnt/mysql-data /tmp/mysql-data
    sudo mount /dev/nvme1n1 /mnt/mysql-data

    if df -h | grep -q "mysql-data"; then
        echo "Storage is mounted!"
    else
        echo "Something is broken"
        exit 1
    fi
fi

#get permission so docker can access mnt/myql-data
sudo chmod 755 /mnt/mysql-data
sudo chown -R 999:999 /mnt/mysql-data