# Capture/Sniff CSI using Raspberry Pi 3B+
Based on [Nexmon_CSI](https://github.com/nexmonster/nexmon_csi/tree/pi-5.10.92#usage).

## A) Raspberry Pi OS installation (host PC)
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
- ssh pi@itsipaddr
- Initial setup using ```sudo raspi-config```:
  - Set up a new password.
  - Set up wireless network access: country, SSID, password.
- Set up SSH keys for automatic login
  - ssh-copy-id pi@itsipaddr
