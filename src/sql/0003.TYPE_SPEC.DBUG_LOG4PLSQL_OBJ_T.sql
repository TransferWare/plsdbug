CREATE TYPE "DBUG_LOG4PLSQL_OBJ_T" AUTHID DEFINER under std_object (
  isdefaultinit integer
, llevel number
, lsection varchar2(2000)
, ltext varchar2(2000)
, use_log4j integer
, use_out_trans integer
, use_logtable integer
, use_alert integer
, use_trace integer
, use_dbms_output integer
, init_lsection varchar2(2000)
, init_llevel number
, dbms_output_wrap integer

, constructor function dbug_log4plsql_obj_t(self in out nocopy dbug_log4plsql_obj_t)
  return self as result

, overriding member function name(self in dbug_log4plsql_obj_t)
  return varchar2

, overriding member procedure print(self in dbug_log4plsql_obj_t)

) final;
/

