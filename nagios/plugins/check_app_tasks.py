#!/usr/bin/env python3
import json
import sys
import urllib.request

URL = "http://192.168.56.22:5000/metrics-custom"
WARN = 10
CRIT = 20

try:
    with urllib.request.urlopen(URL, timeout=5) as r:
        data = json.load(r)
except Exception as e:
    print(f"CRITICAL - cannot read {URL}: {e}")
    sys.exit(2)

pending = data["tasks_pending"]

if pending >= CRIT:
    print(f"CRITICAL - {pending} pending tasks")
    sys.exit(2)
elif pending >= WARN:
    print(f"WARNING - {pending} pending tasks")
    sys.exit(1)
else:
    print(f"OK - {pending} pending tasks")
    sys.exit(0)
