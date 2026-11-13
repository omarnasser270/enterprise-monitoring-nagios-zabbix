#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y python3-venv python3-pip

mkdir -p /opt/taskmanager
cp /vagrant/apps/flask-api/app.py /vagrant/apps/flask-api/requirements.txt /opt/taskmanager/
python3 -m venv /opt/taskmanager/venv
/opt/taskmanager/venv/bin/pip install -r /opt/taskmanager/requirements.txt
chown -R www-data:www-data /opt/taskmanager

cp /vagrant/configs/systemd/taskmanager.service /etc/systemd/system/taskmanager.service
systemctl daemon-reload
systemctl enable --now taskmanager
