set serveroutput on size 1000000 format trunc
set feedback off
set trimspool on
set verify off
set linesize 1000 trimspool on

begin
  ut_dbug.ut_factorial('&&1', '&&2');
end;
/
