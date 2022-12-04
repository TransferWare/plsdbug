CREATE OR REPLACE TYPE BODY "DBUG_PLSDBUG_OBJ_T" 
is

constructor function dbug_plsdbug_obj_t(self in out nocopy dbug_plsdbug_obj_t)
return self as result
is
  l_object_name constant std_objects.object_name%type := 'DBUG_PLSDBUG';
  l_std_object std_object;
begin
  begin
    std_object_mgr.get_std_object(l_object_name, l_std_object);
    self := treat(l_std_object as dbug_plsdbug_obj_t);
    self.dirty := 0;
  exception
    when no_data_found
    then
      self.dirty := 1;
      self.ctx := null;
  end;

  -- essential
  return;
end;

overriding
member function name(self in dbug_plsdbug_obj_t)
return varchar2
is
begin
  return 'DBUG_PLSDBUG';
end name;

overriding
member procedure serialize(self in dbug_plsdbug_obj_t, p_json_object in out nocopy json_object_t)
is
begin
  -- every sub type must first start with (self as <super type>).serialize(p_json_object)
  (self as std_object).serialize(p_json_object);

  p_json_object.put('CTX', ctx);
end serialize;

end;
/

