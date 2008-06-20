--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $Header$
REMARK

declare
  -- ORA-02303: cannot drop or replace a type with type or table dependents
  e_type_has_dependencies exception;
  pragma exception_init(e_type_has_dependencies, -2303);
begin
  execute immediate 'create or replace type dbug_call_tab_t is table of dbug_call_obj_t
';
exception
  when e_type_has_dependencies
  then
    null;
end;
/

show errors

@verify dbug_call_tab_t type
