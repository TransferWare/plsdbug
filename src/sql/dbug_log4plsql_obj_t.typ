--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL$
REMARK

declare
  -- ORA-02303: cannot drop or replace a type with type or table dependents
  e_type_has_dependencies exception;
  pragma exception_init(e_type_has_dependencies, -2303);
begin
  execute immediate 'create or replace type dbug_log4plsql_obj_t under std_object (
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

, overriding member function name(self in dbug_log4plsql_obj_t)
  return varchar2
) final
';
exception
  when e_type_has_dependencies
  then
    null;
end;
/

@dbug_verify dbug_log4plsql_obj_t type
