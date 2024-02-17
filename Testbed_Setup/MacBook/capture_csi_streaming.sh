#!/bin/bash

make 
rm test*.pcap
rm output*.txt

output_dir="/Users/gaofengdong/Desktop/JCAS/Testbed_Setup/MacBook/outputs"

startPort=1230
for i in {1..6}; do
    # Define the output file based on the iteration
    outputFile="$output_dir/sniffer${i}.pcap"
    windowName="capture${i}"
    port=$((startPort + i))
    osascript <<EOF
tell application "Terminal"
    set windowName to do script "socat TCP-LISTEN:$port,reuseaddr - > $outputFile"
    delay 0.1
end tell
EOF
done

date
./a.out

#change here to modify capture length
sleep 23
date
echo "Terminating and saving .pcap files..."
killall Terminal

echo "Output..."
./read_output
grep "captured" outputs/output*.txt

#not working
# #read output.txt from sniffers
# IPaddrs_sniffers=("192.168.51.91" "192.168.51.195" "192.168.51.196" "192.168.51.148" "192.168.51.167" "192.168.51.161")
# echo "Reading output.txt from sniffers..."
# for i in {0..5}; do
#     scp pi@${IPaddrs_sniffers[$i]}:~/output.txt $output_dir/output${i+1}.txt
#     sleep 0.5
# done

# exit 0
