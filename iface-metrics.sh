#!/bin/sh

INFLUXDB=${1}
HOSTNAME=${2}
DATABASE=${3}
shift; shift
INTERFACES=${@}

echo hostname: ${HOSTNAME}
echo influx url: ${INFLUXDB}
echo interfaces: ${INTERFACES}

logger -t iface-stats "Interfaces: ${INTERFACES} | Hostname: ${HOSTNAME} | InfluxDB url: ${INFLUXDB} | DB name: ${DATABASE}"

while true; do

  for interface in $INTERFACES ; do

    interface_stats=$(grep ${interface} /proc/net/dev | sed s/.*://)

    recived_1=$(echo ${interface_stats} | awk '{print $1}')
    sent_1=$(echo ${interface_stats} | awk '{print $9}')
    sleep 1

    timestamp=$(date +%s)
    interface_stats=$(grep $interface /proc/net/dev | sed s/.*://)

    recived_2=$(echo ${interface_stats} | awk '{print $1}')
    sent_2=$(echo ${interface_stats} | awk '{print $9}')

    bytes_recv=$(( ( ${recived_2} - ${recived_1} ) ))
    bytes_sent=$(( ( ${sent_2} - ${sent_1} ) ))

    curl -s -XPOST "${INFLUXDB}/write?db=${DATABASE}&precision=s" \
      --data-binary "net,host=${HOSTNAME},interface=${interface} bytes_recv=${bytes_recv},bytes_sent=${bytes_sent} ${timestamp}"
    sleep 5

  done;

done;
