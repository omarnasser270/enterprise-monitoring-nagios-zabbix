# Zabbix server settings (zabbix01)

Only the lines that differ from the defaults in `/etc/zabbix/zabbix_server.conf`.
The full file is not committed because it contains the database password.

```
DBName=zabbix
DBUser=zabbix
DBPassword=<db_password>
EnableGlobalScripts=1
```

`EnableGlobalScripts=1` is required for the "Log alert" action script to run on the
Zabbix server. In recent 7.0 packages script execution on the server is disabled by default
(error: `Global script execution on Zabbix server is disabled by server configuration`).
Enable it in a lab only; in production prefer media types (email, chat) over server-side scripts.
