# Copyright (C) 2020 Rumen G. Bogdanovski
# All rights reserved.
#
# You can use this software under the terms of MIT license (see LICENSE).

# Build test executable
DEBUG_BUILD = -g

CFLAGS = $(DEBUG_BUILD) -O3 -std=gnu11
LDFLAGS = -lpthread

all: deadlock_test

deadlock_test: deadlock_test.c
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

.PHONY: clean

clean:
	rm -rf deadlock_test __pycache__

# Debian package build
INSTALL_PREFIX=/usr/local
PACKAGE_NAME=indigo-deadlock-detector
PACKAGE_VERSION=0.2
BUILD_NO=1
DEBIAN_ARCH=all
FULL_NAME=$(PACKAGE_NAME)-$(PACKAGE_VERSION)-$(BUILD_NO)-$(DEBIAN_ARCH)

package: $(FULL_NAME).deb

deb-prepare:
	install -d /tmp/$(FULL_NAME)/$(INSTALL_PREFIX)/bin
	install -d /tmp/$(FULL_NAME)/$(INSTALL_PREFIX)/share/$(PACKAGE_NAME)
	install gdb_deadlock_script /tmp/$(FULL_NAME)/$(INSTALL_PREFIX)/share/$(PACKAGE_NAME)
	install gdb_deadlock_detector.py /tmp/$(FULL_NAME)/$(INSTALL_PREFIX)/share/$(PACKAGE_NAME)
	install indigo_deadlock_detector.sh /tmp/$(FULL_NAME)/$(INSTALL_PREFIX)/bin/indigo_deadlock_detector
	sed -i "s+GDB_SCRIPT_PATH=\".\"+GDB_SCRIPT_PATH=$(INSTALL_PREFIX)/share/$(PACKAGE_NAME)+g" /tmp/$(FULL_NAME)/$(INSTALL_PREFIX)/bin/indigo_deadlock_detector
	install README.md /tmp/$(FULL_NAME)/$(INSTALL_PREFIX)/share/$(PACKAGE_NAME)

$(FULL_NAME).deb: deb-prepare
	install -d /tmp/$(FULL_NAME)/DEBIAN
	printf "Package: $(PACKAGE_NAME)\nVersion: $(PACKAGE_VERSION)-$(BUILD_NO)\nInstalled-Size: $(shell echo $$((`du -s /tmp/$(FULL_NAME) | cut -f1`)))\nPriority: optional\nArchitecture: $(DEBIAN_ARCH)\nMaintainer: INDIGO Community\nDepends: gdb\nDescription: Indigo deadlock detector\n" > /tmp/$(FULL_NAME)/DEBIAN/control
	printf "#!/bin/bash\ncd $(INSTALL_PREFIX)/share/$(PACKAGE_NAME) && rm -rf __pycache__" >/tmp/$(FULL_NAME)/DEBIAN/prerm
	chmod +x /tmp/$(FULL_NAME)/DEBIAN/prerm
	sudo chown root /tmp/$(FULL_NAME)
	dpkg --build /tmp/$(FULL_NAME)
	mv /tmp/$(FULL_NAME).deb .
	sudo rm -rf /tmp/$(FULL_NAME)
	echo "Created: $(FULL_NAME).deb"
