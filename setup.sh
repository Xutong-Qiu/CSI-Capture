#!/bin/bash

destination_dir="./quick_setup_livestream_5GHz.sh"
addr=(91 195 196 148 167 161)
for i in "${!addr[@]}"; do
    host_ip="192.168.51.${addr[$i]}"
    file_path="/Users/qiuxutong/Desktop/Capstone/pi\ code/$(($i + 1))quick_setup_livestream_5GHz.sh"
    echo $destination_dir
    scp "$file_path" "pi@${host_ip}:${destination_dir}"
    echo "File has been copied to ${host_ip}:${destination_dir}"
done


# 192.168.51.91  1231
#192.168.51.195 1232
#192.168.51.196 1233
#192.168.51.148 1234
#192.168.51.167 1235
#192.168.51.161 1236