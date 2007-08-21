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

GENERATED_FILES      = plsdbug.h plsdbug.c
GENERATED_FILES     += plsdbug.pkb plsdbug.pke plsdbug.pks plsdbug.pls

MOSTLYCLEANFILES     = $(GENERATED_FILES) *.pc

CLEANFILES           = *.lis

AUTOMAKE_OPTIONS     = ansi2knr

AM_CPPFLAGS          = @DBUG_CPPFLAGS@ @EPC_CPPFLAGS@

EXTRA_DIST           = $(GENERATED_FILES)

noinst_DATA          = plsdbug.pls_run
bin_PROGRAMS         = plsdbug
BUILT_SOURCES        = $(GENERATED_FILES)
plsdbug_SOURCES      = plsdbug.idl plsdbug.c main.c
plsdbug_LDADD        = $(top_builddir)/src/lib/libplsdbug.la @DBUG_LDADD@ @EPC_LDADD@

IDL = idl$(EXEEXT)

@SUFFIXES@           = .pls_run .pls

$(GENERATED_FILES): plsdbug.idl
	$(IDL) $?

.pls.pls_run:
# Before running the compiler first compile the package
	echo exit SQL.SQLCODE | $(SQLPLUS) $(USERID) @$(@:.pls_run=.pls)
	@touch $@
