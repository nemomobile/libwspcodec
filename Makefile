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
VERSION_MINOR = 0
VERSION_MICRO = 0
VERSION = $(VERSION_MAJOR).$(VERSION_MINOR).$(VERSION_MICRO)

LIB_SHORTCUT = libwspcodec.so
LIB_SONAME = $(LIB_SHORTCUT).$(VERSION_MAJOR)
LIB = $(LIB_SHORTCUT).$(VERSION)

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
CFLAGS = -fPIC $(WARNINGS) $(INCLUDES) $(shell pkg-config --cflags $(PKGS))
LDFLAGS = -fPIC -shared -Wl,-soname -Wl,$(LIB_SONAME)
DEBUG_CFLAGS = -g -DDEBUG $(CFLAGS) -MMD -MP
DEBUG_LDFLAGS = -g $(LDFLAGS)
RELEASE_CFLAGS = -O2 $(CFLAGS) -MMD -MP
RELEASE_LDFLAGS = $(LDFLAGS)
ARFLAGS = rc

ifndef KEEP_SYMBOLS
KEEP_SYMBOLS = 0
endif

ifneq ($(KEEP_SYMBOLS),0)
RELEASE_CFLAGS += -g
RELEASE_LDFLAGS += -g
endif

#
# Files
#

PKGCONFIG = $(BUILD_DIR)/libwspcodec.pc
SRC_FILES = $(SRC:%=$(SRC_DIR)/%)
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
	rm -fr $(BUILD_DIR) *~ $(SRC_DIR)/*~

$(BUILD_DIR):
	mkdir -p $@

$(DEBUG_BUILD_DIR):
	mkdir -p $@

$(RELEASE_BUILD_DIR):
	mkdir -p $@

$(DEBUG_LIB): $(DEBUG_BUILD_DIR) $(DEBUG_OBJS)
	$(LD) -o $@ $(DEBUG_LDFLAGS) $(DEBUG_OBJS)

$(RELEASE_LIB): $(RELEASE_BUILD_DIR) $(RELEASE_OBJS)
	$(LD) -o $@ $(RELEASE_LDFLAGS) $(RELEASE_OBJS)
ifeq ($(KEEP_SYMBOLS),0)
	strip $@
endif

$(DEBUG_BUILD_DIR)/%.o : $(SRC_DIR)/%.c
	$(CC) -c $(DEBUG_CFLAGS) -MF"$(@:%.o=%.d)" $< -o $@

$(RELEASE_BUILD_DIR)/%.o : $(SRC_DIR)/%.c
	$(CC) -c $(RELEASE_CFLAGS) -MF"$(@:%.o=%.d)" $< -o $@

$(PKGCONFIG): libwspcodec.pc.in
	sed -e 's/\[version\]/'$(VERSION)/g $< >> $@

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

INSTALL_ALIAS1 = $(INSTALL_LIB_DIR)/$(LIB_SONAME)
INSTALL_ALIAS2 = $(INSTALL_LIB_DIR)/$(LIB_SHORTCUT)

install: $(INSTALL_LIB_DIR) 
	$(INSTALL_FILES) $(RELEASE_LIB) $(INSTALL_LIB_DIR)
	ln -sf $(LIB) $(INSTALL_ALIAS1)
	ln -sf $(LIB) $(INSTALL_ALIAS2)

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
