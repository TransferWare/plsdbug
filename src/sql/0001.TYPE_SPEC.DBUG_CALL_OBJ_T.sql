CREATE TYPE "DBUG_CALL_OBJ_T" AUTHID DEFINER IS OBJECT (
  module_name varchar2(4000)
, called_from varchar2(4000) -- the location from which this module is called (initially null)
, other_calls varchar2(4000) -- only set for the first index
);
/

