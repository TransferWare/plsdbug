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

.pl.html:
	@PERL@ -S pod2html --infile=$< --outfile=$@

.sql.html:
	@PERL@ -S pod2html --infile=$< --outfile=$@

sql_files            = dbug_pls.sql dbug_trigger.sql
pl_files             = dbug_trigger_show.pl
html_files           = $(sql_files:.sql=.html) $(pl_files:.pl=.html)

EXTRA_DIST           = $(sql_files) $(pl_files) $(html_files)

CLEANFILES           = $(html_files) pod2htm*.tmp

html: $(html_files)
