REMARK Try to call Flyway script beforeEachMigrate.sql (add its directory to SQLPATH) so that PLSQL_CCFlags can be set.
REMARK But no harm done if it is not there.

whenever oserror continue
whenever sqlerror continue
@@beforeEachMigrate.sql

whenever oserror exit failure
whenever sqlerror exit failure
set define off sqlblanklines on
ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

prompt @@0001.TYPE_SPEC.DBUG_PLSDBUG_OBJ_T.sql
@@0001.TYPE_SPEC.DBUG_PLSDBUG_OBJ_T.sql
show errors TYPE "DBUG_PLSDBUG_OBJ_T"
prompt @@R__0002.PACKAGE_SPEC.DBUG_PLSDBUG.sql
@@R__0002.PACKAGE_SPEC.DBUG_PLSDBUG.sql
show errors PACKAGE "DBUG_PLSDBUG"
prompt @@R__0003.PACKAGE_BODY.DBUG_PLSDBUG.sql
@@R__0003.PACKAGE_BODY.DBUG_PLSDBUG.sql
show errors PACKAGE BODY "DBUG_PLSDBUG"
prompt @@R__0004.TYPE_BODY.DBUG_PLSDBUG_OBJ_T.sql
@@R__0004.TYPE_BODY.DBUG_PLSDBUG_OBJ_T.sql
show errors TYPE BODY "DBUG_PLSDBUG_OBJ_T"
prompt @@R__0005.PACKAGE_SPEC.PLSDBUG.sql
@@R__0005.PACKAGE_SPEC.PLSDBUG.sql
show errors PACKAGE "PLSDBUG"
prompt @@R__0006.PACKAGE_BODY.PLSDBUG.sql
@@R__0006.PACKAGE_BODY.PLSDBUG.sql
show errors PACKAGE BODY "PLSDBUG"
prompt @@R__0007.PACKAGE_SPEC.UT_PLSDBUG.sql
@@R__0007.PACKAGE_SPEC.UT_PLSDBUG.sql
show errors PACKAGE "UT_PLSDBUG"
prompt @@R__0008.PACKAGE_BODY.UT_PLSDBUG.sql
@@R__0008.PACKAGE_BODY.UT_PLSDBUG.sql
show errors PACKAGE BODY "UT_PLSDBUG"
