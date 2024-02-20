#!/bin/sh

echo "tcpdump -i wlan0 port 5500 -l -w - | socat - TCP:192.168.51.200:1235"
echo ""

date +"%Y-%m-%d %H:%M:%S.%3N"

tcpdump -i wlan0 port 5500 -l -w - | socat - TCP:192.168.51.200:1235 &

ps aux | grep -E 'socat|tcpdump'

sleep 20
pkill tcpdump
date +"%Y-%m-%d %H:%M:%S.%3N"

sleep 1
ps aux | grep -E 'socat|tcpdump'