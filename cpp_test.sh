#!/bin/bash

make 

rm test*.pcap
rm output*.txt

for i in {1..2}; do
    # Calculate port number for this iteration
    port=$((startPort + i - 1))
    # Define the output file based on the iteration
    outputFile="/Users/qiuxutong/Desktop/Capstone/test${i}.pcap"
    
    osascript <<EOF
tell application "Terminal"
    set commandString to "socat TCP-LISTEN:1234,reuseaddr - > $outputFile"
    set newWindow to do script commandString
    delay 1 # Give the window a second to open
end tell
EOF

done

./a.out &

sleep 5
echo "Terminating..."
killall Terminal

./read_output

grep "packets" output*.txt