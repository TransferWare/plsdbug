/* perl generate_ddl.pl (version 2023-01-05) --nodynamic-sql --force-view --group-constraints --skip-install-sql --source-schema=EPCAPP --strip-source-schema */

/*
-- JDBC url - username : jdbc:oracle:thin:@pato - EPCAPP
-- source schema       : 
-- source database link: 
-- target schema       : EPCAPP
-- target database link: 
-- object type         : 
-- object names include: 1
-- object names        : DBUG_PLSDBUG_OBJ_T,
      DBUG_PLSDBUG,
      PLSDBUG,
      UT_PLSDBUG,
-- skip repeatables    : 0
-- interface           : pkg_ddl_util v5
-- transform params    : 
-- exclude objects     : 
-- include objects     : 
-- owner               : ORACLE_TOOLS
*/
-- pkg_ddl_util v5
call dbms_application_info.set_module('uninstall.sql', null);
/* SQL statement 1 (DROP;EPCAPP;PACKAGE_BODY;DBUG_PLSDBUG;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 1');
DROP PACKAGE BODY DBUG_PLSDBUG;

/* SQL statement 2 (DROP;EPCAPP;PACKAGE_BODY;PLSDBUG;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 2');
DROP PACKAGE BODY PLSDBUG;

/* SQL statement 3 (DROP;EPCAPP;PACKAGE_BODY;UT_PLSDBUG;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 3');
DROP PACKAGE BODY UT_PLSDBUG;

/* SQL statement 4 (DROP;EPCAPP;PACKAGE_SPEC;DBUG_PLSDBUG;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 4');
DROP PACKAGE DBUG_PLSDBUG;

/* SQL statement 5 (DROP;EPCAPP;PACKAGE_SPEC;PLSDBUG;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 5');
DROP PACKAGE PLSDBUG;

/* SQL statement 6 (DROP;EPCAPP;PACKAGE_SPEC;UT_PLSDBUG;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 6');
DROP PACKAGE UT_PLSDBUG;

/* SQL statement 7 (DROP;EPCAPP;TYPE_BODY;DBUG_PLSDBUG_OBJ_T;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 7');
DROP TYPE BODY DBUG_PLSDBUG_OBJ_T;

/* SQL statement 8 (DROP;EPCAPP;TYPE_SPEC;DBUG_PLSDBUG_OBJ_T;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 8');
DROP TYPE DBUG_PLSDBUG_OBJ_T FORCE;

