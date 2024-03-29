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

include $(top_srcdir)/lint.am

MAINTAINERCLEANFILES = Makefile.in

BUILT_SOURCES        = plsdbug.h plsdbug.c
BUILT_SOURCES       += plsdbug.pkb plsdbug.pke plsdbug.pks plsdbug.pls

MOSTLYCLEANFILES     = $(BUILT_SOURCES) *.pc

CLEANFILES           = *.???_run

# AUTOMAKE_OPTIONS     = ansi2knr

# GJP 2023-02-02 Use oradumper as a template

AM_CPPFLAGS          = -I$(top_srcdir)/src/lib

AM_CFLAGS	           = @DBUG_CPPFLAGS@ @EPC_CPPFLAGS@

# Add the packages
EXTRA_DIST           = plsdbug.pkb plsdbug.pks plsdbug.pls

noinst_DATA          = plsdbug.pls_run

bin_PROGRAMS         = plsdbug
plsdbug_SOURCES      = plsdbug.idl plsdbug.c main.c
plsdbug_LDADD        = $(top_builddir)/src/lib/libplsdbug.la @DBUG_LDADD@ @EPC_LDADD@

# do not forget to add to noinst_DATA otherwise plsdbug.pls will not get installed
noinst_DATA         += plsdbug_local

if DARWIN

noinst_DATA         += plsdbug.no_dynamic

plsdbug.no_dynamic:
	ORACLE_LIBS=$(ORACLE_LIBS) ORACLE_LDFLAGS=$(ORACLE_LDFLAGS) $(top_srcdir)/darwin-remove-rpath.sh plsdbug

endif

IDL                  = idl$(EXEEXT)

@SUFFIXES@           = .pls_run .pls .idl_run .idl

.idl.idl_run:
	$(IDL) $<
	@touch $@

.pls.pls_run:
# Before running the compiler first compile the package
	echo exit SQL.SQLCODE | $(SQLPLUS) $(USERID) @$<
	@touch $@

$(BUILT_SOURCES): plsdbug.idl_run

if DARWIN

plsdbug_local: plsdbug
	@cp $? $@
	ORACLE_LIBS=$(ORACLE_LIBS) ORACLE_LDFLAGS=$(ORACLE_LDFLAGS) $(top_srcdir)/darwin-remove-rpath.sh $@

else

plsdbug_local: plsdbug
	@cp $? $@

endif

DISTCLEANFILES = plsdbug_local
