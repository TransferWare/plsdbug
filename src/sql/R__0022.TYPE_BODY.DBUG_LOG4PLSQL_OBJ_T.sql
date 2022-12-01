CREATE OR REPLACE TYPE BODY "DBUG_LOG4PLSQL_OBJ_T" 
is

constructor function dbug_log4plsql_obj_t(self in out nocopy dbug_log4plsql_obj_t)
return self as result
is
  l_object_name constant std_objects.object_name%type := 'DBUG_LOG4PLSQL';
  l_std_object std_object;
begin
  std_object_mgr.get_std_object(l_object_name, l_std_object);
  self := treat(l_std_object as dbug_log4plsql_obj_t);
  -- do not set dirty, since we do not verify changes

  -- essential
  return;
end;

overriding member function name(self in dbug_log4plsql_obj_t)
return varchar2
is
begin
  return 'DBUG_LOG4PLSQL';
end name;

overriding member procedure print(self in dbug_log4plsql_obj_t)
is
begin
  (self as std_object).print; -- Generalized invocation 
  dbms_output.put_line
  ( utl_lms.format_message
    ( '%s.%s.%s; use log4j: %s; use logtable: %s; use dbms_output: %s'
    , $$PLSQL_UNIT_OWNER
    , $$PLSQL_UNIT
    , 'PRINT'
    --, isdefaultinit integer
    --, llevel number
    --, lsection varchar2(2000)
    --, ltext varchar2(2000)
    , to_char(use_log4j)
    --, use_out_trans integer
    , to_char(use_logtable)
    --, use_alert integer
    --, use_trace integer
    , to_char(use_dbms_output)
    --, init_lsection varchar2(2000)
    --, init_llevel number
    --, dbms_output_wrap integer
    )
  );
end print;

end;
/

