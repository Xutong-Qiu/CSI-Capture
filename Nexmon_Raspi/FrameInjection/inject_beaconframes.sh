#!/bin/sh

CHAN=$1
if [ "$CHAN" = "" ]; then
  echo "./inject_beaconframes channel interval_ms"
  exit 1
fi

INTERVAL=$2
if [ "$INTERVAL" = "" ]; then
  echo "./inject_beaconframes channel interval_ms"
  exit 1
fi

echo "Set channel to $CHAN"
sudo iwconfig mon0 channel $CHAN

echo "Injecting beacon frames every  $INTERVAL ms"
sudo ./inject -i mon0 -d $INTERVAL -l