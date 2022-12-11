# PLSDBUG - an Oracle PL/SQL debugging package based on the DBUG C library

The PLSDBUG software is based on an external debugging library written in C
and the plug and play channel architecture of its PL/SQL companion, see also
[DBUG](https://github.com/TransferWare/dbug).  You can find more information
about PLSDBUG [here](https://github.com/TransferWare/plsdbug).

What this software does is to create the glue for adding a DBUG channel named
PLSDBUG to the Oracle PL/SQL DBUG library.

You can activate a channel in your Oracle session by issueing `DBUG.ACTIVATE('PLSDBUG')`. Next when you issue a DBUG routine call, let's say `DBUG.ENTER('MAIN')`, this is what will happen:
1. DBUG checks its active channels (here PLSDBUG) and invokes dynamically `DBUG_<CHANNEL>.ENTER('MAIN')`, hence `DBUG_PLSDBUG.ENTER('MAIN')`.
2. Package `DBUG_PLSDBUG` (one of the database objects from PLSDBUG) will call the external C routine `dbug_enter('MAIN')` **indirectly**.
3. This will be done by sending the encoded call to a server (a process started by calling program `plsdbug`) that is able to invoke [the C debugging library DBUG](https://github.com/TransferWare/dbug) using the [External Procedure Call toolkit (EPC)](https://github.com/TransferWare/epc).

PLSDBUG consists of:
* Oracle objects to be installed in the database.
* a PLSDBUG server (a program named `plsdbug`) that is able to invoke the C debugging library via EPC.
* the C library (`plsdbug.la`).
* C headers.

As mentioned before this software is based on:
1. [DBUG](https://github.com/TransferWare/dbug).
2. [EPC](https://github.com/TransferWare/epc).

## Installation

Clone both the DBUG and EPC repository to the same root (e.g. ~/dev) and then clone PLSDBUG.

Follow these installation steps:

| Step | When |
| :--- | :--- |
| [DATABASE INSTALL](#database-install) | Always |
| [INSTALL FROM SOURCE](#install-from-source) | When you want the install the rest (not the database) from source |

### DATABASE INSTALL

Now install the database parts of DBUG and EPC first:
1. see the [DBUG - DATABASE INSTALL](https://github.com/TransferWare/dbug#database-install).
2. see the [EPC - DATABASE INSTALL](https://github.com/TransferWare/epc#database-install).

There are two methods:
1. use the [Paulissoft Application Tools for Oracle (PATO) GUI](https://github.com/paulissoft/pato-gui)
with the pom.xml file from the project root and schema ORACLE_TOOLS as the owner (same as DBUG and EPC)
2. execute `src/sql/install.sql` connected as the EPC owner using SQL*Plus, SQLcl or SQL Developer

The advantage of the first method is that your installation is tracked and
that you can upgrade later on.

### INSTALL FROM SOURCE

Installation using the GNU build tools is described in file `INSTALL`.

In order to separate build artifacts and source artifacts I usually create a
`build` directory and configure and make it from there:

The whole installation process:

```
$ mkdir ~/dev
$ cd ~/dev
$ for d in dbug epc plsdbug; do git clone https://github.com/TransferWare/$d; done
$ for d in dbug epc plsdbug; do mkdir $d/build; done
$ cd dbug && ./bootstrap && cd build && ../configure && make check install; cd ~/dev
$ cd epc && ./bootstrap && cd build && ../configure && make install USERID=<Oracle connect string>; cd ~/dev
$ cd plsdbug && ./bootstrap && cd build && ../configure && make install USERID=<Oracle connect string>; cd ~/dev
```

The USERID just needs to a valid Oracle connect string, like `scott/tiger@orcl` in the old days.

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
