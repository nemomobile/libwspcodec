# -*- Mode: makefile-gmake -*-

.PHONY: clean all debug release pkgconfig install install-dev

# Required packages
PKGS = glib-2.0

#
# Default target
#

all: debug release pkgconfig

#
# Library version
#

VERSION_MAJOR = 2
VERSION_MINOR = 2
VERSION_RELEASE = 0
VERSION = $(VERSION_MAJOR).$(VERSION_MINOR)

LIB_SHORTCUT = libwspcodec-$(VERSION).so
LIB_SONAME = $(LIB_SHORTCUT)
LIB = $(LIB_SONAME).$(VERSION_RELEASE)

#
# Sources
#

SRC = wsputil.c

#
# Directories
#

SRC_DIR = wspcodec
BUILD_DIR = build
DEBUG_BUILD_DIR = $(BUILD_DIR)/debug
RELEASE_BUILD_DIR = $(BUILD_DIR)/release

#
# Tools and flags
#

CC = $(CROSS_COMPILE)gcc
LD = $(CC)
WARNINGS = -Wall
INCLUDES = -I$(SRC_DIR)
BASE_FLAGS = -fPIC
CFLAGS = $(BASE_FLAGS) $(DEFINES) $(WARNINGS) $(INCLUDES) -MMD -MP \
  $(shell pkg-config --cflags $(PKGS))
LDFLAGS = $(BASE_FLAGS) -shared -Wl,-soname,$(LIB_SONAME) \
  $(shell pkg-config --libs $(PKGS))
DEBUG_FLAGS = -g
RELEASE_FLAGS =

ifndef KEEP_SYMBOLS
KEEP_SYMBOLS = 0
endif

ifneq ($(KEEP_SYMBOLS),0)
RELEASE_FLAGS += -g
endif

DEBUG_LDFLAGS = $(LDFLAGS) $(DEBUG_FLAGS)
RELEASE_LDFLAGS = $(LDFLAGS) $(RELEASE_FLAGS)
DEBUG_CFLAGS = $(CFLAGS) $(DEBUG_FLAGS) -DDEBUG
RELEASE_CFLAGS = $(CFLAGS) $(RELEASE_FLAGS) -O2

#
# Files
#

PKGCONFIG = $(BUILD_DIR)/libwspcodec.pc
DEBUG_OBJS = $(SRC:%.c=$(DEBUG_BUILD_DIR)/%.o)
RELEASE_OBJS = $(SRC:%.c=$(RELEASE_BUILD_DIR)/%.o)

#
# Dependencies
#

DEPS = $(DEBUG_OBJS:%.o=%.d) $(RELEASE_OBJS:%.o=%.d)
ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(DEPS)),)
-include $(DEPS)
endif
endif

#
# Rules
#

DEBUG_LIB = $(DEBUG_BUILD_DIR)/$(LIB)
RELEASE_LIB = $(RELEASE_BUILD_DIR)/$(LIB)

debug: $(DEBUG_LIB)

release: $(RELEASE_LIB)

pkgconfig: $(PKGCONFIG)

clean:
	rm -f *~ $(SRC_DIR)/*~
	rm -fr $(BUILD_DIR) RPMS installroot
	rm -fr debian/tmp debian/libwspcodec debian/libwspcodec-dev
	rm -f documentation.list debian/files debian/*.substvars
	rm -f debian/*.debhelper.log debian/*.debhelper

$(BUILD_DIR):
	mkdir -p $@

$(DEBUG_BUILD_DIR):
	mkdir -p $@

$(RELEASE_BUILD_DIR):
	mkdir -p $@

$(DEBUG_LIB): $(DEBUG_BUILD_DIR) $(DEBUG_OBJS)
	$(LD) $(DEBUG_OBJS) $(DEBUG_LDFLAGS) -o $@

$(RELEASE_LIB): $(RELEASE_BUILD_DIR) $(RELEASE_OBJS)
	$(LD) $(RELEASE_OBJS) $(RELEASE_LDFLAGS) -o $@
ifeq ($(KEEP_SYMBOLS),0)
	strip $@
endif

$(DEBUG_BUILD_DIR)/%.o : $(SRC_DIR)/%.c
	$(CC) -c $(DEBUG_CFLAGS) -MF"$(@:%.o=%.d)" $< -o $@

$(RELEASE_BUILD_DIR)/%.o : $(SRC_DIR)/%.c
	$(CC) -c $(RELEASE_CFLAGS) -MF"$(@:%.o=%.d)" $< -o $@

$(PKGCONFIG): libwspcodec.pc.in
	sed -e 's/\[version\]/'$(VERSION)/g $< > $@

#
# Install
#

INSTALL_PERM  = 644
INSTALL_OWNER = $(shell id -u)
INSTALL_GROUP = $(shell id -g)

INSTALL = install
INSTALL_DIRS = $(INSTALL) -d
INSTALL_FILES = $(INSTALL) -m $(INSTALL_PERM)

INSTALL_LIB_DIR = $(DESTDIR)/usr/lib
INSTALL_INCLUDE_DIR = $(DESTDIR)/usr/include/libwspcodec/wspcodec
INSTALL_PKGCONFIG_DIR = $(DESTDIR)/usr/lib/pkgconfig

INSTALL_ALIAS = $(INSTALL_LIB_DIR)/$(LIB_SHORTCUT)

install: $(INSTALL_LIB_DIR)
	$(INSTALL_FILES) $(RELEASE_LIB) $(INSTALL_LIB_DIR)
	ln -sf $(LIB) $(INSTALL_ALIAS)

install-dev: install $(INSTALL_INCLUDE_DIR) $(INSTALL_PKGCONFIG_DIR)
	$(INSTALL_FILES) $(SRC_DIR)/wsputil.h $(INSTALL_INCLUDE_DIR)
	$(INSTALL_FILES) $(SRC_DIR)/wspcodec.h $(INSTALL_INCLUDE_DIR)
	$(INSTALL_FILES) $(PKGCONFIG) $(INSTALL_PKGCONFIG_DIR)

$(INSTALL_LIB_DIR):
	$(INSTALL_DIRS) $@

$(INSTALL_INCLUDE_DIR):
	$(INSTALL_DIRS) $@

$(INSTALL_PKGCONFIG_DIR):
	$(INSTALL_DIRS) $@
