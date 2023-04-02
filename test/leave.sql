REM This script is there to verify that missing dbug.leave calls are adjusted for
REM later on.

define userid = '&&1'
define dbug_method = '&&2'
define dbug_options = '&&3'

define termout_off = off

set termout &&termout_off
connect &&userid

set feedback off

whenever sqlerror exit failure

set termout &&termout_off

begin
  ut_dbug.ut_leave('&&dbug_method', '&&dbug_options');
end;
/

