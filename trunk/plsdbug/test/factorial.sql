set serveroutput on size 1000000
set feedback off
set trimspool on

begin
	dbms_pipe.purge( epc.get_request_pipe );
exception
	when	others
	then
		null;
end;
/

declare
	function
	factorial (i_value in integer)
	return	integer
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
        dbug.activate( '&&method' );
	dbug.init( '&&options' );
	dbms_output.put_line( factorial( &&value ) );
	dbug.done;
end;
/
