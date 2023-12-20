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


## B) Header installation
### 1. Perform initial setup.
- Insert the SD card into your Raspberry Pi 3B+ and boot it.
- Connect the Pi using an Ethernet cable.
- Get its LAN IP address using LANScan apps/tools.
- ssh pi@ipaddr
- Initial setup using ```sudo raspi-config```:
  - Set up a new password.
  - Set up wireless network access: country, SSID, password.

### 2. Copy Linux headers for 5.10.63-v7+ kernel.
Note: ```sudo apt install raspberrypi-kernel-headers``` will install newer headers incompatible with the kernel/Nexmon codes. Therefore, we manually download and copy the headers.

Check the kernel version: 
```
uname -r
```
For the OS we use, it's 5.10.63-v7+.

All the raspi firmwares/headers are here: [link](https://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/).
Since the release date of the OS we use is October 30th 2021, we downloaded the "raspberrypi-kernel-headers_1.20211118-1_armhf.deb", and found the header files (linux-headers-5.10.63-v7+) under ```data/usr/src/```. You may download the header [here](https://drive.google.com/file/d/1i26VqE_eg4gF0iBQc5-3qULhTLEkR1I8/view?usp=sharing) directly. Then send it to Raspi.

#### On MacBook:
```
scp linux-headers-5.10.63-v7+.zip pi@ipaddr:~
```
#### On Raspi:
```
unzip linux-headers-5.10.63-v7+.zip
sudo mv linux-headers-5.10.63-v7+ /usr/src/
```

## C) Nexmon installation
### 1. Install packages as required for nexmon
```
sudo apt update
sudo apt install git libgmp3-dev gawk qpdf bison flex make
```
Note: if not installing these packages, below errors may appear for the first "make" below:

"
make[2]: *** No rule to make target 'parser.c', needed by 'dep/parser.d'.  Stop.

make[2]: Leaving directory '/home/pi/nexmon/buildtools/b43/assembler'

make[1]: *** [Makefile:21: b43/assembler/b43-asm.bin] Error 2

make[1]: Leaving directory '/home/pi/nexmon/buildtools'

make: *** [Makefile:9: buildtools] Error 2
"

### 2. Library version miss-match work-around

```
sudo ln -s /usr/src/linux-headers-5.10.63-v7+ /lib/modules/$(uname -r)/build
cd /usr/lib/arm-linux-gnueabihf/
sudo ln -s libisl.so.23.0.0 libisl.so.10
sudo ln -s libmpfr.so.6.1.0 libmpfr.so.4
cd $HOME
```

### 3. Fetch nexmon with kernel 5.10 support

```
git clone https://github.com/mildsunrise/nexmon.git
cd nexmon
git checkout cea7c4b952b3e67110dc1032b8996dae0db9a857
```

### 4. Build firmware and kernel module
```
source setup_env.sh
make
cd patches/bcm43455c0/7_45_206/nexmon
make
```

Note: If meeting errors: "make[1]: *** /lib/modules/5.10.63-v7+/build: No such file or directory.  Stop."
- In step 2, create the Symlink:
```sudo ln -s /usr/src/linux-headers-5.10.63-v7+ /lib/modules/$(uname -r)/build```
- Verify the Symlink:
```ls -l /lib/modules/$(uname -r)/build```. The output looks like "lrwxrwxrwx 1 root root 34 Dec 20 02:09 /lib/modules/5.10.63-v7+/build -> /usr/src/linux-headers-5.10.63-v7+".


### 5. Backup original firmware and kernel module (optional)
```
sudo mv /lib/firmware/cypress/cyfmac43455-sdio.bin /lib/firmware/cypress/cyfmac43455-sdio.bin.orig
sudo mv /lib/modules/5.10.63-v7+/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko /lib/modules/5.10.63-v7+/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac/brcmfmac.ko.orig
```
### 6. Install firmware and kernel module
```
sudo cp brcmfmac43455-sdio.bin /lib/firmware/cypress/cyfmac43455-sdio.bin
sudo cp brcmfmac_5.10.y-nexmon/brcmfmac.ko /lib/modules/5.10.63-v7+/kernel/drivers/net/wireless/broadcom/brcm80211/brcmfmac
```
### 7. Reboot
```
sudo reboot
```


## D) Injection example

### 1. Transfer the injection example to the Raspberry Pi and compile it
```
gcc -O2 -o inject inject.c
```

### 2. Enable WiFi monitor mode 

#### Run the quick script directly:
```
./enable_monitormode.sh
```
#### Or run the detailed commands separately:
```
sudo wpa_cli terminate
sudo ifconfig wlan0 down
sudo iw phy `iw dev wlan0 info | gawk '/wiphy/ {printf "phy" $2}'` interface add mon0 type monitor
sudo ifconfig mon0 up
```

Note: if meeting errors like "Wi-Fi is currently blocked by rfkill", use raspi-config (```sudo raspi-config```) to set the country first.


### 3. Set the channel and inject beacon frames
#### Run the quick script to set the channel and interval directly:
```
./inject_beaconframes channel interval_ms
```
An example is ```./inject_beaconframes.sh 36 10```.

Note: the delay/interval is roughly estimated, doesn't mean the rate is exactly 100 Hz.

#### OR run the detailed commands separately:
- Set the channel
```
sudo iwconfig mon0 channel 1
```

- Inject one beacon

```
sudo ./inject -i mon0
```

- Inject beacons every 100 ms
```
sudo ./inject -i mon0 -d 100 -l
```

Note: press CTRL+C to stop
Note: a Wifi network with SSID "DEMO" should be visible by other WiFi devices.


