set serveroutput on size 1000000 format trunc
set feedback off
set trimspool on
set verify off
set linesize 1000 trimspool on

declare
	l_plsdbug_options constant varchar2(100) := '&&1';

        function
        factorial (i_value in integer)
        return  integer
        is
                v_value integer := i_value;
        begin
                dbug.enter( 'factorial' );
                dbug.print( 'find', 'find %s factorial', v_value );
                if (v_value > 1) 
                then
                        v_value := v_value * factorial( v_value-1 );
                end if;
                dbug.print( 'result', 'result is %s', v_value );
                dbug.leave;
                RETURN (v_value);
        end;
begin
	if l_plsdbug_options is not null
        then
		dbug.activate( 'PLSDBUG' );
        	dbug_plsdbug.init( l_plsdbug_options );
	else
		dbug.activate( 'DBMS_OUTPUT' );
	end if;
        dbms_output.put_line( factorial( &&2 ) );
        dbug.done;
end;
/
