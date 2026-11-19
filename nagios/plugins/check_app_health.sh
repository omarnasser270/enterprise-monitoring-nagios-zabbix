#!/bin/bash

CODE=$(curl -s -o /dev/null -m 5 -w '%{http_code}' http://192.168.56.22:5000/health)

if [ "$CODE" = "200" ]; then
    echo "OK - API healthy (HTTP $CODE)"
    exit 0
elif [ "$CODE" = "503" ]; then
    echo "CRITICAL - API degraded (HTTP $CODE)"
    exit 2
elif [ "$CODE" = "000" ]; then
    echo "CRITICAL - cannot connect to API"
    exit 2
else
    echo "WARNING - unexpected HTTP code $CODE"
    exit 1
fi
