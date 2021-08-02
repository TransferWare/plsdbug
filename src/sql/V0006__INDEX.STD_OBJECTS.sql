declare
  -- ORA-00955: name is already used by an existing object
  e_object_already_exists exception;
  pragma exception_init(e_object_already_exists, -955);
begin
  -- table may have been dropped in uninstall.sql
  execute immediate q'[
CREATE UNIQUE INDEX "STD_OBJECTS_PK" ON "STD_OBJECTS" ("GROUP_NAME", "OBJECT_NAME")]';
exception
  when e_object_already_exists
  then
    null;
end;
/


