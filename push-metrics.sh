#!/bin/sh

# awk -F'^:' 'NR>2{print $1}' /proc/net/dev

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

    bytes_recv=$(( ( ${recived_2} - ${recived_1} ) ))
    bytes_sent=$(( ( ${sent_2} - ${sent_1} ) ))

    #logger -t stats "[${timestamp}]:${interface} inbound=${bytes_recv} outbound=${bytes_sent}"
    #echo "[${timestamp}]:${interface} inbound=${in_speed} outbound=${out_speed}"

    curl -s -XPOST "${INFLUXDB}/write?db=${database}&precision=s" \
      --data-binary "net,host=${HOSTNAME},interface=${interface} bytes_recv=${bytes_recv},bytes_sent=${bytes_sent} ${timestamp}"
    sleep 5
  done;
done;
