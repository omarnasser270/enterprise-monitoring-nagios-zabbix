#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y apache2 snmpd snmp

# Apache on port 8080
sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf
sed -i 's/<VirtualHost \*:80>/<VirtualHost *:8080>/' /etc/apache2/sites-available/000-default.conf
echo "<h1>Internal Status: $(hostname)</h1>" > /var/www/html/index.html
systemctl enable apache2
systemctl restart apache2

# SNMP (lab only: simple community string)
cat > /etc/snmp/snmpd.conf <<'EOF'
agentAddress udp:161
rocommunity monitor 192.168.56.0/24
sysLocation Lab
sysContact admin@example.com
EOF
systemctl enable snmpd
systemctl restart snmpd

# cron heartbeat: updates the file modification time every minute
echo '* * * * * root touch /var/tmp/heartbeat' > /etc/cron.d/heartbeat
chmod 644 /etc/cron.d/heartbeat
touch /var/tmp/heartbeat
