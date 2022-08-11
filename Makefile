PACKAGE=thc-secure-delete
GITPROJECT="therealdano/$(PACKAGE).git"
GITHOST="github.com"
GITBRANCH="secure-delete"
GIT=git
VERSION=3.1.2
PREFIX=/usr
CC=gcc
OPT=${CFLAGS} -fstack-protector-strong -fPIC -pie -Wl,-z,relro -Wl,-z,now -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE
#OPT=-Wall -D_DEBUG_ -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE
BINDIR=$(PREFIX)/bin
SHAREDIR=$(PREFIX)/share
MANDIR=$(SHAREDIR)/man
DOCDIR=$(SHAREDIR)/doc/secure_delete
OPT_MOD=-D__KERNEL__ -DMODULE -fomit-frame-pointer -fno-strict-aliasing -pipe -mpreferred-stack-boundary=2
#LD_MOD=-r

all: sdel-lib.o srm sfill sswap sdmem
	@echo
	@echo "A Puritan is someone who is deathly afraid that someone, somewhere, is"
	@echo "having fun."
	@echo
	@echo "I hope YOU have fun!"
	@echo

sdel-mod.o: sdel-mod.c
	$(CC) $(OPT) $(OPT_MOD) $(LD_MOD) -I/lib/modules/`uname -r`/build/include -c sdel-mod.c

sdel-lib.o: sdel-lib.c
	$(CC) ${OPT} -c sdel-lib.c

srm: srm.c
	$(CC) ${OPT} -o srm srm.c sdel-lib.o
	-strip srm
sfill: sfill.c
	$(CC) ${OPT} -o sfill sfill.c sdel-lib.o
	-strip sfill
sswap: sswap.c
	$(CC) ${OPT} -o sswap sswap.c sdel-lib.o
	-strip sswap
sdmem: smem.c
	$(CC) ${OPT} -o sdmem smem.c sdel-lib.o
	-strip sdmem

clean:
	rm -f sfill srm sswap sdmem sdel sdel-lib.o sdel-mod.o core *~

install: all
	if [ ! -d "$(DESTDIR)$(BINDIR)" ]; then \
		mkdir -p -m 755 $(DESTDIR)$(BINDIR); \
	fi
	cp -f sdel srm sfill sswap sdmem the_cleaner.sh $(DESTDIR)$(BINDIR)
	chmod 711 $(DESTDIR)$(BINDIR)/srm $(DESTDIR)$(BINDIR)/sfill $(DESTDIR)$(BINDIR)/sswap $(DESTDIR)$(BINDIR)/sdmem $(DESTDIR)$(BINDIR)/the_cleaner.sh
	if [ ! -d "$(DESTDIR)$(MANDIR)" ]; then \
		mkdir -p -m 755 $(DESTDIR)$(MANDIR)/man1; \
	fi
	cp -f srm.1 sfill.1 sswap.1 smem.1 $(DESTDIR)$(MANDIR)/man1
	chmod 644 $(DESTDIR)$(MANDIR)/man1/srm.1 $(DESTDIR)$(MANDIR)/man1/sfill.1 $(DESTDIR)$(MANDIR)/man1/sswap.1 $(DESTDIR)$(MANDIR)/man1/smem.1
	if [ ! -d "$(DESTDIR)$(DOCDIR)" ]; then \
		mkdir -p -m 755 $(DESTDIR)$(DOCDIR); \
	fi
	cp -f CHANGES FILES README secure_delete.doc usenix6-gutmann.doc $(DESTDIR)$(DOCDIR)
	#-test -e sdel-mod.o && cp -f sdel-mod.o /lib/modules/`uname -r`/kernel/drivers/char
#	#@-test '!' -e sdel-mod.o -a `uname -s` = 'Linux' && echo "type \"make sdel-mod install\" to compile and install the Linux loadable kernel module for secure delete"

tag:
	(TAGGED=$(shell $(GIT) tag | grep v$(VERSION)); \
		if [ "x$$TAGGED" != "x" ]; then \
			$(GIT) tag -d v$(VERSION); \
			$(GIT) push origin :refs/tags/v$(VERSION);\
		fi)
	$(GIT) tag v$(VERSION)
	$(GIT) push origin $(GITBRANCH)

dist: 
	DISTTEMP=`mktemp -d -t $(PACKAGE).XXXXXX`;\
	(cd $${DISTTEMP}; git clone -b "$(GITBRANCH)" git@$(GITHOST):$(GITPROJECT) $(PACKAGE)-$(VERSION) || echo 'export failed');\
	tar -czpf $(PACKAGE)-$(VERSION).tar.gz --exclude=.git --exclude=.svn --exclude=.gitignore --exclude=client -C $${DISTTEMP} .;\
	rm -rf $${DISTTEMP};\
	echo "The final archive is $(PACKAGE)-$(VERSION).tar.gz"
