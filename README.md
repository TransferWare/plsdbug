# PLSDBUG, a PL/SQL debugging package

This is [PLSDBUG, a PL/SQL debugging
package](https://github.com/TransferWare/plsdbug).

It is used to:
- create a program plsdbug to receive debugging messages from Oracle PL/SQL

The following output channels are available:
- PLSDBUG which interfaces with the PLSDBUG server and is based on:
  1. the [External Procedure Call toolkit (EPC)](https://github.com/TransferWare/epc)
  2. the [C debugging library DBUG](https://github.com/TransferWare/dbug)

PLSDBUG itself consists of:
1. a PL/SQL library to be installed in the database
2. the C library (-lplsdbug)
3. a PLSDBUG server (a program named `plsdbug`)
4. C headers

Follow these installation steps:

| Step | When |
| :--- | :--- |
| [DATABASE INSTALL](#database-install) | Always |
| [INSTALL FROM SOURCE](#install-from-source) | When you want the install the rest (not the database) from source |
| [INSTALL](#install) | When you want the install the rest and you have a `configure` script |

## CHANGELOG

See the file [CHANGELOG.md](CHANGELOG.md).

## DATABASE INSTALL

This section explains how to install just the PL/SQL library.

### Preconditions

Install the database part of the EPC.

### Installation

There are two methods to install the PLSDBUG PL/SQL library:
1. use the [Paulissoft Application Tools for Oracle (PATO) GUI](https://github.com/paulissoft/pato-gui)
with the pom.xml file from the project root and schema ORACLE_TOOLS as the owner
2. execute `src/sql/install.sql` connected as the owner using SQL*Plus, SQLcl or SQL Developer

The advantage of the first method is that your installation is tracked and
that you can upgrade later on.

## INSTALL FROM SOURCE

Also called the MAINTAINER BUILD. You just need the sources either cloned from
[PLSBUG on GitHub](https://github.com/TransferWare/plsdbug) or from a source
archive.

You need a Unix shell which is available on Mac OS X, Linux and Unix of course.
On Windows you can use the Windows Subsystem for Linux (WSL), Cygwin or Git Bash.

You need the following programs:
- automake
- autoconf
- libtool (on Mac OS X you need glibtool)

Next the following command will generate the Autotools `configure` script:

```
$ ./bootstrap
```

## INSTALL

The PLSDBUG package depends on package [DBUG, a C debugging
library](https://github.com/TransferWare/dbug) and
[EPC](https://github.com/TransferWare/epc). All packages should be installed
into the same lib and bin directories (e.g. use the same prefix when
installing).

This section explains how to install the complete toolkit (including the PL/SQL library).

### Preconditions

Install DBUG and EPC (non database part).

Here you need either a distribution archive with the `configure` script or you must have bootstrapped your environment.

Next the following command will generate the Autotools `configure` script:

```
$ ./bootstrap
```

### Build

See file `INSTALL` for further installation instructions. Do not forget to set
environment variable USERID as the Oracle connect string. This will install
the PLSDBUG and DBUG_PLSDBUG package for interfacing with the `plsdbug`
executable.

## DOCUMENTATION

Issue this to (re-)generate the documentation:

```
$ make html
```

In the build directory you will find these files now:
- `src/sql/dbug_trigger.html`
- `src/sql/dbug.html`
- `util/dbug_trigger.html`
- `util/dbug_pls.html`
- `util/dbug_trigger_show.html`
