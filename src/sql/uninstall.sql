--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL$
REMARK

whenever sqlerror continue

drop type dbug_plsdbug_obj_t
/

drop type dbug_log4plsql_obj_t
/

drop type dbug_obj_t
/

drop type dbug_call_tab_t
/

drop type dbug_call_obj_t
/

drop package dbug_plsdbug
/

drop package dbug_dbms_output
/

drop package dbug_log4plsql
/

rem set sql.sqlcode to 0

set termout off

select * from dual
/
