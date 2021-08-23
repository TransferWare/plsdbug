declare
  -- ORA-02264: name already used by an existing constraint
  e_constraint_already_exists exception;
  pragma exception_init(e_constraint_already_exists, -2264);
begin
  -- table may have been dropped in uninstall.sql
  execute immediate q'[
ALTER TABLE "STD_OBJECTS" ADD CONSTRAINT "STD_OBJECTS_CHK1" CHECK (created_by is not null) ENABLE]';

  execute immediate q'[
ALTER TABLE "STD_OBJECTS" ADD CONSTRAINT "STD_OBJECTS_CHK2" CHECK (creation_date is not null) ENABLE]';

  execute immediate q'[
ALTER TABLE "STD_OBJECTS" ADD CONSTRAINT "STD_OBJECTS_CHK3" CHECK (last_updated_by is not null) ENABLE]';

  execute immediate q'[
ALTER TABLE "STD_OBJECTS" ADD CONSTRAINT "STD_OBJECTS_CHK4" CHECK (last_update_date is not null) ENABLE]';

  execute immediate q'[
ALTER TABLE "STD_OBJECTS" ADD CONSTRAINT "STD_OBJECTS_PK" PRIMARY KEY ("GROUP_NAME", "OBJECT_NAME") ENABLE]';
exception
  when e_constraint_already_exists
  then
    null;
end;
/
