#!/bin/bash
output_dir="/Users/gaofengdong/Desktop/JCAS/Testbed_Setup/MacBook/outputs"

make 
rm ./outputs/*.pcap
rm ./outputs/*.txt

# exit 0

startPort=1230
for i in {1..6}; do
    # Define the output file based on the iteration
    outputFile="$output_dir/sniffer${i}.pcap"
    windowName="capture${i}"
    port=$((startPort + i))
    osascript <<EOF
    
tell application "Terminal"
    set windowName to do script "socat TCP-LISTEN:$port,reuseaddr - | pv -trab > $outputFile"
    delay 0.5
end tell
EOF
done

date
./ssh_execute

#change here to modify capture length
sleep 13
date
echo ""
echo "Terminating and saving .pcap files..."
killall Terminal

#read output.txt from sniffers
echo "Output..."
./read_output
# grep "captured" outputs/output*.txt
for i in {1..6}; do
    printf "Sniffer${i}: "
    awk 'NR==3 {printf "Start time:%s ", $2}' "${output_dir}/output$((i)).txt"
    awk 'NR==11 {printf "End time:%s;  ", $2}' "${output_dir}/output$((i)).txt"
    grep "captured" outputs/output${i}.txt
done


#not working
# #read output.txt from sniffers
# IPaddrs_sniffers=("192.168.51.91" "192.168.51.195" "192.168.51.196" "192.168.51.148" "192.168.51.167" "192.168.51.161")
# echo "Reading output.txt from sniffers..."
# for i in {0..5}; do
#     scp pi@${IPaddrs_sniffers[$i]}:~/output.txt $output_dir/output${i+1}.txt
#     sleep 0.5
# done

# exit 0
