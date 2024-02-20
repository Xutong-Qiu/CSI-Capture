#!/bin/sh

DEST_IP=$1
DEST_PORT=$2
TIME=$3

echo "tcpdump -i wlan0 port 5500 -l -w - | socat - TCP:$DEST_IP:$DEST_PORT"
echo ""


date +"%Y-%m-%d %H:%M:%S.%3N"
tcpdump -i wlan0 port 5500 -l -w - | socat - TCP:$DEST_IP:$DEST_PORT &
ps aux | grep -E 'socat|tcpdump'

sleep $TIME
pkill tcpdump
date +"%Y-%m-%d %H:%M:%S.%3N"

sleep 1
ps aux | grep -E 'socat|tcpdump'
