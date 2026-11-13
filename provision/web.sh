#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y nginx

mkdir -p /var/www/taskmanager
cp /vagrant/configs/nginx/index.html /var/www/taskmanager/index.html

cp /vagrant/configs/nginx/taskmanager.conf /etc/nginx/sites-available/taskmanager
ln -sf /etc/nginx/sites-available/taskmanager /etc/nginx/sites-enabled/taskmanager
rm -f /etc/nginx/sites-enabled/default

nginx -t
systemctl enable nginx
systemctl restart nginx
