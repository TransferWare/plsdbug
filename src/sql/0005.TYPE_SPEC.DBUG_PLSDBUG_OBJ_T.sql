CREATE TYPE "DBUG_PLSDBUG_OBJ_T" AUTHID DEFINER under std_object (
  ctx integer

, constructor function dbug_plsdbug_obj_t(self in out nocopy dbug_plsdbug_obj_t)
  return self as result

, overriding member function name(self in dbug_plsdbug_obj_t)
  return varchar2
) final;
/

