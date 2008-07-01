set serveroutput on size 1000000 format trunc
set feedback off
set trimspool on
set verify off
set linesize 1000 trimspool on

declare
	l_dbug_method constant varchar2(100) := '&&2';
	l_plsdbug_options constant varchar2(100) := '&&3';

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
	case upper(l_dbug_method)
          when 'PLSDBUG'
          then
		dbug.activate( l_dbug_method );
        	dbug_plsdbug.init( l_plsdbug_options );
	  else
		dbug.activate( l_dbug_method );
	end case;
        dbms_output.put_line( factorial( &&1 ) );
        dbug.done;
end;
/
