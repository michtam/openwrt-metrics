#!/bin/sh
SCRIPT="/root/bin/iface-metrics.sh"
HOSTNAME="gateway.local"
INFLUXDB_URL="http://influxdb.local:8086"
DB_NAME="network"

# waiting for all interfaces especially wlan0/1
sleep 30

awk -F':' 'NR>2{print $1}' /proc/net/dev | xargs -n 1 -P 12 ${SCRIPT} ${INFLUXDB_URL} ${HOSTNAME} ${DB_NAME}
