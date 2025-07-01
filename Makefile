MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:
BUILDDIR := build
DEBIAN_IMG_URL := https://cdimage.debian.org/images/cloud/sid/daily/latest/debian-sid-generic-amd64-daily.qcow2
DEBIAN_IMG_FILE := debian.qcow2
KERNEL_CMDLINE := root=/dev/sda1 console=tty0 console=ttyS0,115200 earlyprintk=ttyS0,115200 consoleblank=0

.PHONY: all
all: prepare cidata download resize run

.PHONY: resize
resize:
	qemu-img resize $(DEBIAN_IMG_FILE) +10G

.PHONY: prepare
prepare:
	mkdir -p $(BUILDDIR)
	mkdir -p $(BUILDDIR)/boot

.PHONY: clean
clean:
	rm cidata.iso
	rm -rf $(BUILDDIR)

.PHONY: distclean
distclean: clean
	rm $(DEBIAN_IMG_FILE)

.PHONY: download
download:
	wget $(DEBIAN_IMG_URL) -O $(DEBIAN_IMG_FILE)

.PHONY: cidata
cidata:
	echo "Creating cloud-init iso image"
	xorrisofs -o cidata.iso -V cidata -r -J cidata/

.PHONY: run
run:
	qemu-system-x86_64 \
		-enable-kvm \
		-nographic \
		-m 16G \
		-smp $$(nproc) \
		-cdrom cidata.iso \
		-drive file=$(DEBIAN_IMG_FILE),format=qcow2,index=0,media=disk \
		-serial mon:stdio
