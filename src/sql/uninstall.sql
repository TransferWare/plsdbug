/* perl generate_ddl.pl (version 2021-07-28) --nodynamic-sql --force-view --noremove-output-directory --skip-install-sql --nostrip-source-schema */

/*
-- JDBC url            : jdbc:oracle:thin:ORACLE_TOOLS@//localhost:1521/orcl
-- source schema       : 
-- source database link: 
-- target schema       : ORACLE_TOOLS
-- target database link: 
-- object type         : 
-- object names include: 1
-- object names        : DBUG,DBUG_CALL_OBJ_T,DBUG_CALL_TAB_T,DBUG_DBMS_APPLICATION_INFO,DBUG_DBMS_OUTPUT,DBUG_LOG4PLSQL,DBUG_LOG4PLSQL_OBJ_T,DBUG_LOG4PLSQL,DBUG_LOG4PLSQL_OBJ_T,DBUG_OBJ_T,DBUG_PROFILER,DBUG_TRIGGER,STD_OBJECTS
-- skip repeatables    : 0
-- interface           : pkg_ddl_util v4
-- owner               : ORACLE_TOOLS
*/
-- pkg_ddl_util v4
call dbms_application_info.set_module('uninstall.sql', null);
/* SQL statement 1 (ALTER;ORACLE_TOOLS;CONSTRAINT;STD_OBJECTS_CHK4;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 1');
ALTER TABLE "ORACLE_TOOLS"."STD_OBJECTS" DROP CONSTRAINT STD_OBJECTS_CHK4;

/* SQL statement 2 (ALTER;ORACLE_TOOLS;CONSTRAINT;STD_OBJECTS_CHK3;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 2');
ALTER TABLE "ORACLE_TOOLS"."STD_OBJECTS" DROP CONSTRAINT STD_OBJECTS_CHK3;

/* SQL statement 3 (ALTER;ORACLE_TOOLS;CONSTRAINT;STD_OBJECTS_CHK2;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 3');
ALTER TABLE "ORACLE_TOOLS"."STD_OBJECTS" DROP CONSTRAINT STD_OBJECTS_CHK2;

/* SQL statement 4 (ALTER;ORACLE_TOOLS;CONSTRAINT;STD_OBJECTS_CHK1;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 4');
ALTER TABLE "ORACLE_TOOLS"."STD_OBJECTS" DROP CONSTRAINT STD_OBJECTS_CHK1;

/* SQL statement 5 (ALTER;ORACLE_TOOLS;CONSTRAINT;STD_OBJECTS_PK;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 5');
ALTER TABLE "ORACLE_TOOLS"."STD_OBJECTS" DROP PRIMARY KEY KEEP INDEX;

/* SQL statement 6 (DROP;ORACLE_TOOLS;INDEX;STD_OBJECTS_PK;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 6');
DROP INDEX ORACLE_TOOLS.STD_OBJECTS_PK;

/* SQL statement 7 (DROP;ORACLE_TOOLS;PACKAGE_BODY;DBUG;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 7');
DROP PACKAGE BODY ORACLE_TOOLS.DBUG;

/* SQL statement 8 (DROP;ORACLE_TOOLS;PACKAGE_BODY;DBUG_DBMS_APPLICATION_INFO;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 8');
DROP PACKAGE BODY ORACLE_TOOLS.DBUG_DBMS_APPLICATION_INFO;

/* SQL statement 9 (DROP;ORACLE_TOOLS;PACKAGE_BODY;DBUG_DBMS_OUTPUT;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 9');
DROP PACKAGE BODY ORACLE_TOOLS.DBUG_DBMS_OUTPUT;

/* SQL statement 10 (DROP;ORACLE_TOOLS;PACKAGE_BODY;DBUG_LOG4PLSQL;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 10');
DROP PACKAGE BODY ORACLE_TOOLS.DBUG_LOG4PLSQL;

/* SQL statement 11 (DROP;ORACLE_TOOLS;PACKAGE_BODY;DBUG_PROFILER;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 11');
DROP PACKAGE BODY ORACLE_TOOLS.DBUG_PROFILER;

/* SQL statement 12 (DROP;ORACLE_TOOLS;PACKAGE_BODY;DBUG_TRIGGER;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 12');
DROP PACKAGE BODY ORACLE_TOOLS.DBUG_TRIGGER;

/* SQL statement 13 (DROP;ORACLE_TOOLS;PACKAGE_SPEC;DBUG_DBMS_APPLICATION_INFO;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 13');
DROP PACKAGE ORACLE_TOOLS.DBUG_DBMS_APPLICATION_INFO;

/* SQL statement 14 (DROP;ORACLE_TOOLS;PACKAGE_SPEC;DBUG_DBMS_OUTPUT;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 14');
DROP PACKAGE ORACLE_TOOLS.DBUG_DBMS_OUTPUT;

/* SQL statement 15 (DROP;ORACLE_TOOLS;PACKAGE_SPEC;DBUG_LOG4PLSQL;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 15');
DROP PACKAGE ORACLE_TOOLS.DBUG_LOG4PLSQL;

/* SQL statement 16 (DROP;ORACLE_TOOLS;PACKAGE_SPEC;DBUG_PROFILER;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 16');
DROP PACKAGE ORACLE_TOOLS.DBUG_PROFILER;

/* SQL statement 17 (DROP;ORACLE_TOOLS;PACKAGE_SPEC;DBUG_TRIGGER;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 17');
DROP PACKAGE ORACLE_TOOLS.DBUG_TRIGGER;

/* SQL statement 18 (DROP;ORACLE_TOOLS;TYPE_BODY;DBUG_OBJ_T;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 18');
DROP TYPE BODY ORACLE_TOOLS.DBUG_OBJ_T;

/* SQL statement 19 (DROP;ORACLE_TOOLS;PACKAGE_SPEC;DBUG;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 19');
DROP PACKAGE ORACLE_TOOLS.DBUG;

/* SQL statement 20 (DROP;ORACLE_TOOLS;TYPE_BODY;DBUG_LOG4PLSQL_OBJ_T;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 20');
DROP TYPE BODY ORACLE_TOOLS.DBUG_LOG4PLSQL_OBJ_T;

/* SQL statement 21 (DROP;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 21');
DROP TABLE ORACLE_TOOLS.STD_OBJECTS PURGE;

/* SQL statement 22 (DROP;ORACLE_TOOLS;TYPE_SPEC;DBUG_OBJ_T;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 22');
DROP TYPE ORACLE_TOOLS.DBUG_OBJ_T;

/* SQL statement 23 (DROP;ORACLE_TOOLS;TYPE_SPEC;DBUG_CALL_TAB_T;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 23');
DROP TYPE ORACLE_TOOLS.DBUG_CALL_TAB_T;

/* SQL statement 24 (DROP;ORACLE_TOOLS;TYPE_SPEC;DBUG_CALL_OBJ_T;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 24');
DROP TYPE ORACLE_TOOLS.DBUG_CALL_OBJ_T;

/* SQL statement 25 (DROP;ORACLE_TOOLS;TYPE_SPEC;DBUG_LOG4PLSQL_OBJ_T;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 25');
DROP TYPE ORACLE_TOOLS.DBUG_LOG4PLSQL_OBJ_T;

