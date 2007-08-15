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

MAINTAINERCLEANFILES = Makefile.in

GENERATED_FILES      = plsdbug.pc plsdbug.c plsdbug.h
GENERATED_FILES     += plsdbug.pkb plsdbug.pke plsdbug.pks plsdbug.pls

MOSTLYCLEANFILES     = $(GENERATED_FILES)

CLEANFILES           = *.lis

AUTOMAKE_OPTIONS     = ansi2knr

AM_CPPFLAGS          = -I$(includedir)

EXTRA_DIST           = $(GENERATED_FILES)

noinst_DATA          = 
bin_PROGRAMS         = plsdbug
BUILT_SOURCES        = plsdbug.h
plsdbug_SOURCES      = plsdbug.idl main.c
plsdbug_LDADD        = $(top_builddir)/src/lib/libplsdbug.la

IDL = idl$(EXEEXT)

plsdbug($EXEEXT): plsdbug.c

@SUFFIXES@: .c .idl

.idl.c:
	$(IDL) $<
# first compile the package
	echo exit SQL.SQLCODE | $(SQLPLUS) $(USERID) @$(@:.c=.pls)
	test -z "$(PROC)" || $(PROC) $(PROCINCLUDES) $(PROCFLAGS) INAME=$(@:.c=.pc) ONAME=$@
