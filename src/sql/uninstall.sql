/* perl generate_ddl.pl (version 2021-08-27) --nodynamic-sql --force-view --skip-install-sql --nostrip-source-schema */

/*
-- JDBC url            : jdbc:oracle:thin:ORACLE_TOOLS@//localhost:1521/orcl
-- source schema       : 
-- source database link: 
-- target schema       : ORACLE_TOOLS
-- target database link: 
-- object type         : 
-- object names include: 1
-- object names        : DBUG,
DBUG_CALL_OBJ_T,
DBUG_CALL_TAB_T,
DBUG_DBMS_APPLICATION_INFO,
DBUG_DBMS_OUTPUT,
DBUG_LOG4PLSQL,
DBUG_LOG4PLSQL_OBJ_T,
DBUG_LOG4PLSQL,
DBUG_LOG4PLSQL_OBJ_T,
DBUG_PLSDBUG_OBJ_T,
DBUG_OBJ_T,
DBUG_PROFILER,
DBUG_TRIGGER,
STD_OBJECTS
-- skip repeatables    : 0
-- interface           : pkg_ddl_util v5
-- transform params    : 
-- owner               : ORACLE_TOOLS
*/

drop PACKAGE PLSDBUG;

drop PACKAGE DBUG_PLSDBUG;

drop TYPE DBUG_PLSDBUG_OBJ_T;


