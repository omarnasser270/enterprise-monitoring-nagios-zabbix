# Zabbix setup (zabbix01, 192.168.56.11)

Zabbix 7.0 LTS on Ubuntu 22.04 with MySQL and Apache. These are the standard steps from the official
Zabbix documentation for this stack; adjust names or passwords to your own values.

```bash
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu22.04_all.deb
sudo dpkg -i zabbix-release_latest_7.0+ubuntu22.04_all.deb
sudo apt update
sudo apt install -y mysql-server zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
```

Create the database (see `zabbix/sql/create-zabbix-db.sql`), import the schema, then disable the temporary option:

```bash
sudo mysql < zabbix/sql/create-zabbix-db.sql
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | sudo mysql --default-character-set=utf8mb4 -uzabbix -p zabbix
sudo mysql -e "SET GLOBAL log_bin_trust_function_creators = 0;"
```

Set `DBPassword` (and `EnableGlobalScripts=1`, see `zabbix/server/server-settings.md`) in `/etc/zabbix/zabbix_server.conf`, then:

```bash
sudo systemctl restart zabbix-server zabbix-agent apache2
sudo systemctl enable zabbix-server zabbix-agent apache2
```

Finish the setup wizard at `http://192.168.56.11/zabbix`. Default login is `Admin` / `zabbix` (lab only, change it for anything real).

## Agents on the target VMs

On each of web01, app01, db01, generic01 (repo package as above):

```bash
sudo apt install -y zabbix-agent2
sudo sed -i -e 's/^Server=.*/Server=192.168.56.11/' -e 's/^ServerActive=.*/ServerActive=192.168.56.11/' -e "s/^Hostname=.*/Hostname=$(hostname)/" /etc/zabbix/zabbix_agent2.conf
sudo systemctl enable --now zabbix-agent2
```

Check from zabbix01 (`sudo apt install -y zabbix-get`):

```bash
for ip in 21 22 23 24; do echo -n "192.168.56.$ip -> "; zabbix_get -s 192.168.56.$ip -k agent.ping; done
```

Time sync (avoids the "System time is out of sync" trigger after VMs are halted and resumed):

```bash
sudo apt install -y chrony && sudo systemctl enable --now chrony && sudo chronyc makestep
```
