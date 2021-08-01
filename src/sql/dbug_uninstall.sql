--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL$
REMARK

whenever sqlerror continue

drop package dbug_profiler
/

drop package dbug_dbms_output
/

drop package dbug_dbms_application_info
/

drop package dbug
/

drop package dbug_trigger
/

drop package dbug_log4plsql
/

rem set sql.sqlcode to 0

set termout off

select * from dual
/

set termout on
