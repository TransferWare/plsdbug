--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $Header$
REMARK

create or replace type dbug_call_tab_t is table of dbug_call_obj_t
/

show errors

@verify dbug_call_tab_t type
