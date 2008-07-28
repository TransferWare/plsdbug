--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL$
REMARK

declare
  -- ORA-02303: cannot drop or replace a type with type or table dependents
  e_type_has_dependencies exception;
  pragma exception_init(e_type_has_dependencies, -2303);
begin
  execute immediate 'create or replace type dbug_obj_t under std_object (
  active_str_tab sys.odcivarchar2list
, active_num_tab sys.odcinumberlist
, indent_level integer
, call_tab dbug_call_tab_t
, dbug_level integer
, break_point_level_str_tab sys.odcivarchar2list
, break_point_level_num_tab sys.odcinumberlist
, ignore_buffer_overflow integer

, constructor function dbug_obj_t
  return self as result

, overriding member function name(self in dbug_obj_t)
  return varchar2

, member procedure print(self in dbug_obj_t)
) final
';
exception
  when e_type_has_dependencies
  then
    null;
end;
/

@dbug_verify dbug_obj_t type
