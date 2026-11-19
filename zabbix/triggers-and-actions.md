# Triggers and actions

## Custom triggers on app01 (same thresholds as the Nagios `check_app_tasks.py` plugin)

| Name | Severity | Expression |
|---|---|---|
| Task backlog high (pending > 10) | Warning | `last(/app01/taskmanager.metric[tasks_pending])>10` |
| Task backlog critical (pending > 20) | High | `last(/app01/taskmanager.metric[tasks_pending])>20` |

## Auto registration actions (Alerts > Actions > Autoregistration actions)

| Action | Condition | Operations |
|---|---|---|
| Auto register - Web servers | Host metadata contains `web-server` | Add host, group `Lab Servers`, templates: Linux by Zabbix agent, ICMP Ping, Nginx by Zabbix agent |
| Auto register - Generic Linux | Host metadata contains `generic-linux` | Add host, group `Lab Servers`, templates: Linux by Zabbix agent, ICMP Ping |

## Trigger action

`Log problems`: runs the global script `Log alert` (see `zabbix/scripts/log-alert.txt`) on problem and on recovery.

## Hosts

| Host | Registration | Templates / extras |
|---|---|---|
| app01 | manual | Linux by Zabbix agent, ICMP Ping, 3 custom items (UserParameter) |
| db01 | manual | Linux by Zabbix agent, ICMP Ping, MySQL by Zabbix agent 2 (macros `{$MYSQL.USER}`, `{$MYSQL.PASSWORD}`) |
| web01 | auto registration | Linux by Zabbix agent, ICMP Ping, Nginx by Zabbix agent |
| generic01 | auto registration | Linux by Zabbix agent, ICMP Ping, plus SNMP interface with Linux by SNMP (`{$SNMP_COMMUNITY}`) |
