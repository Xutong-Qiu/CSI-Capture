#!/bin/bash

file_path="./quick_setup_livestream_5GHz.sh"

host_ip="192.168.51.161"
# 192.168.51.91  1231
#192.168.51.195 1232
#192.168.51.196 1233
#192.168.51.148 1234
#192.168.51.167 1235
#192.168.51.161 1236
destination_dir="./quick_setup_livestream_5GHz.sh"

scp "$file_path" "pi@${host_ip}:${destination_dir}"

echo "File has been copied to ${host_ip}:${destination_dir}"
