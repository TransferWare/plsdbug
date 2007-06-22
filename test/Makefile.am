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

EXTRA_DIST           = benchmark.sql factorial.sql sleep.sql leave.sql

@SUFFIXES@: .run .sql

.sql.run:
	echo exit SQL.SQLCODE | $(SQLPLUS) $(USERID) @$<

TESTS = benchmark sleep factorial leave

FORCE = force

PLSDBUG = plsdbug
PLSDBUG_OPTIONS = -Dd,g,t,O

DIFF = diff -w

OPTIONS = d,t,o=dbug.log

SLEEP = 5

VALUE = 10

# Ensure the created dummy test scripts are executable (chmod +x)

leave: $(srcdir)/leave.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
	echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$< 1>$@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

sleep: $(srcdir)/sleep.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
# start plsdbug
	pipe="DBUG_`dirname $(USERID)`"; $(PLSDBUG) $(PLSDBUG_OPTIONS) -u$(USERID) -p$$pipe 1>$@.log 2>&1 &
	while ! grep "Connected to database...." $@.log; do sleep 1; done
	sleep 1
# run test
	echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$< $(OPTIONS) $(SLEEP)
	@-ps | grep $(PLSDBUG)
	pid=`ps | grep $(PLSDBUG) | grep -v grep | awk '{ print $$1; }'`; for p in $$pid; do kill $$p; done
	dbugrpt < dbug.log > $@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

benchmark: $(srcdir)/benchmark.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
# start plsdbug
	pipe="DBUG_`dirname $(USERID)`"; $(PLSDBUG) $(PLSDBUG_OPTIONS) -u$(USERID) -p$$pipe 1>$@.log 2>&1 &
	while ! grep "Connected to database...." $@.log; do sleep 1; done
	sleep 1
# run test
	echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$< $(OPTIONS) $(VALUE)
	@-ps | grep $(PLSDBUG)
	pid=`ps | grep $(PLSDBUG) | grep -v grep | awk '{ print $$1; }'`; for p in $$pid; do kill $$p; done
	dbugrpt < dbug.log > $@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

factorial: $(srcdir)/factorial.sql $(FORCE)
# test USERID
	@echo 'Checking whether USERID is set' && test -n "$(USERID)"
# start plsdbug
	pipe="DBUG_`dirname $(USERID)`"; $(PLSDBUG) $(PLSDBUG_OPTIONS) -u$(USERID) -p$$pipe 1>$@.log 2>&1 &
	while ! grep "Connected to database...." $@.log; do sleep 1; done
	sleep 1
# run test
	echo exit SQL.SQLCODE | $(SQLPLUS) -s $(USERID) @$< $(OPTIONS) $(VALUE)
	@-ps | grep $(PLSDBUG)
	pid=`ps | grep $(PLSDBUG) | grep -v grep | awk '{ print $$1; }'`; for p in $$pid; do kill $$p; done
	dbugrpt < dbug.log > $@.lis
	$(DIFF) $@.lis $(srcdir)/$@.ref
# make the target $@
	@echo : > $@
	@chmod +x $@

force: ;
