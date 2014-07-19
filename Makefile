PREFIX?=/usr/local
DESTDIR?=
INSTALL?=install

OSFILES = $(filter-out $(wildcard *~),$(wildcard os.*))
SCRIPTS = $(filter-out $(wildcard *~),$(wildcard guilt-*))

VERSION:=$(shell { git describe 2> /dev/null | sed 's/^v//'; } || sed -n -e '/^GUILT_VERSION=/ { s/^GUILT_VERSION="/v/; s/"//; p; q; }' guilt)

.PHONY: all
all: guilt-version
	@echo "Nothing to build, it is all bash :)"
	@echo "Try make install"

.PHONY: FORCE
guilt-version: FORCE
	@{	\
		echo "#!/bin/sh";			\
		echo "GUILT_VERSION=$(VERSION)";	\
		echo "DO_NOT_CHECK_BRANCH_EXISTENCE=1";	\
		echo "_main () {";			\
		echo "	echo \"Guilt version \$$GUILT_VERSION\"";\
		echo "}";				\
	} >$@

.PHONY: install
install: guilt-version
	$(INSTALL) -d $(DESTDIR)$(PREFIX)/bin/
	$(INSTALL) -m 755 guilt $(DESTDIR)$(PREFIX)/bin/
	$(INSTALL) -d $(DESTDIR)$(PREFIX)/lib/guilt/
	$(INSTALL) -m 755 $(SCRIPTS) $(DESTDIR)$(PREFIX)/lib/guilt/
	$(INSTALL) -m 644 $(OSFILES) $(DESTDIR)$(PREFIX)/lib/guilt/
	$(INSTALL) -d $(DESTDIR)$(PREFIX)/etc/bash_completion.d/
	$(INSTALL) -m 644 guilt.complete $(DESTDIR)$(PREFIX)/etc/bash_completion.d/

.PHONY: uninstall
uninstall:
	./uninstall $(DESTDIR)$(PREFIX)/bin/ $(SCRIPTS)

.PHONY: doc
doc:
	+$(MAKE) -C Documentation all

.PHONY: install-doc
install-doc:
	+$(MAKE) -C Documentation install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR) INSTALL=$(INSTALL)

.PHONY: test
test:
	+$(MAKE) -C regression all

.PHONY: clean
clean:
	+$(MAKE) -C Documentation clean
