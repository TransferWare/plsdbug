REMARK [2027441]: Ignore dbms_output buffer overflow.

set serveroutput on size 5000
set linesize 200 trimspool on feedback off

variable l_nr number

begin
  dbug.activate('dbms_output');
end;
/

begin
  dbug.enter('buffer_overflow.sql (1)');
  :l_nr := 1;
  dbug.set_ignore_buffer_overflow(true);
  dbug.print('info', 'dbug.get_ignore_buffer_overflow: %s', dbug.get_ignore_buffer_overflow);
  dbug.leave;
end;
/

begin
  dbug.enter('buffer_overflow.sql (2)');
  for i_idx in 1..1000
  loop
    dbug.print('info', '%s:%s:%s', :l_nr, rpad('x', 80, 'x'), i_idx);
  end loop;
  dbug.leave;
end;
/

begin
  dbug.enter('buffer_overflow.sql (3)');
  :l_nr := 2;
  dbug.set_ignore_buffer_overflow(false);
  dbug.print('info', 'dbug.get_ignore_buffer_overflow: %s', dbug.get_ignore_buffer_overflow);
  dbug.leave;
end;
/

begin
  dbug.enter('buffer_overflow.sql (4)');
  for i_idx in 1..1000
  loop
    dbug.print('info', '%s:%s:%s', :l_nr, rpad('x', 80, 'x'), i_idx);
  end loop;
  dbug.leave;
end;
/
