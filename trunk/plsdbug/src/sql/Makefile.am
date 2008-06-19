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

sql_scripts      = uninstall.sql verify.sql

if LOG4PLSQL

pls_scripts      = dbug.pls dbug_trigger.pls dbug_plsdbug.pls dbug_dbms_output.pls dbug_log4plsql.pls
typ_scripts      = dbug_call_obj_t.typ dbug_call_tab_t.typ dbug_obj_t.typ dbug_plsdbug_obj_t.typ dbug_log4plsql_obj_t.typ
tyb_scripts      = dbug_obj_t.tyb dbug_plsdbug_obj_t.tyb dbug_log4plsql_obj_t.tyb

else

pls_scripts      = dbug.pls dbug_trigger.pls dbug_plsdbug.pls dbug_dbms_output.pls
typ_scripts      = dbug_call_obj_t.typ dbug_call_tab_t.typ dbug_obj_t.typ dbug_plsdbug_obj_t.typ
tyb_scripts      = dbug_obj_t.tyb dbug_plsdbug_obj_t.tyb 

endif

noinst_DATA      = $(typ_scripts) $(pls_scripts) $(tyb_scripts) \
                   $(pls_scripts:.pls=.html) \
                   $(typ_scripts:.typ=.typ_run) $(pls_scripts:.pls=.pls_run) $(tyb_scripts:.tyb=.tyb_run)

MOSTLYCLEANFILES = $(pls_scripts:.pls=.html)

CLEANFILES       = *.???_run pod*.tmp

EXTRA_DIST       = $(pls_scripts) $(typ_scripts) $(tyb_scripts) $(sql_scripts) \
                   $(pls_scripts:.pls=.html)

if LOG4PLSQL

else

EXTRA_DIST      += dbug_log4plsql_obj_t.typ dbug_log4plsql_obj_t.tyb

endif

@SUFFIXES@: .pls .typ .tyb .html .pls_run .typ_run .tyb_run

# Dependencies

dbug_trigger.pls_run: dbug.pls_run

dbug_call_tab_t.typ_run dbug.pls_run: dbug_call_obj_t.typ_run

dbug_obj_t.typ_run dbug.pls_run: dbug_call_tab_t.typ_run

dbug_log4plsql_obj_t.tyb_run dbug_log4plsql.pls_run: dbug_log4plsql_obj_t.typ_run

dbug_obj_t.tyb_run dbug.pls_run: dbug_obj_t.typ_run

dbug_plsdbug_obj_t.tyb_run dbug_plsdbug.pls_run: dbug_plsdbug_obj_t.typ_run


# End of dependencies

uninstall: uninstall.sql_run clean

uninstall.sql_run: uninstall.sql
	echo exit SQL.SQLCODE | ( SQLPATH=$(srcdir) && export SQLPATH && $(SQLPLUS) $(USERID) @$< )

.pls.pls_run:
	echo exit SQL.SQLCODE | ( SQLPATH=$(srcdir) && export SQLPATH && $(SQLPLUS) $(USERID) @$< )
	@touch $@

.typ.typ_run:
	echo exit SQL.SQLCODE | ( SQLPATH=$(srcdir) && export SQLPATH && $(SQLPLUS) $(USERID) @$< )
	@touch $@

.tyb.tyb_run:
	echo exit SQL.SQLCODE | ( SQLPATH=$(srcdir) && export SQLPATH && $(SQLPLUS) $(USERID) @$< )
	@touch $@

.pls.html:
	sed 's/-- =pod/=pod/g;s/-- =cut/=cut/g' $? | @PERL@ -S pod2html --outfile=$@
