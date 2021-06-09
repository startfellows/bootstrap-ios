EXECUTABLE_NAME = tamplier
SHELL = /bin/bash

prefix ?= /usr/local
BINDIR ?= $(prefix)/bin

INSTALL_PATH = $(BINDIR)/$(EXECUTABLE_NAME)
BUILD_PATH = .build/apple/Products/Release/$(EXECUTABLE_NAME)

.PHONY: install build uninstall

install: build
	mkdir -p $(prefix)/bin
	cp -f $(BUILD_PATH) $(INSTALL_PATH)

build:
	swift build -c release --disable-sandbox --product $(EXECUTABLE_NAME) --arch arm64 --arch x86_64

uninstall:
	rm -f $(INSTALL_PATH)