# Nagios setup (nagios01, 192.168.56.10)

Nagios Core 4.5.14 is built from source on Ubuntu 22.04 (following the official Nagios Core installation guide),
with Apache for the web UI. This page covers what was added on top of the stock install.

## 1. Object definitions

The files in `nagios/config/` define the hosts and services (`web01.cfg`, `db01.cfg`, `app01.cfg`, `generic01.cfg`).
Copy them to a directory that `nagios.cfg` loads:

```bash
sudo mkdir -p /usr/local/nagios/etc/servers
sudo cp nagios/config/*.cfg /usr/local/nagios/etc/servers/
```

In `/usr/local/nagios/etc/nagios.cfg` make sure this line is active (not commented):

```
cfg_dir=/usr/local/nagios/etc/servers
```

Always validate before restarting. A typo in one file stops Nagios from starting:

```bash
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
sudo systemctl restart nagios
```

Naming rule learned the hard way: service descriptions must not contain `` ()=!$%^&*|'"<>?, ``.
A name like `Load (NRPE)` makes the configuration check fail.

## 2. Custom plugins

```bash
sudo cp nagios/plugins/check_app_health.sh nagios/plugins/check_app_tasks.py /usr/local/nagios/libexec/
sudo chown nagios:nagios /usr/local/nagios/libexec/check_app_*
sudo chmod +x /usr/local/nagios/libexec/check_app_*
```

A Nagios plugin prints one line and returns an exit code: `0` OK, `1` WARNING, `2` CRITICAL, `3` UNKNOWN.

| Plugin | What it checks | Result |
|---|---|---|
| `check_app_health.sh` | `GET /health` on the Flask API | HTTP 200 is OK, 503 or no connection is CRITICAL, anything else is WARNING |
| `check_app_tasks.py` | `pending` tasks from `/metrics-custom` | WARNING above 10, CRITICAL above 20, CRITICAL if the API is unreachable |

Test them by hand before adding them to Nagios:

```bash
/usr/local/nagios/libexec/check_app_health.sh; echo "exit code: $?"
/usr/local/nagios/libexec/check_app_tasks.py; echo "exit code: $?"
```

## 3. NRPE (local checks on app01 and generic01)

On each target VM install the NRPE server and the standard plugins, then add the lab commands:

```bash
sudo apt install -y nagios-nrpe-server monitoring-plugins-basic
sudo cp nagios/nrpe/app01-lab-checks.cfg /etc/nagios/nrpe.d/lab-checks.cfg    # generic01: generic01-lab-checks.cfg
sudo systemctl restart nagios-nrpe-server
```

`/etc/nagios/nrpe.cfg` must list the Nagios server in `allowed_hosts` (`192.168.56.10`).

| Host | NRPE commands |
|---|---|
| app01 | `lab_load`, `lab_disk_root`, `lab_gunicorn` |
| generic01 | `lab_load`, `lab_disk_root`, `lab_apache`, `lab_heartbeat` |

Test from nagios01:

```bash
/usr/local/nagios/libexec/check_nrpe -H 192.168.56.22 -c lab_load
/usr/local/nagios/libexec/check_nrpe -H 192.168.56.24 -c lab_heartbeat
```

### The heartbeat check and PrivateTmp

`lab_heartbeat` uses `check_file_age` on a file that a cron job touches every minute on generic01.
The first version used `/var/tmp/heartbeat` and always returned `File not found`, because the NRPE systemd unit runs with
`PrivateTmp=true` and sees its own private `/var/tmp`. The file now lives in `/var/lib/heartbeat`.

## 4. Other changes

- `check_swap` in `commands.cfg` uses `-n ok` because nagios01 has no swap partition (otherwise the check is CRITICAL).
- Notifications go to the local mailbox (postfix + mailutils); no external mail server is needed for the lab.

## 5. Soft and hard states

A failing check is first reported as `SOFT` and re-checked every minute. After 4 failed attempts it becomes `HARD`,
and only then are notifications sent. A service that recovers during the `SOFT` phase does not alert anyone.
The failure test in the README shows both cases.
