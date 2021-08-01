declare
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
   )  DEFAULT COLLATION "USING_NLS_COMP"  
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" 
   CACHE]';
exception
  when others
  then
    raise;
end;
/
