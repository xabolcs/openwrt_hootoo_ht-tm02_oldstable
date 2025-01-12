## Overview

This repository contains a few simple patch to allow a few `ramips/rt305x` Sunvalleytek Tripmate devices to be flashed with **stock compatible flash layout** custom OpenWrt build.

It builds the images using the [OpenWrt ImageBuilder](https://openwrt.org/docs/guide-user/additional-software/imagebuilder). One advantage of this over from-source custom builds is that the kernel is the same as the official builds, so all kmods from the standard repos are installable.

The only difference between these firmwares and the offical HT-TM02 firmware is the [installation method](https://openwrt.org/toh/hootoo/ht-tm01_tripmate#installation): the firmwares in this repository need to be installed with TFTP recovery. 

And because of this, you should never ever cross upgrade between official OpenWrt build and this custom build!


## Supported devices

| Vendor | Model | Vendor Product Line | Stock firmware | Stock backup <small>from a random user</small> | OpenWrt Wiki device page |
| --- | --- | --- | --- | --- | --- |
| HooToo | HT-TM01 (WIP) | `WiFiDGRJ` | ... | [backup-fw-WiFiDGRJ-HooToo-TM01-2.000.022-8850118661](https://drive.google.com/drive/folders/1XiEWeimv5pPtHeueD4U0fTVdcnYSKeeL?usp=sharing) | [HooToo HT-TM01 (TripMate)](https://openwrt.org/toh/hootoo/ht-tm01_tripmate) |
| HooToo | HT-TM02 | `WiFiPort` | ... | [backup-fw-WiFiPort-HooToo-TM02-2.000.018-8850119415](https://drive.google.com/drive/folders/1PnhUEnPvaC5h0kxtm30y-SiWqHzyFvty?usp=sharing) | [HooToo HT-TM02 (TripMate Nano)](https://openwrt.org/toh/hootoo/tripmate-nano) |

### Work in progress devices

#### HooToo HT-TM01

##### LEDs
The blue led is stronger than the green! :D
They can work independently but when both blue and green are ON, then only blue led lights.

##### I2C
The device has an HT66F30 chip, but I don't even know how to enable it:

```
# dmesg |grep i2c
[   23.142156] i2c /dev entries driver
[   23.166426] rt2880-pinmux pinctrl: pin io1 already requested by pinctrl; cannot claim for 10000900.i2c
[   23.185198] rt2880-pinmux pinctrl: pin-1 (10000900.i2c) status -22
[   23.197612] rt2880-pinmux pinctrl: could not request pin 1 (io1) from group i2c  on device rt2880-pinmux
[   23.216590] i2c-ralink 10000900.i2c: Error applying setting, reverse things back
[   23.231457] i2c-ralink: probe of 10000900.i2c failed with error -22
```


## Download firmware

See the [releases page](https://github.com/xabolcs/openwrt_hootoo_ht-tm02_oldstable/releases) for links to the firmware images.

These are built using [this Github workflow](./.github/workflows/build_release_images.yml). You can see the build logs for a few days [here](https://github.com/xabolcs/openwrt_hootoo_ht-tm02_oldstable/actions?query=workflow%3ABuild-Release-Images).


## Installing

Create a system backup first, write file `EnterRouterMode.sh` from [here](https://forum.openwrt.org/t/hootoo-ht-tm01-how-to-flash-stock-firmware/31436/50) to a USB stick (needs not be empty), and insert it to the device while it's running. This script will create a new folder on the USB stick with copies of the device's original partitions.

After you placed the backup to a safe place choose the `kernel.bin` and `rootfs.bin` for your device and follow the [TFTP recovery installation instructions](https://openwrt.org/toh/hootoo/ht-tm01_tripmate#installation)!


## Building

If you want to build the firmwares yourself, checkout this repo and do the following.

```
make
```

The firmware will be located at `openwrt-imagebuilder-*-ramips-rt305x.Linux-x86_64/bin/targets/ramips/rt305x/`. To customize the firmware further (packages etc), see the ImageBuilder wiki.
