# WiFi CSI Sniffer using ASUS RT-AC86U Router
Based on the [Nexmon CSI tool](https://github.com/nexmonster/nexmon_csi/tree/master).

## A) Installation


## B) Usage
### 1. Quick setup
- On the AP: Load the modified driver. This can be done **only once after a reboot**, reloading twice can crash the AP. To reload the driver enter the AP  using ssh, then:
  ```
  ./reload_5GHz.sh
     ```
- On the desktop: Live stream the .pcap data from the AP, and save it as a .pcap file, by monitoring the [PORT] port:
    ```
    socat TCP-LISTEN:[PORT],reuseaddr - > test.pcap
    ```
    Change the port as needed.
- On the AP:
  - Modify the /quick_set_livestream.sh file to set up the live-streaming parameter: [Desktop_IPaddr] is the desktop's LAN IP address and [PORT] is the same port as we set above.
    ```
    ./tcpdump -i ${IFACE5GHZ} port 5500 -l -w - | socat - TCP:[Desktop_IPaddr]:[PORT]
    ```
  - Configure the channel, bandwidth, rxcore (rx antennas, set to combination (or) of values [1|2|4|8]), rxnss (spatial streams), [macaddr] (mac address filter), [frametype] (frame control type filter):
    ```
    ./quick_setup_livestream_5GHz.sh channel bandwidth rxcore rxnss [macaddr] [frametype]
    ```
    Some examples:
    - ```./quick_setup_livestream_5GHz.sh 36 80 1 1```
    - ```./quick_setup_livestream_5GHz.sh 36 80 3 1 11:22:33:44:55:66 0x80```

### 2. Detailed commands



