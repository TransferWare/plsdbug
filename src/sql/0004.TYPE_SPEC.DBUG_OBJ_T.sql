CREATE TYPE "DBUG_OBJ_T" AUTHID DEFINER under std_object (
  active_str_tab sys.odcivarchar2list
, active_num_tab sys.odcinumberlist
, indent_level integer
, call_tab dbug_call_tab_t
, dbug_level integer
, break_point_level_str_tab sys.odcivarchar2list
, break_point_level_num_tab sys.odcinumberlist
, ignore_buffer_overflow integer

, constructor function dbug_obj_t(self in out nocopy dbug_obj_t)
  return self as result

, overriding member function name(self in dbug_obj_t)
  return varchar2

, overriding member procedure print(self in dbug_obj_t)

) final;
/

