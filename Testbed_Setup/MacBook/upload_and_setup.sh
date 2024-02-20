#!/bin/bash

set_up_destination_dir="./quick_setup.sh"
livestream_destination_dir="./livestream.sh"
addr=(91 195 196 148 167 161)
channels=(36 3 149 36 3 149)
bandwidths=(80 80 80 80 80 80)
tx_routers=(JCAS3-5G JCAS3-2.4G JCAS4 JCAS3-5G JCAS3-2.4G JCAS4)
for i in "${!addr[@]}"; do
    host_ip="192.168.51.${addr[$i]}"
    set_up_file_path="./pi_quick_setup.sh"
    livestream_file_path="./PiCode/$(($i + 1))livestream.sh"
    scp "$set_up_file_path" "pi@${host_ip}:${set_up_destination_dir}"
    scp "$livestream_file_path" "pi@${host_ip}:${livestream_destination_dir}"
    echo "File has been copied to ${host_ip}"
    ssh pi@${host_ip} "chmod 777 quick_setup.sh; sudo ./quick_setup.sh ${channels[$i]} ${bandwidths[$i]} 1 1 ${tx_routers[$i]}"
    echo "${host_ip} has been setup"
done


# 192.168.51.91  1231
#192.168.51.195 1232
#192.168.51.196 1233
#192.168.51.148 1234
#192.168.51.167 1235
#192.168.51.161 1236