-- Run on db01. Read-only monitoring user for the "MySQL by Zabbix agent 2" template.
-- Lab-only password. Host macros in Zabbix: {$MYSQL.USER}=zbx_monitor, {$MYSQL.PASSWORD}=<password below>
CREATE USER IF NOT EXISTS 'zbx_monitor'@'localhost' IDENTIFIED BY 'ZbxMon123!';
GRANT REPLICATION CLIENT, PROCESS, SHOW DATABASES, SHOW VIEW ON *.* TO 'zbx_monitor'@'localhost';
FLUSH PRIVILEGES;
