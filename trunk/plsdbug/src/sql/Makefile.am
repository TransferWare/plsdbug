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

noinst_DATA      = dbug.pls dbug.html dbug.pls_run
noinst_DATA     += dbug_trigger.pls dbug_trigger.html dbug_trigger.pls_run
noinst_DATA     += dbug_plsdbug.pls dbug_plsdbug.html dbug_plsdbug.pls_run
noinst_DATA     += dbug_dbms_output.pls dbug_dbms_output.html dbug_dbms_output.pls_run
noinst_DATA     += dbug_log4plsql.pls dbug_log4plsql.html dbug_log4plsql.pls_run

MOSTLYCLEANFILES = dbug.html dbug_trigger.html dbug_plsdbug.html dbug_dbms_output.html dbug_log4plsql.html

CLEANFILES       = *.pls_run pod*.tmp

EXTRA_DIST       = dbug.pls dbug.html
EXTRA_DIST      += dbug_trigger.pls dbug_trigger.html
EXTRA_DIST      += dbug_plsdbug.pls dbug_plsdbug.html
EXTRA_DIST      += dbug_dbms_output.pls dbug_dbms_output.html
EXTRA_DIST      += dbug_log4plsql.pls dbug_log4plsql.html

@SUFFIXES@: .pls .html .pls_run

.pls.pls_run:
	echo exit SQL.SQLCODE | $(SQLPLUS) $(USERID) @$?
	@touch $@

.pls.html:
	sed 's/-- =pod/=pod/g;s/-- =cut/=cut/g' $? | @PERL@ -S pod2html --outfile=$@
