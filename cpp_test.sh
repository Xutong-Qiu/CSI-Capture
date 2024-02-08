#!/bin/bash

make 

rm test*.pcap
rm output*.txt

startPort=1234
for i in {1..5}; do
    # Define the output file based on the iteration
    outputFile="/Users/qiuxutong/Desktop/Capstone/test${i}.pcap"
    windowName="capture${i}"
    port=$((startPort + i))
    osascript <<EOF
tell application "Terminal"
    set windowName to do script "socat TCP-LISTEN:$port,reuseaddr - > $outputFile"
    delay 1 
end tell
EOF
done

./a.out &

sleep 5
echo "Terminating..."
killall Terminal

./read_output

grep "packets" output*.txt