REM This script is there to verify that missing dbug.leave calls are adjusted for
REM later on.

define userid = '&&1'
define dbug_method = '&&2'
define dbug_options = '&&3'

define termout_off = on

set termout &&termout_off
connect &&userid

set feedback off
set linesize 1000 trimspool on
set serveroutput on size unlimited format trunc
whenever sqlerror exit failure

set termout &&termout_off

begin
  dbug.activate('dbms_output');
  ut_dbug.ut_leave('&&dbug_method', '&&dbug_options');
end;
/

