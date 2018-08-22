--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL$
REMARK

whenever sqlerror exit failure

variable object_name varchar2(128)
variable object_type varchar2(19)

set define on feedback off verify off linesize 132 trimspool on termout on

execute :object_name := upper('&&1'); :object_type := upper('&&2')

set serveroutput on

declare
  l_found pls_integer;
begin
  select  1
  into    l_found
  from    user_objects
  where   object_name = :object_name
  and     object_type = :object_type
  and     status = 'VALID';
exception
  when no_data_found
  then
    dbms_output.put_line('ERROR: Could not find a valid object with name "'
                         ||:object_name
                         ||'" and type "'
                         ||:object_type
                         ||'".');
    raise;
end;
/

undefine 1 2
set define off feedback on verify on
