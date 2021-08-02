declare
  -- ORA-02303: cannot drop or replace a type with type or table dependents
  e_type_has_dependencies exception;
  pragma exception_init(e_type_has_dependencies, -2303);
begin
  execute immediate 'create or replace type dbug_plsdbug_obj_t under std_object (
  ctx integer

, constructor function dbug_plsdbug_obj_t
  return self as result

, overriding member function name(self in dbug_plsdbug_obj_t)
  return varchar2
) final
';
exception
  when e_type_has_dependencies
  then
    null;
end;
/

