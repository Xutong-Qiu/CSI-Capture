#!/bin/sh

DEST_IP=$1
DEST_PORT=$2

echo "tcpdump -i wlan0 port 5500 -l -w - | socat - TCP:$DEST_IP:$DEST_PORT"
echo ""

tcpdump -i wlan0 port 5500 -l -w - | socat - TCP:$DEST_IP:$DEST_PORT