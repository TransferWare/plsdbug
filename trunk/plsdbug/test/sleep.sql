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
	procedure
	sleep (i_value in number)
	is
	begin
		dbug.enter( 'sleep' );
		dbug.print( 'parameters', 'sleeping %s seconds', i_value );
		dbms_lock.sleep( i_value );
		dbug.leave;
	end;
begin
	dbug.init( '&&options' );
	dbug.enter( 'main' );
	sleep( &&value );
	dbug.leave;
	dbug.done;
end;
/
