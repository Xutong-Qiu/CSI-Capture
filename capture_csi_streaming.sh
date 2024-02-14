#!/bin/bash

make 
rm test*.pcap
rm output*.txt

startPort=1230
for i in {1..6}; do
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

./a.out

#change here to modify capture length
sleep 10

echo "Terminating..."
killall Terminal
./read_output

grep "packets" output*.txt


# unused test code
# socat TCP-LISTEN:1235,reuseaddr - > /Users/qiuxutong/Desktop/Capstone/test1.pcap&
# socat_pid1=$!
# socat TCP-LISTEN:1236,reuseaddr - > /Users/qiuxutong/Desktop/Capstone/test2.pcap&
# socat_pid2=$!
# socat TCP-LISTEN:1237,reuseaddr - > /Users/qiuxutong/Desktop/Capstone/test3.pcap&
# socat_pid3=$!
# socat TCP-LISTEN:1238,reuseaddr - > /Users/qiuxutong/Desktop/Capstone/test4.pcap&
# socat_pid4=$!
# socat TCP-LISTEN:1239,reuseaddr - > /Users/qiuxutong/Desktop/Capstone/test5.pcap&
# socat_pid5=$!
# sleep 2

# echo "here"
# kill $socat_pid1
# kill $socat_pid2
# kill $socat_pid3
# kill $socat_pid4
# kill $socat_pid5