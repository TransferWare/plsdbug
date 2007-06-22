set serveroutput on size 1000000
set feedback off
set trimspool on
set verify off
set timing on

declare
        procedure doit
        is
        begin
                dbug.enter( 'doit' );
                dbug.leave;
        end;
begin
        dbug.activate( 'DBMS_OUTPUT', false );
        dbug.activate( 'PLSDBUG' );
        dbug_plsdbug.init( '&&1' );
        dbug.enter( 'main' );
        for v_nr in 1..&&2
        loop
                doit;
        end loop;
        dbug.leave;
        dbug.done;
end;
/

