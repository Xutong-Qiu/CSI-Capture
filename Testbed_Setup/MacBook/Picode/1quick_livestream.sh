#!/bin/sh

IFACE5GHZ="wlan0"

echo "tcpdump -i ${IFACE5GHZ} port 5500 -l -w - | socat - TCP:192.168.51.200:1231"
echo ""

# tcpdump -i ${IFACE5GHZ} port 5500 -l -w - | socat - TCP:192.168.51.200:1231

date
tcpdump -i ${IFACE5GHZ} port 5500 -l -w - | socat - TCP:192.168.51.200:1231 &
ps aux | grep -E 'socat|tcpdump'

sleep 5
pkill tcpdump
ps aux | grep -E 'socat|tcpdump'
date