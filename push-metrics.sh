#!/bin/sh

INFLUXDB=${1}
HOSTNAME=${2}
shift; shift
INTERFACES=${@}
database="network"

echo hostname: ${HOSTNAME}
echo influx url: ${INFLUXDB}
echo interfaces: ${INTERFACES}

while true; do
  for interface in $INTERFACES ; do
    interface_stats=$(grep $interface /proc/net/dev | sed s/.*://)
    recived_1=$(echo ${interface_stats} | awk '{print $1}')
    sent_1=$(echo ${interface_stats} | awk '{print $9}')
    sleep 1
    timestamp=$(date +%s)
    interface_stats=$(grep $interface /proc/net/dev | sed s/.*://)
    recived_2=$(echo ${interface_stats} | awk '{print $1}')
    sent_2=$(echo ${interface_stats} | awk '{print $9}')
    in_speed=$(( ( ${recived_2} - ${recived_1} ) / 1024 ))
    out_speed=$(( ( ${sent_2} - ${sent_1} ) / 1024))
    curl -s -XPOST "${INFLUXDB}/write?db=${database}&precision=s" --data-binary "bandwidth,host=${HOSTNAME},interface=${interface} inbound=${in_speed},outbound=${out_speed} ${timestamp}"
  done;
done;
