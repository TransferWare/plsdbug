# -*-fundamental-*-
# Process this file with autoconf to produce a configure script.

# Copyright (C) 2002-2022 G.J. Paulissen
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

AC_PREREQ([2.71])
AC_REVISION([2022-12-01])
AC_INIT([plsdbug],[5.0.0],[gert.jan.paulissen@gmail.com])

# version check
if test -f "$srcdir/VERSION"
then
  read version < $srcdir/VERSION
else
  version=
fi

if test "$version" != "$PACKAGE_VERSION"
then
  echo "Updating file $srcdir/VERSION with package version $PACKAGE_VERSION." 1>&2
  echo "$PACKAGE_VERSION" > $srcdir/VERSION
	test -d $srcdir/.mvn || mkdir $srcdir/.mvn
	echo "-Drevision=$PACKAGE_VERSION" > $srcdir/.mvn/maven.config
fi

# Use same configuration file as EPC
AC_CONFIG_MACRO_DIR([config])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_SRCDIR([src/prog/main.c])
AC_CONFIG_HEADERS([config.h])

AC_CANONICAL_HOST
AM_INIT_AUTOMAKE
# AM_C_PROTOTYPES

# Checks for programs.
# Checks for programs.
AC_PATH_PROG([PERL],[perl])
case x$PERL in
x)
	# No Perl avaliable: stop
	AC_MSG_ERROR([Perl must be available in \$PATH.])
	;;
esac
dnl AC_ARG_VAR(PERL,[The program name of Perl.])
AC_PROG_CC

LT_INIT([win32-dll])

case ${host_os} in
*darwin*)
  case "${enable_shared}" in
	yes)
    AC_MSG_NOTICE([On Mac OS X you should disable shared libraries (configure --help)])
    enable_shared=no
    enable_static=yes
    ;;
	no)
    ;;
  esac
  darwin=true
  ;;
*)
  darwin=false
  ;;
esac

AM_CONDITIONAL([DARWIN], [test x$darwin = xtrue])

# For ORACLE_LDFLAGS and ORACLE_LIBS
ACX_PROG_PROC
# Oracle sqlplus
ACX_PROG_SQLPLUS

# Enable dbug
ACX_DBUG

# Enable epc
ACX_EPC

# Checks for header files.
AC_CHECK_INCLUDES_DEFAULT
AC_PROG_EGREP

AC_CHECK_HEADERS([assert.h malloc.h stdlib.h string.h strings.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST

# Checks for library functions.
AC_FUNC_MALLOC

# This is necessary so that .o files in LIBOBJS are also built via
# the ANSI2KNR-filtering rules.
LIB@&t@OBJS=`echo "$LIB@&t@OBJS" |
             sed 's,\.[[^.]]* ,$U&,g;s,\.[[^.]]*$,$U&,'`
LTLIBOBJS=`echo "$LIB@&t@OBJS" |
           sed 's,\.[[^.]]* ,.lo ,g;s,\.[[^.]]*$,.lo,'`
AC_SUBST(LTLIBOBJS)dnl
AC_SUBST(ac_aux_dir)dnl

AC_CONFIG_FILES([Makefile])
AC_CONFIG_FILES([src/Makefile])
AC_CONFIG_FILES([src/lib/Makefile])
AC_CONFIG_FILES([src/prog/Makefile])
AC_CONFIG_FILES([src/sql/Makefile])
AC_CONFIG_FILES([test/Makefile])

AC_OUTPUT

echo \
"------------------------------------------------------------------------
Configuration:

  Source code location:       ${srcdir}
  Compiler:                   ${CC}
  Compiler flags:             ${CFLAGS}
  Host System Type:           ${host}
  Install path:               ${prefix}

  See config.h for further configuration information.
------------------------------------------------------------------------"


