set serveroutput on size 1000000
set feedback off
set trimspool on
set verify off

declare
  procedure doit
  is
  begin
    dbug.enter( 'doit' );
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
  for v_nr in 1..&&1
  loop
    doit;
  end loop;
  dbug.leave;
  dbug.done;
end;
/

