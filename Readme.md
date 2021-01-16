# OpenWrt/LEDE interfaces metrics to Influxdb
Simple scripts to push router's interfaces metrics to the influxdb's database.  
First `iface-metrics.sh` - main script to grab and push metrics.  
Second: `iface-metrics-wrapper.sh` - wrapper to help execute first one.
Especially to run the main script in the backgroud and grab metrics from all of the interfaces.

## Requirements
Installed additional packages:
- `findutils-xargs`
- `curl`
- `coreutils-nohup`

## How to use
1. Copy both scripts for example to the `/root/bin`
1. Make sure that scripts are executable
1. Update variables inside `grab-all-metrics.sh` script
1. Add these commands to startup:
```
nohup /root/bin/grab-all-metrics.sh > /tmp/grab-all-metrics.out &
echo $! > /var/run/grab-all-metrics.pid
```
1. Reboot or execute commands manually
