create or replace type dbug_obj_t under std_object (
  indent_level integer
, call_tab dbug_call_tab_t
, dbug_level integer
, constructor function dbug_obj_t
  return self as result
) final
/

show errors
