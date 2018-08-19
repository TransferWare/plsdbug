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

pls_scripts      = dbug_log4plsql.pls
sql_scripts      = dbug_install_log4plsql.sql dbug_uninstall_log4plsql.sql
tyb_scripts      = dbug_log4plsql_obj_t.tyb
typ_scripts      = dbug_log4plsql_obj_t.typ

noinst_DATA      = $(pls_scripts:.pls=.html)

MOSTLYCLEANFILES = $(pls_scripts:.pls=.html)

CLEANFILES       = *.???_run pod*.tmp

EXTRA_DIST       = $(pls_scripts) \
                   $(pls_scripts:.pls=.html) \
                   $(sql_scripts) \
                   $(tyb_scripts) \
                   $(typ_scripts)

@SUFFIXES@: .html

install: dbug_install_log4plsql.sql_run

uninstall: dbug_uninstall_log4plsql.sql_run clean

.pls.html:
	sed 's/-- =pod/=pod/g;s/-- =cut/=cut/g' $? | @PERL@ -S pod2html --outfile=$@

dbug_uninstall_log4plsql.sql_run:
	echo exit SQL.SQLCODE | ( SQLPATH=$(srcdir) && export SQLPATH && $(SQLPLUS) $(USERID) @dbug_uninstall_log4plsql.sql )
	@touch $@

dbug_install_log4plsql.sql_run:
	echo exit SQL.SQLCODE | ( SQLPATH=$(srcdir) && export SQLPATH && $(SQLPLUS) $(USERID) @dbug_install_log4plsql.sql )
	@touch $@
