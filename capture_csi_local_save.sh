#!/bin/bash

make 
rm output*.pcap
rm output*.txt

./a.out &

#change here to modify capture length
sleep 20

addr=(98 125 207 247 20)
# Use a for loop to iterate through the array indices
for i in "${!addr[@]}"; do
    # Define the output file based on the iteration
    outputFile="/Users/qiuxutong/Desktop/Capstone/output_test$(($i + 1)).pcap"
    # Use the address from the array and the correct outputFile path in the scp command
    scp pi@192.168.51.${addr[$i]}:output.pcap "$outputFile"
done
