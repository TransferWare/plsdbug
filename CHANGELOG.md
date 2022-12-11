# Changelog

Copyright (C) 1999-2022 G.J. Paulissen 

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Please see the [EPC issue queue](https://github.com/TransferWare/epc/issues) for issues.

Types of changes:
- *Added* for new features.
- *Changed* for changes in existing functionality.
- *Deprecated* for soon-to-be removed features.
- *Removed* for now removed features.
- *Fixed* for any bug fixes.
- *Security* in case of vulnerabilities.

[Unreleased]

- [Add print method to subtypes of std_object.](https://github.com/TransferWare/plsdbug/issues/2)
- [The procedure dbug.set_ignore_buffer_overflow() seems not to work anymore.](https://github.com/TransferWare/plsdbug/issues/1)

## [4.0.0] - 2021-08-02

A new version on GitHub.

### Added

- README.md describes up to date installation instructions
- CHANGELOG.md describes releases found on [PLSDBUG releases](https://sourceforge.net/projects/transferware/files/plsdbug/) and in files Changelog and NEWS
- Maven pom.xml

### Changed

- README now refers to README.md
- ChangeLog now refers to CHANGELOG.md
- NEWS now refers to CHANGELOG.md
- src/sql SQL scripts have been created using the DDL generation of [Oracle Tools](https://github.com/paulissoft/oracle-tools)
- Removed RCS keywords like $Revision$, $HeadURL$, $Header$, $Id$ and $RCSfile$ from source files
- LOG4PLSQL is no longer optional but mandatory
- PL/SQL packages PLSDBUG and DBUG_PLSDBUG are installed only when the PLSDBUG server is built, hence optional for a database installation
- Use of dbms_sesson.sleep in PL/SQL package DBUG_TRIGGER

## [3.1.0]

### Changed

- Updated missing leave calls using Oracle 12C UTL_CALL_STACK (if available)

## [3.0.0]

### Changed

- Added support for log4plsql version 3 and 4

## [2.2.1] - 2014-08-11

### Added

- Added support for Cygwin 1.7.x

## [2.2.0] - 2008-07-28

### Added

- [2027441]: Ignore dbms_output buffer overflow. See package dbug
- Added dbug.trace() calls

### Changed

- Renamed src/sql/install.sql into src/sql/dbug_install.sql to avoid naming conflicts with EPC
- Renamed src/sql/uninstall.sql into src/sql/dbug_uninstall.sql to avoid naming conflicts with EPC
- Renamed src/sql/verify.sql into src/sql/dbug_verify.sql to avoid naming conflicts with EPC
- Solved bugs in dbug.activate() and dbug.active()
- QMS error stack is reconstructed after displaying it using 
  dbug.on_error() or dbug.leave_on_error()

## [2.1.1] - 2008-07-02

### Added

- Added tests for PLSDBUG and LOG4PLSQL persistency support

### Changed

- Solved bugs for PLSDBUG and LOG4PLSQL persistency support
- The module name is printed by dbug.leave for DBMS_OUTPUT and LOG4PLSQL methods
  just like for PLSDBUG

## [2.1.0]

### Added

- Added persistency support (see EPC for details)

## [2.0.1] - 2007-09-09

### Added

- Installation tested on the Mac OS X
- LOG4PLSQL disabling added to README

## [2.0.0]

### Added

- Ability to add extensions (plug and play)
- LOG4PLSQL can be disabled using --with-log4plsql=no

## [1.3.0]

### Added

- Added LOG4PLSQL method
- Missing dbug.leave calls are automatically detected
- Function dbug.on_error and dbug.leave_on_error added
- Added setting log level like Log4J
- Added setting level for a break point

## [1.2.0] - 2005-12-19

### Added

- Based on EPC 4.5.0
- Added Java debugging (src/my/dbug.java)
- Flush dbug statements at the end of a dbug session
- Show the output of dbug triggers

## [1.1.0]

### Added

- Based on EPC 4.2.0
- Added dbms_reputil.from_remote to util/dbug_trigger.sql for enhanced debugging 
  of replicated transactions

## [1.0.0] - 2004-03-12

### Added

- plsdbug library added

### Changed

- TS_DBUG renamed into PLSDBUG
- Performance improved by using oneway functions where possible

## [0.9.0] - 2003-08-21

### Added

- Added GNU build support
- Package dbug can be used in conjunction with PRAGMA RESTRICT_REFERENCES

## [1.0.0] - 1999-12-15

For historical reasons, this is the date of the first TS_DBUG release.

