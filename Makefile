PLATFORM=/Developer/Platforms/iPhoneOS.platform
SDKVER=3.1.3
SDK=$(PLATFORM)/Developer/SDKs/iPhoneOS$(SDKVER).sdk
CC=$(PLATFORM)/Developer/usr/bin/gcc-4.2
STRIP=$(PLATFORM)/Developer/usr/bin/strip

RAMDISK_IV=2e7aa9f6dc823657f1c930a00db8efe1
RAMDISK_KEY=9781d55350f58c3ff72c7a3e50b70288
RAMDISK_TEMPLATE=/Users/John/Desktop/3.1.3/018-6508-014.dmg

LAUNCHD_SOURCES=launchd/launchd.c launchd/syscall.S
RDKIT_SOURCES=rdkit/framebuffer.c

CFLAGS=-arch armv6 -isysroot $(SDK) -std=c99 -I./include
LDFLAGS=-F$(SDK)/System/Library/PrivateFrameworks \
	-framework CoreFoundation 

all: clean ramdisk/sbin/launchd ramdisk.dmg

ramdisk/sbin/launchd:
	$(CC) $(CFLAGS) -static -o ramdisk/sbin/launchd $(LAUNCHD_SOURCES) -nostdlib
	strip ramdisk/sbin/launchd
	ldid -S ramdisk/sbin/launchd

ramdisk.dmg:
	xpwntool $(RAMDISK_TEMPLATE) ./template-decrypted.dmg -k $(RAMDISK_KEY) -iv $(RAMDISK_IV)
	hdid template-decrypted.dmg
	rm -rf /Volumes/ramdisk/*
	cp -R ramdisk/* /Volumes/ramdisk/
	sudo chown 0:0 /Volumes/ramdisk/sbin/launchd
	sudo chmod 0755 /Volumes/ramdisk/sbin/launchd
	umount /Volumes/ramdisk
	xpwntool template-decrypted.dmg ramdisk.dmg -k $(RAMDISK_KEY) -iv $(RAMDISK_IV) -t $(RAMDISK_TEMPLATE)
	rm template-decrypted.dmg

clean:
	rm -rf ramdisk.dmg
	rm -rf ramdisk/sbin/launchd