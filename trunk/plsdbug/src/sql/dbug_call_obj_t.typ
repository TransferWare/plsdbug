create or replace type dbug_call_obj_t is object (
  module_name varchar2(4000)
, called_from varchar2(4000) -- the location from which this module is called (initially null)
, other_calls varchar2(4000) -- only set for the first index
)
/

show errors
