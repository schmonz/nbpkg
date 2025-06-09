.PHONY: install-bin

install-bin:
	mkdir -p $${HOME}/bin
	ln -sf `pwd`/bin/nbpkg $${HOME}/bin
	( echo '#!/bin/sh' && echo 'exec nbpkg make "$$@"' ) > $${HOME}/bin/make
	chmod +x $${HOME}/bin/make
	( echo '#!/bin/sh' && echo 'exec nbpkg sudo "$$@"' ) > $${HOME}/bin/sudo
	chmod +x $${HOME}/bin/sudo
	ln -sf /opt/pkg/bin/cvs-for-gits $${HOME}/bin/cvs
