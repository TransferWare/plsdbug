--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL: https://svn.code.sf.net/p/transferware/code/trunk/plsdbug/src/sql/dbug_uninstall.sql $
REMARK

whenever sqlerror continue

drop type dbug_log4plsql_obj_t
/

drop package dbug_log4plsql
/

rem set sql.sqlcode to 0

set termout off

select * from dual
/
