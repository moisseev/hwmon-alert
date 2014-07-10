program = hwmon-alert
version = `egrep '\# Version[ ]+' $(program) | sed "s/.*Version *\(.*\), .*/\1/"`
release = $(program)-$(version)

src = $(program) \
      $(program).conf.sample \
      $(program).1 \
      Makefile README.md LICENSE

cleanfiles = hwmon-alert.1 \
             $(release).tgz \
             $(release).tgz.md5

prefix ?= /usr/local

bindir  = $(prefix)/bin
confdir = $(prefix)/etc
mandir  = $(prefix)/man/man1
libdir  = /var/lib/$(program)

INSTALL = /usr/bin/install -c

hwmon-alert.1:
	pod2man --section=1 \
		--release="$(version)" \
		--center="$(program) manual" \
		$(program) > $(program).1

install: hwmon-alert.1
	$(INSTALL) -d -m 0755 $(DESTDIR)$(bindir) $(DESTDIR)$(confdir) \
		$(DESTDIR)$(libdir) $(DESTDIR)$(mandir) || exit 1;
	$(INSTALL) -m 0755 $(program) $(DESTDIR)$(bindir)/$(program) || exit 1;
	$(INSTALL) -m 0644 $(program).conf.sample $(DESTDIR)$(confdir)/$(program).conf.sample || exit 1;
	$(INSTALL) -m 0644 $(program).1 $(DESTDIR)$(mandir)/$(program).1 || exit 1;
	gzip $(DESTDIR)$(mandir)/$(program).1;

uninstall:
	-@rm $(DESTDIR)$(bindir)/$(program) \
		$(DESTDIR)$(confdir)/$(program).conf.sample \
		$(DESTDIR)$(mandir)/$(program).1.gz
	@if [ -f $(DESTDIR)$(libdir)/offrange.db ]; then \
		rm $(DESTDIR)$(libdir)/offrange.db; \
	fi
	-@rmdir $(DESTDIR)$(libdir)

release: hwmon-alert.1
	@echo Preparing version $(version); \
	tar -czvf $(release).tgz --uid=0 --gid=0 -s",^,$(release)/," $(src); \
	md5 $(release).tgz > $(release).tgz.md5; \
	chmod 644 $(release).tgz $(release).tgz.md5

clean:
	@for file in $(cleanfiles); do \
		if [ -f $$file ]; then rm $$file; fi \
	done
