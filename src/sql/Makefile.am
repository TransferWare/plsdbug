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

noinst_DATA      = dbug.pls dbug.html dbug.pls_run dbug_trigger.pls dbug_trigger.html dbug_trigger.pls_run

MOSTLYCLEANFILES = dbug.html dbug_trigger.html

CLEANFILES       = *.pls_run pod*.tmp

EXTRA_DIST       = Imakefile dbug.pls dbug.html dbug_trigger.pls dbug_trigger.html

@SUFFIXES@: .pls .html .pls_run

.pls.pls_run:
	echo exit SQL.SQLCODE | $(SQLPLUS) $(USERID) @$?
	@touch $@

.pls.html:
	sed 's/-- =pod/=pod/g;s/-- =cut/=cut/g' $? | @PERL@ -S pod2html --outfile=$@


