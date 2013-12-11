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

sql_scripts      = dbug_install.sql dbug_uninstall.sql dbug_verify.sql
pks_scripts      = dbug.pks
pkb_scripts      = dbug.pkb

if LOG4PLSQL

pls_scripts      = dbug_trigger.pls dbug_plsdbug.pls dbug_dbms_output.pls dbug_dbms_application_info.pls dbug_log4plsql.pls
typ_scripts      = dbug_call_obj_t.typ dbug_call_tab_t.typ dbug_obj_t.typ dbug_plsdbug_obj_t.typ dbug_log4plsql_obj_t.typ
tyb_scripts      = dbug_obj_t.tyb dbug_plsdbug_obj_t.tyb dbug_log4plsql_obj_t.tyb

else

pls_scripts      = dbug_trigger.pls dbug_plsdbug.pls dbug_dbms_output.pls dbug_dbms_application_info.pls
typ_scripts      = dbug_call_obj_t.typ dbug_call_tab_t.typ dbug_obj_t.typ dbug_plsdbug_obj_t.typ
tyb_scripts      = dbug_obj_t.tyb dbug_plsdbug_obj_t.tyb 

endif

noinst_DATA      = $(pkb_scripts) \
		   $(pkb_scripts:.pkb=.pkb_run) \
		   $(pks_scripts) \
		   $(tyb_scripts:.tyb=.tyb_run) \
	     $(pls_scripts:.pls=.pls_run) \
       $(tyb_scripts) \
       $(pls_scripts) \
       $(typ_scripts) \
       $(pks_scripts:.pks=.html) \
       $(pks_scripts:.pks=.pks_run) \
       $(pls_scripts:.pls=.html) \
       $(typ_scripts:.typ=.typ_run)

MOSTLYCLEANFILES = $(pls_scripts:.pls=.html) $(pks_scripts:.pks=.html)

CLEANFILES       = *.???_run pod*.tmp

if LOG4PLSQL

EXTRA_DIST       = $(pkb_scripts) \
		   $(pks_scripts) \
       $(tyb_scripts) \
       $(pls_scripts) \
       $(sql_scripts) \
       $(typ_scripts) \
       $(pks_scripts:.pks=.html) \
       $(pls_scripts:.pls=.html)

else

EXTRA_DIST       = $(pkb_scripts) \
		   $(pks_scripts) \
       $(tyb_scripts) \
       $(pls_scripts) \
       $(sql_scripts) \
       $(typ_scripts) \
       $(pks_scripts:.pks=.html) \
       $(pls_scripts:.pls=.html) \
       dbug_log4plsql_obj_t.typ \
		   dbug_log4plsql_obj_t.tyb

endif

@SUFFIXES@: .pls .pks .pkb .typ .tyb .html .pls_run .pks_run .pkb_run .typ_run .tyb_run

# Dependencies

dbug_trigger.pls_run dbug.pkb_run: dbug.pks_run

dbug_call_tab_t.typ_run: dbug_call_obj_t.typ_run

dbug_obj_t.typ_run: dbug_call_tab_t.typ_run

dbug_log4plsql_obj_t.tyb_run dbug_log4plsql.pls_run: dbug_log4plsql_obj_t.typ_run

dbug_obj_t.tyb_run dbug.pkb_run: dbug_obj_t.typ_run

dbug_plsdbug_obj_t.tyb_run dbug_plsdbug.pls_run: dbug_plsdbug_obj_t.typ_run

# End of dependencies

uninstall: dbug_uninstall.sql_run clean

dbug_uninstall.sql_run: dbug_uninstall.sql
	echo exit SQL.SQLCODE | ( SQLPATH=$(srcdir) && export SQLPATH && $(SQLPLUS) $(USERID) @$< )

.pls.pls_run:
	echo exit SQL.SQLCODE | ( SQLPATH=$(srcdir) && export SQLPATH && $(SQLPLUS) $(USERID) @$< )
	@touch $@

.pks.pks_run:
	echo exit SQL.SQLCODE | ( SQLPATH=$(srcdir) && export SQLPATH && $(SQLPLUS) $(USERID) @$< )
	@touch $@

.pkb.pkb_run:
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

.pks.html:
	sed 's/-- =pod/=pod/g;s/-- =cut/=cut/g' $? | @PERL@ -S pod2html --outfile=$@
