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

TESTS_PLSDBUG = leave.plsdbug benchmark.plsdbug sleep.plsdbug factorial.plsdbug

TESTS_DBMS_OUTPUT = leave.dbms_output benchmark.dbms_output sleep.dbms_output factorial.dbms_output

if LOG4PLSQL

TESTS_LOG4PLSQL = leave.log4plsql benchmark.log4plsql sleep.log4plsql factorial.log4plsql

LEAVE_LOG4PLSQL = leave.log4plsql

BENCHMARK_LOG4PLSQL = benchmark.log4plsql

SLEEP_LOG4PLSQL = sleep.log4plsql

FACTORIAL_LOG4PLSQL = factorial.log4plsql

else

TESTS_LOG4PLSQL = 

LEAVE_LOG4PLSQL =

BENCHMARK_LOG4PLSQL =

SLEEP_LOG4PLSQL =

FACTORIAL_LOG4PLSQL =

endif

leave: leave.plsdbug leave.dbms_output $(LEAVE_LOG4PLSQL)

benchmark: benchmark.plsdbug benchmark.dbms_output $(BENCHMARK_LOG4PLSQL)

sleep: sleep.plsdbug sleep.dbms_output $(SLEEP_LOG4PLSQL)

factorial: factorial.plsdbug factorial.dbms_output $(FACTORIAL_LOG4PLSQL)

TESTS = leave benchmark sleep factorial

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
$(TESTS):
	@echo : > $@
	@chmod +x $@

dbms_output: benchmark.dbms_output factorial.dbms_output sleep.dbms_output leave.dbms_output

plsdbug: benchmark.plsdbug factorial.plsdbug sleep.plsdbug leave.plsdbug

$(TESTS_PLSDBUG) $(TESTS_DBMS_OUTPUT) $(TESTS_LOG4PLSQL)::
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"

$(TESTS_PLSDBUG)::
# start plsdbug
	-$(STOP_SERVER)
	$(START_SERVER)
	while ! grep "Connected to database...." $@.log; do sleep 1; done
	sleep 2

# GJP 20-06-2008 Use different connections to check persistency
leave.plsdbug::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s /nolog @$(srcdir)/leave.sql $(USERID) 'PLSDBUG' $(PLSDBUG_OPTIONS) 1>/dev/null

leave.dbms_output::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s /nolog @$(srcdir)/leave.sql $(USERID) 'DBMS_OUTPUT' "" 1>$@.lis

leave.log4plsql::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s /nolog @$(srcdir)/leave.sql $(USERID) 'LOG4PLSQL' "" 1>$@.lis

sleep.plsdbug::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/sleep.sql $(SLEEP) 'PLSDBUG' $(PLSDBUG_OPTIONS)

sleep.dbms_output::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/sleep.sql $(SLEEP) 'DBMS_OUTPUT' "" 1>$@.lis

sleep.log4plsql::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/sleep.sql $(SLEEP) 'LOG4PLSQL' "" 1>$@.lis

benchmark.plsdbug::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/benchmark.sql $(VALUE) 'PLSDBUG' $(PLSDBUG_OPTIONS)

benchmark.dbms_output::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/benchmark.sql $(VALUE) 'DBMS_OUTPUT' "" 1>$@.lis

benchmark.log4plsql::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/benchmark.sql $(VALUE) 'LOG4PLSQL' "" 1>$@.lis

factorial.plsdbug::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/factorial.sql $(VALUE) 'PLSDBUG' $(PLSDBUG_OPTIONS)

factorial.dbms_output::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/factorial.sql $(VALUE) 'DBMS_OUTPUT' "" 1>$@.lis

factorial.log4plsql::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/factorial.sql $(VALUE) 'LOG4PLSQL' "" 1>$@.lis

$(TESTS_PLSDBUG)::
	$(STOP_SERVER)
	dbugrpt < dbug.log > $@.lis

$(TESTS_LOG4PLSQL)::
	SQLPATH=""; echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$(srcdir)/log4plsql.sql 1>$@.lis

$(TESTS_PLSDBUG) $(TESTS_DBMS_OUTPUT) $(TESTS_LOG4PLSQL)::
	$(DIFF) $@.lis $(srcdir)/$@.ref
