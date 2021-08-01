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

pks_scripts      = dbug.pks dbug_profiler.pks
pkb_scripts      = dbug.pkb dbug_profiler.pks
pls_scripts      = dbug_trigger.pls dbug_dbms_output.pls dbug_dbms_application_info.pls dbug_log4plsql.pls
sql_scripts      = dbug_install.sql dbug_uninstall.sql dbug_verify.sql
typ_scripts      = dbug_call_obj_t.typ dbug_call_tab_t.typ dbug_obj_t.typ dbug_log4plsql_obj_t.typ
tyb_scripts      = dbug_obj_t.tyb dbug_log4plsql_obj_t.tyb

SUBDIRS          = .

html_files       = $(pks_scripts:.pks=.html) \
                   $(pls_scripts:.pls=.html)

noinst_DATA      = $(html_files) \
                   dbug_install.sql_run

MOSTLYCLEANFILES = $(pls_scripts:.pls=.html) $(pks_scripts:.pks=.html)

CLEANFILES       = *.???_run pod*.tmp

EXTRA_DIST       = $(pkb_scripts) \
                   $(pks_scripts) \
                   $(pls_scripts) \
                   $(sql_scripts) \
                   $(tyb_scripts) \
                   $(typ_scripts) \
                   $(pks_scripts:.pks=.html) \
                   $(pls_scripts:.pls=.html)

@SUFFIXES@: .pls .pks .html

html: $(html_files)

install: dbug_install.sql_run clean

uninstall: dbug_uninstall.sql_run clean

dbug_install.sql_run:
	echo exit SQL.SQLCODE | ( SQLPATH=$(srcdir) && export SQLPATH && $(SQLPLUS) $(USERID) @dbug_install.sql )
	@touch $@

dbug_uninstall.sql_run:
	echo exit SQL.SQLCODE | ( SQLPATH=$(srcdir) && export SQLPATH && $(SQLPLUS) $(USERID) @dbug_uninstall.sql )

.pls.html:
	sed 's/-- =pod/=pod/g;s/-- =cut/=cut/g' $? | @PERL@ -S pod2html --outfile=$@

.pks.html:
	sed 's/-- =pod/=pod/g;s/-- =cut/=cut/g' $? | @PERL@ -S pod2html --outfile=$@
