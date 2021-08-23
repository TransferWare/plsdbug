declare
  -- ORA-00955: name is already used by an existing object
  e_object_already_exists exception;
  pragma exception_init(e_object_already_exists, -955);
begin
  -- table may have been dropped in uninstall.sql
  execute immediate q'[
CREATE TABLE "STD_OBJECTS" 
   (  "GROUP_NAME" VARCHAR2(100), 
  "OBJECT_NAME" VARCHAR2(100), 
  "CREATED_BY" VARCHAR2(30), 
  "CREATION_DATE" DATE, 
  "LAST_UPDATED_BY" VARCHAR2(30), 
  "LAST_UPDATE_DATE" DATE, 
  "OBJ" "STD_OBJECT" 
   )]';
exception
  when e_object_already_exists
  then
    null;
end;
/
