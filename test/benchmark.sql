set serveroutput on size unlimited format trunc
set feedback off
set trimspool on
set verify on

begin
  ut_dbug.ut_benchmark('&&1', '&&2', '&&3');
end;
/

