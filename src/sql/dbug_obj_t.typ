create or replace type dbug_obj_t under std_object (
  active_str_tab sys.odcivarchar2list
, active_num_tab sys.odcinumberlist
, indent_level integer
, call_tab dbug_call_tab_t
, dbug_level integer
, break_point_level_str_tab sys.odcivarchar2list
, break_point_level_num_tab sys.odcinumberlist
, constructor function dbug_obj_t
  return self as result
) final
/

show errors
