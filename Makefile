##
## to set by the user
##
# verbosity (default off)
V = 0
# libnotify support, 0 for on, 1 for off (default on)
WITH_NOTIFY = 1

ifeq ($(V),0)
VERBOSE=@
else
VERBOSE=
endif

ifneq ($(WITH_NOTIFY),1)
CPPFLAGS += -DWITHOUT_NOTIFY
endif

# programs
CC ?= gcc
PKG_CONFIG ?= pkg-config
RM = rm -f
INSTALL = install
INSTALL_BIN = $(INSTALL) -m755
INSTALL_DATA = $(INSTALL) -m644

# flags and libs
CFLAGS ?= -O2
CFLAGS += -Wall -Wno-format
PKG_DEPS = gtk+-2.0
ifeq ($(WITH_NOTIFY),1)
PKG_DEPS += libnotify
endif
LIBS += $(shell $(PKG_CONFIG) --libs $(PKG_DEPS)) -lm
CFLAGS += $(shell $(PKG_CONFIG) --cflags $(PKG_DEPS))

# variables
PACKAGE_NAME = cbatticon
VERSION = $(shell grep CBATTICON_VERSION_NUMBER cbatticon.c | awk '{print $$3}')
PREFIX ?= /usr
BINDIR = $(PREFIX)/bin
DOCDIR = $(PREFIX)/share/doc/$(PACKAGE_NAME)-$(VERSION)

BIN = $(PACKAGE_NAME)
SOURCEFILES := $(wildcard *.c)
OBJECTS := $(patsubst %.c,%.o,$(SOURCEFILES))

$(BIN): $(OBJECTS)
	@echo -e '\033[1;31mLinking CC executable $@\033[0m'
	$(VERBOSE) $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

$(OBJECTS): $(SOURCEFILES)
	@echo -e '\033[0;32mBuilding CC object $@\033[0m'
	$(VERBOSE) $(CC) -c $(CFLAGS) $(CPPFLAGS) -o $@ $<

install: $(BIN)
	@echo -e '\033[1;33mInstalling $(PACKAGE_NAME)\033[0m'
	$(VERBOSE) $(INSTALL) -d "$(DESTDIR)$(BINDIR)"
	$(VERBOSE) $(INSTALL_BIN) $(BIN) "$(DESTDIR)$(BINDIR)"/
	$(VERBOSE) $(INSTALL) -d "$(DESTDIR)$(DOCDIR)"
	$(VERBOSE) $(INSTALL_DATA) README "$(DESTDIR)$(DOCDIR)"/

uninstall:
	@echo -e '\033[1;33mUninstalling $(PACKAGE_NAME)\033[0m'
	$(VERBOSE) $(RM) "$(DESTDIR)$(BINDIR)"/$(BIN)
	$(VERBOSE) $(RM) "$(DESTDIR)$(DOCDIR)"/README

clean :
	@echo -e '\033[1;33mCleaning up source directory\033[0m'
	$(VERBOSE) $(RM) $(BIN) $(OBJECTS)

.PHONY: install uninstall clean
