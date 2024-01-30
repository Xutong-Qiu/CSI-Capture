# Capture/Sniff CSI using Raspberry Pi 3B+
Based on [Nexmon_CSI](https://github.com/nexmonster/nexmon_csi/tree/pi-5.10.92#usage).

## A) Raspberry Pi OS installation (on host PC)
### 1. On your host PC, download the "Raspberry Pi OS" image

```
wget https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-lite.zip
```

### 2. Unpack the image and deploy it to the SD-Card

```
unzip 2022-01-28-raspios-bullseye-armhf-lite.zip
```
Insert the SD card, and check the disk.
```
diskutil list
```
Unmount the SD card:
```
diskutil unmountDisk /dev/diskX
```
Write the image:
```
sudo dd if=2022-01-28-raspios-bullseye-armhf-lite.img of=/dev/$SDCARD bs=1M conv=fsync status=progress
```

Note: replace $SDCARD with the device node name corresponding to the sdcard on your host PC.


### 3. SSH setup.
Create an empty file called ssh, without any extension, on the boot partition of the SD card. This enables SSH access.

The default user name is "pi" and the default password is "raspberry".

### 4. Perform initial setup.
- Insert the SD card into your Raspberry Pi 3B+ and boot it.
- Connect the Pi to a router using an Ethernet cable.
- Get its LAN IP address using LANScan apps/tools or check on the router.
- Set up SSH keys for automatic login (on host PC)
  - ssh-copy-id pi@itsipaddr
- ssh pi@itsipaddr
- Initial setup using ```sudo raspi-config```:
  - Set up a new password.
  - Set up wireless network access: country.
  - (Optional) Set up timezone
    - Navigate to Localisation Options, select "Change Timezone". Choose "America" and press Enter. Then, select the city or region. Scroll down to find "Los_Angeles" and press Enter.
- (Optional) NTP setup for time synchronization among multiple devices.
  - Install NTP: `sudo apt install ntp`
  - Edit the NTP Configuration File: `sudo vi /etc/ntp.conf`
    - Here we are using UCLA NTP servers:
      ```
      server ntp-asm1.time.ucla.edu iburst
      server ntp-asm2.time.ucla.edu iburst
      server ntp-csb1.time.ucla.edu iburst
      server ntp-csb2.time.ucla.edu iburst
      ```
  - Restart the NTP Service: `sudo systemctl restart ntp`
  - Verify the Configuration: `ntpq -p`
    - "offset": The time difference, in milliseconds, between your Raspberry Pi's clock and the NTP server's clock.
    - "jitter": The variability (in milliseconds) in the query response times from the NTP server.

### 5. Install Nexmon_csi

Run the [install script](https://github.com/nexmonster/nexmon_csi_bin/blob/main/install.sh) from [Nexmon_csi_bin](https://github.com/nexmonster/nexmon_csi_bin).

```
curl -fsSL https://raw.githubusercontent.com/nexmonster/nexmon_csi_bin/main/install.sh | sudo bash
```

The script should take about a minute to run, reboot when it's done and go to the [Usage Section](#usage).


## B) Usage
1. Use **`mcp`** (_makecsiparams_) to generate a base64 encoded parameter string which is used to configure the extractor.
   This example collects CSI on **channel 36** with **bandwidth 80 MHz** on first core of the WiFi chip, for the first spatial stream.
   Raspberry Pi has only one core, and a single antenna, so the `-C`, and `-N` options don't need changing.
    ```
    mcp -C 1 -N 1 -c 36/80

    KuABEQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==
    ```
    `mcp` supports several other features like filtering data by Mac IDs or by FrameControl byte. Run `mcp -h` to see all available options.
2. `ifconfig wlan0 up`
3. `nexutil -Iwlan0 -s500 -b -l34 -vKuABEQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==`
4. `iw dev wlan0 interface add mon0 type monitor`
5. `ip link set mon0 up`

Collect CSI by listening on socket 5500 for UDP packets. One way to do this is using tcpdump:
`tcpdump -i wlan0 dst port 5500`. You can store 1000 CSI samples in a pcap file like this:
`tcpdump -i wlan0 dst port 5500 -vv -w output.pcap -c 1000`.

You will not be able to use the built in WiFi chip to connect to your WLAN, so use an Ethernet cable.
