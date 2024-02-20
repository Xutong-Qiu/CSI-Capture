#!/bin/bash

rm -r PiCode

# Ask the user for the IP address
echo "Enter the IP address for live streaming:"
read live_ip

# Create the PiCode directory if it doesn't exist
mkdir -p ./PiCode

start_port=1230
# Copy the script 5 times with different names
for i in {1..6}; do
  cp quick_setup_livestream_5GHz.sh "./PiCode/${i}quick_setup_livestream_5GHz.sh"

  new_port=$((start_port + i))

  sed -i '' "s/PORT_PLACEHOLDER/$new_port/" "./PiCode/${i}quick_setup_livestream_5GHz.sh"
  sed -i '' "s/IP_ADDRESS_PLACEHOLDER/$live_ip/" "./PiCode/${i}quick_setup_livestream_5GHz.sh"
done

echo "Scripts have been customized and copied to ./PiCode."