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

EXTRA_DIST           = benchmark.sql benchmark.plsdbug.ref
EXTRA_DIST          += factorial.sql factorial.plsdbug.ref
EXTRA_DIST          += sleep.sql sleep.plsdbug.ref
EXTRA_DIST          += leave.sql leave.plsdbug.ref

TESTS_PLSDBUG        = leave.plsdbug benchmark.plsdbug sleep.plsdbug factorial.plsdbug

leave: leave.plsdbug

benchmark: benchmark.plsdbug

sleep: sleep.plsdbug

factorial: factorial.plsdbug

TESTS = leave benchmark sleep factorial

PLSDBUG = $(top_builddir)/src/prog/plsdbug_local
DBUG_OPTIONS = -Dd,g,t,O

# run the server in the background and purge the request pipe
PIPE = "DBUG_`dirname $(USERID)`"
START_SERVER = @PERL@ -S epcdaemon.pl \
               --verbose $(PLSDBUG) -p$(PIPE) -P $(DBUG_OPTIONS) -u$(USERID) 1>$@.log 2>&1

STOP_SERVER = echo "Killing server at `date`" && $(PLSDBUG) -p$(PIPE) -I -u$(USERID) && sleep 1 && ! ps | grep plsdbug_local | grep -v grep

DIFF = diff -w

DBUG_LOGFILE = dbug.log

PLSDBUG_OPTIONS = d,t,o=$(DBUG_LOGFILE)

SLEEP = 5

VALUE = 10

# Utility targets
start_server:
	-$(STOP_SERVER)
	@test ! -f $(DBUG_LOGFILE) || rm $(DBUG_LOGFILE)
	$(START_SERVER)
	while ! grep "Connected to database...." $@.log; do sleep 1; done
	sleep 2

stop_server:
	$(STOP_SERVER)
	dbugrpt < $(DBUG_LOGFILE) > $@.lis

leave_plsdbug:
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s /nolog @$(srcdir)/leave.sql $(USERID) 'PLSDBUG' $(PLSDBUG_OPTIONS) 1>$@.log 2>&1

# Ensure the created dummy test scripts are executable (chmod +x)
$(TESTS):
	@echo : > $@
	@chmod +x $@

plsdbug: benchmark.plsdbug factorial.plsdbug sleep.plsdbug leave.plsdbug

$(TESTS_PLSDBUG)::
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"

$(TESTS_PLSDBUG)::
# start plsdbug
	-$(STOP_SERVER)
	@test ! -f $(DBUG_LOGFILE) || rm $(DBUG_LOGFILE)
	$(START_SERVER)
	while ! grep "Connected to database...." $@.log; do sleep 1; done
	sleep 2

# GJP 20-06-2008 Use different connections to check persistency
leave.plsdbug::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s /nolog @$(srcdir)/leave.sql $(USERID) 'PLSDBUG' $(PLSDBUG_OPTIONS)

sleep.plsdbug::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/sleep.sql $(SLEEP) 'PLSDBUG' $(PLSDBUG_OPTIONS)

benchmark.plsdbug::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/benchmark.sql $(VALUE) 'PLSDBUG' $(PLSDBUG_OPTIONS)

factorial.plsdbug::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/factorial.sql 'PLSDBUG' $(PLSDBUG_OPTIONS)

$(TESTS_PLSDBUG)::
	$(STOP_SERVER)
	dbugrpt < $(DBUG_LOGFILE) > $@.lis

$(TESTS_PLSDBUG)::
	$(DIFF) $@.lis $(srcdir)/$@.ref
