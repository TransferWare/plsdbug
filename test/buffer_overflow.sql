REMARK [2027441]: Ignore dbms_output buffer overflow.

set serveroutput on
set linesize 200 trimspool on feedback off

begin
  dbug.activate('dbms_output');
  dbug.enter('dbms_output.sql');
  for i_nr in 1..2
  loop
    dbug_dbms_output.ignore_buffer_overflow(i_nr = 1);

    for i_idx in 1..20
    loop
      dbug.print('info', '%s:%s:%s', i_nr, rpad('x', 132, 'x'), i_idx);
    end loop;
  end loop;
end;
/
