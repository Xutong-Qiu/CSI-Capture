#!/bin/sh


IFACE5GHZ="wlan0"

echo "tcpdump -i ${IFACE5GHZ} port 5500 -l -w - | socat - TCP:192.168.51.200:1232"
echo ""

# tcpdump -i ${IFACE5GHZ} port 5500 -l -w - | socat - TCP:192.168.51.200:1232

date
tcpdump -i ${IFACE5GHZ} port 5500 -l -w - | socat - TCP:192.168.51.200:1232 &
ps aux | grep -E 'socat|tcpdump'

sleep 5
pkill tcpdump
ps aux | grep -E 'socat|tcpdump'
date