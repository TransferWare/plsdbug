CREATE OR REPLACE TYPE BODY "DBUG_LOG4PLSQL_OBJ_T" 
is

constructor function dbug_log4plsql_obj_t
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

end;
/

