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

# for documentation purposes only
pod_scripts      = dbug.pod dbug_trigger.pod

html_files       = $(pod_scripts:.pod=.html)

sql_scripts      = R__09.PACKAGE_SPEC.DBUG.sql \
                   R__09.PACKAGE_SPEC.DBUG_DBMS_APPLICATION_INFO.sql \
                   R__09.PACKAGE_SPEC.DBUG_DBMS_OUTPUT.sql \
                   R__09.PACKAGE_SPEC.DBUG_LOG4PLSQL.sql \
                   R__09.PACKAGE_SPEC.DBUG_PROFILER.sql \
                   R__09.PACKAGE_SPEC.DBUG_TRIGGER.sql \
                   R__14.PACKAGE_BODY.DBUG.sql \
                   R__14.PACKAGE_BODY.DBUG_DBMS_APPLICATION_INFO.sql \
                   R__14.PACKAGE_BODY.DBUG_DBMS_OUTPUT.sql \
                   R__14.PACKAGE_BODY.DBUG_LOG4PLSQL.sql \
                   R__14.PACKAGE_BODY.DBUG_PROFILER.sql \
                   R__14.PACKAGE_BODY.DBUG_TRIGGER.sql \
                   R__15.TYPE_BODY.DBUG_LOG4PLSQL_OBJ_T.sql \
                   R__15.TYPE_BODY.DBUG_OBJ_T.sql \
                   V0001__TABLE.STD_OBJECTS.sql \
                   V0002__TYPE_SPEC.DBUG_CALL_OBJ_T.sql \
                   V0003__TYPE_SPEC.DBUG_CALL_TAB_T.sql \
                   V0004__TYPE_SPEC.DBUG_LOG4PLSQL_OBJ_T.sql \
                   V0005__TYPE_SPEC.DBUG_OBJ_T.sql \
                   V0006__INDEX.STD_OBJECTS.sql \
                   V0007__CONSTRAINT.STD_OBJECTS.sql \
                   install.sql \
                   uninstall.sql

SUBDIRS          = .

noinst_DATA      = $(html_files)

MOSTLYCLEANFILES = $(html_files)

CLEANFILES       = pod*.tmp

EXTRA_DIST       = $(pod_scripts) \
                   $(html_files) \
                   $(sql_scripts)

POD2HTML        := pod2html

@SUFFIXES@: .pod .html

html: $(html_files)

.pod.html:
	sed 's/-- =pod/=pod/g;s/-- =cut/=cut/g' $? | @PERL@ -S $(POD2HTML) --outfile=$@
