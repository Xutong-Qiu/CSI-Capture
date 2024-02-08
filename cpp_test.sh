#!/bin/bash
osascript <<EOF
tell application "Terminal"
    set pi1Listening to do script "socat TCP-LISTEN:1234,reuseaddr - > /Users/qiuxutong/Desktop/Capstone/test1.pcap"
    delay 1 # Give the window a second to open
end tell
EOF

echo "start listening Pi1..."

sleep 1

osascript <<EOF
tell application "Terminal"
    set pi2Listening to do script "socat TCP-LISTEN:12345,reuseaddr - > /Users/qiuxutong/Desktop/Capstone/test2.pcap"
    delay 1 # Give the window a second to open
end tell
EOF

echo "start listening Pi2..."

sleep 1

make 
./a.out &

sleep 5
echo "Terminating..."
killall Terminal

./read_output

cat pi1_output.txt | grep packets
cat pi2_output.txt | grep packets