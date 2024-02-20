#!/bin/sh


IFACE5GHZ="wlan0"

echo "tcpdump -i ${IFACE5GHZ} port 5500 -l -w - | socat - TCP:192.168.51.200:1234"
echo ""

tcpdump -i ${IFACE5GHZ} port 5500 -l -w - | socat - TCP:192.168.51.200:1234