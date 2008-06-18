create or replace type dbug_log4plsql_obj_t under std_object (
  isdefaultinit integer
, llevel number
, lsection varchar2(2000)
, ltexte varchar2(2000)
, use_log4j integer
, use_out_trans integer
, use_logtable integer
, use_alert integer
, use_trace integer
, use_dbms_output integer
, init_lsection varchar2(2000)
, init_llevel number
, dbms_pipe_name varchar2(255)
, constructor function dbug_log4plsql_obj_t
  return self as result
)
/

show errors
