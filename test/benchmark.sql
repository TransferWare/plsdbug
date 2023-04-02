set serveroutput on size 1000000
set feedback off
set trimspool on
set verify off

begin
  ut_dbug.ut_benchmark('&&1', '&&2', '&&3');
end;
/

