set serveroutput on size 1000000
set feedback off
set trimspool on
set verify off

declare
  procedure
  sleep (i_value in number)
  is
  begin
    dbug.enter( 'sleep' );
    dbug.print( 'parameters', 'sleeping %s seconds', i_value );
$if dbms_db_version.version >= 18 $then                
    dbms_session.sleep( i_value );
$else                
    dbms_lock.sleep( i_value );
$end                
    dbug.leave;
  end;
begin
  dbug.activate( '&&2' );
  case upper('&&2')
    when 'PLSDBUG'
    then
      dbug_plsdbug.init( '&&3' );
    else
      null;
  end case;
  dbug.enter( 'main' );
  sleep( &&1 );
  dbug.leave;
  dbug.done;
end;
/
