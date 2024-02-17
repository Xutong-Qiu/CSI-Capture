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
echo "Terminating..."
killall Terminal

echo "Output..."
./read_output
grep "captured" outputs/output*.txt
