## Makefile.am -- Process this file with automake to produce Makefile.in
## Copyright (C) 2002 G.J. Paulissen
##
## This library is free software; you can redistribute it and/or
## modify it under the terms of the GNU Lesser General Public
## License as published by the Free Software Foundation; either
## version 2.1 of the License, or (at your option) any later version.
##
## This library is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## Lesser General Public License for more details.
##
## You should have received a copy of the GNU Lesser General Public
## License along with this library; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

AUTOMAKE_OPTIONS 	= 
SUBDIRS 		= src test util
MAINTAINERCLEANFILES 	= Makefile.in aclocal.m4 configure config-h.in \
			stamp-h.in $(AUX_DIST)
ACLOCAL_AMFLAGS		= -I $(ac_aux_dir)

EXTRA_DIST              = 

docdir			= $(top_builddir)/util

html:
	@echo Making $@ in $(docdir)
	@cd $(docdir) && make $@

dist-hook:
	for file in $(AUX_DIST) $(AUX_DIST_EXTRA); do \
	  cp $$file $(distdir)/$$file; \
	done
	chmod +x $(top_srcdir)/config/*

