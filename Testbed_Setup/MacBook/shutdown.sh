set_up_destination_dir="./quick_setup.sh"
livestream_destination_dir="./livestream.sh"
addr=(91 195 196 148 167 161)
for i in "${!addr[@]}"; do
    ssh pi@${host_ip} "sudo shutdown now"
    echo "${host_ip} has been shutdown"
done
