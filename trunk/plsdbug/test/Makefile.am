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

MOSTLYCLEANFILES     = 

CLEANFILES           = $(TESTS) *.log *.lis

EXTRA_DIST           = benchmark.sql benchmark.dbms_output.ref benchmark.plsdbug.ref
EXTRA_DIST          += factorial.sql factorial.dbms_output.ref factorial.plsdbug.ref
EXTRA_DIST          += sleep.sql sleep.dbms_output.ref sleep.plsdbug.ref
EXTRA_DIST          += leave.sql leave.dbms_output.ref leave.plsdbug.ref

@SUFFIXES@: .run .sql

.sql.run:
	echo exit SQL.SQLCODE | $(SQLPLUS) $(USERID) @$<

TESTS = leave.dbms_output leave.plsdbug \
        benchmark.dbms_output benchmark.plsdbug \
	sleep.dbms_output sleep.plsdbug \
	factorial.dbms_output sleep.plsdbug

dbms_output: benchmark.dbms_output factorial.dbms_output sleep.dbms_output leave.dbms_output

plsdbug: benchmark.plsdbug factorial.plsdbug sleep.plsdbug leave.plsdbug

FORCE = force

PLSDBUG = $(top_builddir)/src/prog/plsdbug
DBUG_OPTIONS = -Dd,g,t,O

# run the server in the background and purge the request pipe
PIPE = "DBUG_`dirname $(USERID)`"
START_SERVER = @PERL@ -S epcdaemon.pl \
               --verbose $(PLSDBUG) -p$(PIPE) -P $(DBUG_OPTIONS) -u$(USERID) 1>$@.log 2>&1

STOP_SERVER = echo "Killing server at `date`" && $(PLSDBUG) -p$(PIPE) -I -u$(USERID)

DIFF = diff -w

PLSDBUG_OPTIONS = d,t,o=dbug.log

SLEEP = 5

VALUE = 10

# Ensure the created dummy test scripts are executable (chmod +x)

leave.dbms_output: $(srcdir)/leave.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
# GJP 20-06-2008 Use different connections to check persistency
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s /nolog @$< $(USERID) 'DBMS_OUTPUT' "" 1>$@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

# GJP 01-07-2008 Run for PLSDBUG also
leave.plsdbug: $(srcdir)/leave.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
# start plsdbug
	-$(STOP_SERVER)
	$(START_SERVER)
	while ! grep "Connected to database...." $@.log; do sleep 1; done
	sleep 1
# run test
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s /nolog @$< $(USERID) 'PLSDBUG' $(PLSDBUG_OPTIONS) 1>/dev/null
	$(STOP_SERVER)
	dbugrpt < dbug.log > $@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

# GJP 01-07-2008 Run for DBMS_OUTPUT also
sleep.dbms_output: $(srcdir)/sleep.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$< $(SLEEP) 'DBMS_OUTPUT' "" 1>$@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

sleep.plsdbug: $(srcdir)/sleep.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
# start plsdbug
	-$(STOP_SERVER)
	$(START_SERVER)
	while ! grep "Connected to database...." $@.log; do sleep 1; done
	sleep 1
# run test
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$< $(SLEEP) 'PLSDBUG' $(PLSDBUG_OPTIONS)
	$(STOP_SERVER)
	dbugrpt < dbug.log > $@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

benchmark.plsdbug: $(srcdir)/benchmark.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
# start plsdbug
	-$(STOP_SERVER)
	$(START_SERVER)
	while ! grep "Connected to database...." $@.log; do sleep 1; done
	sleep 1
# run test
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$< $(VALUE) 'PLSDBUG' $(PLSDBUG_OPTIONS)
	$(STOP_SERVER)
	dbugrpt < dbug.log > $@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

# GJP 01-07-2008 Run for DBMS_OUTPUT also
benchmark.dbms_output: $(srcdir)/benchmark.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$< $(VALUE) 'DBMS_OUTPUT' "" 1>$@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

# GJP 01-07-2008 Run for DBMS_OUTPUT also
factorial.dbms_output: $(srcdir)/factorial.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$< $(VALUE) 'DBMS_OUTPUT' "" 1>$@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

factorial.plsdbug: $(srcdir)/factorial.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
# start plsdbug
	-$(STOP_SERVER)
	$(START_SERVER)
	while ! grep "Connected to database...." $@.log; do sleep 1; done
	sleep 1
# run test
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$< $(VALUE) 'PLSDBUG' $(PLSDBUG_OPTIONS)
	$(STOP_SERVER)
	dbugrpt < dbug.log > $@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

force: ;
