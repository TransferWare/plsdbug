--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL$
REMARK

declare
  -- ORA-02303: cannot drop or replace a type with type or table dependents
  e_type_has_dependencies exception;
  pragma exception_init(e_type_has_dependencies, -2303);
begin
  execute immediate 'create or replace type dbug_call_obj_t is object (
  module_name varchar2(4000)
, called_from varchar2(4000) -- the location from which this module is called (initially null)
, other_calls varchar2(4000) -- only set for the first index
)';
exception
  when e_type_has_dependencies
  then
    null;
end;
/

@dbug_verify dbug_call_obj_t type
