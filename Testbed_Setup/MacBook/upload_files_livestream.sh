#!/bin/bash

destination_dir="./livestream.sh"
addr=(91 195 196 148 167 161)
for i in "${!addr[@]}"; do
    host_ip="192.168.51.${addr[$i]}"
    file_path="./Picode/livestream_autostop.sh"
    echo $destination_dir
    scp "$file_path" "pi@${host_ip}:${destination_dir}"
    echo "File has been copied to ${host_ip}:${destination_dir}"
done

# Location 1
#1 192.168.51.91  1231
#2 192.168.51.195 1232
#3 192.168.51.196 1233

# Location 2
#4 192.168.51.148 1234
#5 192.168.51.167 1235
#6 192.168.51.161 1236


#AP1 JCAS3-5GHz, CH36:  a0:36:bc:b2:0b:94; Sniffer 1, 4
#AP1 JCAS3-2.4GHz, CH3: a0:36:bc:b2:0b:90; Sniffer 2, 5
#AP2 JCAS4-5GHz, CH149: 00:12:34:56:78:9b; Sniffer 3, 6
