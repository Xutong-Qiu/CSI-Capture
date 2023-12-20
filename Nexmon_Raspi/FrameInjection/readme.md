# Frame injection using Raspberry Pi 3B+
Based on the [Nexmon](https://github.com/seemoo-lab/nexmon) tool and this [guide](https://github.com/seemoo-lab/nexmon/issues/505).

## A) Raspberry Pi OS installation (host PC)
### 1. On your host PC, download the "Raspberry Pi OS with desktop" image (Release date: October 30th 2021)

```
wget https://downloads.raspberrypi.org/raspios_armhf/images/raspios_armhf-2021-11-08/2021-10-30-raspios-bullseye-armhf.zip
```

### 2. Unpack the image and deploy it to the SD-Card

```
unzip 2021-10-30-raspios-bullseye-armhf.zip
```
```
sudo dd if=2021-10-30-raspios-bullseye-armhf.img of=/dev/$SDCARD bs=1M conv=fsync
```

Note: replace $SDCARD with the device node name corresponding to the sdcard on your host PC.


#### On MacBook
- Check the disks:
```
diskutil list
```
- If getting the "dd: /dev/disk4: Resource busy" error:
```
diskutil unmountDisk /dev/disk4
```

### 3. SSH setup.
Create an empty file called ssh, without any extension, on the boot partition of the SD card. This enables SSH access.

The default user name is "pi" and the default password is "raspberry".


## B) Packages and headers installation
### 0. Perform initial setup.
- Insert the SD card into your Raspberry Pi 3B+ and boot it.
- Connect the Pi using an Ethernet cable.
- Get its LAN IP address using LANScan apps/tools.
- ssh pi@ipaddr
- Initial setup using ```sudo raspi-config```:
  - Set up a new password.
  - Set up wireless network access: country, SSID, password.
 

## C) Nexmon installation
