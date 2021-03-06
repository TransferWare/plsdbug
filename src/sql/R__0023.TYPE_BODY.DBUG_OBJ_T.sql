CREATE OR REPLACE TYPE BODY "DBUG_OBJ_T" 
is

constructor function dbug_obj_t(self in out nocopy dbug_obj_t)
return self as result
is
  l_object_name constant std_objects.object_name%type := 'DBUG';
  l_std_object std_object;
begin
  begin
    std_object_mgr.get_std_object(l_object_name, l_std_object);
    self := treat(l_std_object as dbug_obj_t);
    self.dirty := 0;
  exception
    when no_data_found
    then
      /* std_object fields */
      dirty := 1;

      active_str_tab := sys.odcivarchar2list();
      active_num_tab := sys.odcinumberlist();
      indent_level := 0;
      call_tab := dbug_call_tab_t();
      dbug_level := dbug.c_level_default; -- default level
      break_point_level_str_tab :=
        sys.odcivarchar2list
        ( dbug."debug"
        , dbug."error"
        , dbug."fatal"
        , dbug."info"
        , dbug."input"
        , dbug."output"
        , dbug."trace"
        , dbug."warning"
        );
      break_point_level_num_tab :=
        sys.odcinumberlist
        ( dbug.c_level_debug
        , dbug.c_level_error
        , dbug.c_level_fatal
        , dbug.c_level_info
        , dbug.c_level_debug
        , dbug.c_level_debug
        , dbug.c_level_debug
        , dbug.c_level_warning
        );
      ignore_buffer_overflow := 0; -- false
  end;

  -- essential
  return;
end;

overriding member function name(self in dbug_obj_t)
return varchar2
is
begin
  return 'DBUG';
end name;

member procedure print(self in dbug_obj_t)
is
begin
  dbms_output.put_line('dirty: '||dirty);
  if active_str_tab.count > 0
  then
    for i_idx in active_str_tab.first .. active_str_tab.last
    loop
      dbms_output.put_line('active('||active_str_tab(i_idx)||'): '||active_num_tab(i_idx));
    end loop;
  end if;
  dbms_output.put_line('indent_level: '||indent_level);
  dbms_output.put_line('call_tab.count: '||call_tab.count);
  dbms_output.put_line('dbug_level: '||dbug_level);
  if break_point_level_str_tab.count > 0
  then
    for i_idx in break_point_level_str_tab.first .. break_point_level_str_tab.last
    loop
      dbms_output.put_line('break_point_level('||break_point_level_str_tab(i_idx)||'): '||break_point_level_num_tab(i_idx));
    end loop;
  end if;
  dbms_output.put_line('ignore_buffer_overflow: '||ignore_buffer_overflow);
end print;

end;
/

