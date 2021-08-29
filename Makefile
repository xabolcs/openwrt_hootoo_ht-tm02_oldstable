# This Makefile downloads the OpenWRT Image Builder and builds an image
# for the HooToo HT-TM02 with a custom partition layout and DTS file.

ALL_CURL_OPTS := $(CURL_OPTS) -L --fail --create-dirs

BOARD := ramips
SUBTARGET := rt305x
#SOC :=
DTS := HT-TM01
RELEASE := 19.07.8
BUILDER := openwrt-imagebuilder-$(RELEASE)-$(BOARD)-$(SUBTARGET).Linux-x86_64
PROFILE := ht-tm01
#DEVICE_DTS := $(SOC)_$(PROFILE)
DEVICE_DTS := $(DTS)
PACKAGES := iw luci nano dmesg -wpad-mini -wpad-basic -wpad-basic-wolfssl wpad-mesh-wolfssl kmod-rt2800-usb dnsmasq
EXTRA_IMAGE_NAME := custom
FILES := $(CURDIR)/files

TOPDIR := $(CURDIR)/$(BUILDER)
KDIR := $(TOPDIR)/build_dir/target-mipsel_24kc_musl/linux-$(BOARD)_$(SUBTARGET)
PATH := $(TOPDIR)/staging_dir/host/bin:$(PATH)
LINUX_VERSION = $(shell sed -n -e '/Linux-Version: / {s/Linux-Version: //p;q}' $(BUILDER)/.targetinfo)


all: images


$(BUILDER).tar.xz:
	curl $(ALL_CURL_OPTS) -O https://downloads.openwrt.org/releases/$(RELEASE)/targets/$(BOARD)/$(SUBTARGET)/$(BUILDER).tar.xz
	

$(BUILDER): $(BUILDER).tar.xz
	tar -xf $(BUILDER).tar.xz

	# Apply all patches
	$(foreach file, $(sort $(wildcard patches/*.patch)), patch -d $(BUILDER) -p1 < $(file);)

	# Regenerate .targetinfo
	cd $(BUILDER) && make -f include/toplevel.mk TOPDIR="$(TOPDIR)" prepare-tmpinfo || true
	cp -f $(BUILDER)/tmp/.targetinfo $(BUILDER)/.targetinfo

	# Copy updated base-files
	mkdir -p $(FILES)/etc
	cp -pvur $(BUILDER)/target/linux/$(BOARD)/base-files/etc/board.d $(FILES)/etc/
	cp -pvur $(BUILDER)/target/linux/$(BOARD)/base-files/lib $(FILES)

linux-include: $(BUILDER)
	# Fetch DTS include dependencies
	curl $(ALL_CURL_OPTS) "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/include/dt-bindings/gpio/gpio.h?h=v$(LINUX_VERSION)" -o linux-include/dt-bindings/gpio/gpio.h
	curl $(ALL_CURL_OPTS) "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/include/dt-bindings/input/input.h?h=v$(LINUX_VERSION)" -o linux-include/dt-bindings/input/input.h
	curl $(ALL_CURL_OPTS) "https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/include/uapi/linux/input-event-codes.h?h=v$(LINUX_VERSION)" -o linux-include/dt-bindings/input/linux-event-codes.h


$(KDIR)/$(PROFILE)-kernel.bin: $(BUILDER) linux-include
	# Build this device's DTB and firmware kernel image. Uses the official kernel build as a base.
	ln -sf /usr/bin/cpp $(BUILDER)/staging_dir/host/bin/mipsel-openwrt-linux-musl-cpp
	cp -Trf linux-include $(KDIR)/linux-$(LINUX_VERSION)/include
	cd $(BUILDER) && env PATH=$(PATH) make --trace -C target/linux/$(BOARD)/image $(KDIR)/$(PROFILE)-kernel.bin TOPDIR="$(TOPDIR)" INCLUDE_DIR="$(TOPDIR)/include" TARGET_BUILD=1 BOARD="$(BOARD)" SUBTARGET="$(SUBTARGET)" PROFILE="$(PROFILE)" DEVICE_DTS="$(DEVICE_DTS)"


images: $(BUILDER) $(KDIR)/$(PROFILE)-kernel.bin
	# Use ImageBuilder as normal
	cd $(BUILDER) && make image PROFILE="$(PROFILE)" EXTRA_IMAGE_NAME="$(EXTRA_IMAGE_NAME)" PACKAGES="$(PACKAGES)" FILES="$(FILES)"
	cat $(BUILDER)/bin/targets/$(BOARD)/$(SUBTARGET)/sha256sums
	ls -hs $(BUILDER)/bin/targets/$(BOARD)/$(SUBTARGET)/openwrt-*.bin


clean:
	rm -rf openwrt-imagebuilder-*
	rm -rf linux-include
