--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL$
REMARK

WHENEVER SQLERROR EXIT FAILURE

create or replace package dbug_dbms_output is

  procedure done;

  procedure enter(
    p_module in dbug.module_name_t
  );

  procedure leave;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2
  );

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2
  );

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2
  );

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2,
    p_arg4 in varchar2
  );

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2,
    p_arg4 in varchar2,
    p_arg5 in varchar2
  );

  /* Sourceforge transferware issue 2027441 Ignore dbms_output buffer overflow */

  /* setter */
  procedure ignore_buffer_overflow(p_value in boolean);

  /* getter */
  function ignore_buffer_overflow
  return boolean;

end dbug_dbms_output;
/

show errors

@dbug_verify dbug_dbms_output package

create or replace package body dbug_dbms_output is

  g_ignore_buffer_overflow boolean := false; /* backwards compatible */

  -- returns true when the exception is a buffer overflow AND when it must be ignored (clearing the buffer at the same time)
  function handle_buffer_overflow(p_sqlerrm in varchar2)
  return boolean
  is
    l_line varchar2(255);
    l_status integer;
  begin
    if g_ignore_buffer_overflow and instr(p_sqlerrm, 'ORU-10027:') > 0
    then
      /*
        From the Usage Notes for dbms_output.get_line:

        After calling GET_LINE or GET_LINES, any lines not retrieved
        before the next call to PUT, PUT_LINE, or NEW_LINE are discarded
        to avoid confusing them with the next message.


        Hence, getting just one line is enough to clear the buffer.
      */
      loop
        dbms_output.get_line(line => l_line, status => l_status);
        exit when l_status = 1; -- (empty)
      end loop;
      return true;
    else
      return false;
    end if;
  end handle_buffer_overflow;

  /* global modules */

  procedure done
  is
  begin
    null;
  end done;

  procedure enter(
    p_module in dbug.module_name_t
  ) is
  begin
    dbms_output.put_line( substr(dbug.format_enter(p_module), 1, 255) );
  exception
    when others
    then
      if not handle_buffer_overflow(sqlerrm)
      then
        raise;
      end if;
  end enter;

  procedure leave
  is
  begin
    dbms_output.put_line( substr(dbug.format_leave, 1, 255) );
  exception
    when others
    then
      if not handle_buffer_overflow(sqlerrm)
      then
        raise;
      end if;
  end leave;

  procedure print( p_str in varchar2 )
  is
    l_line_tab dbug.line_tab_t;
    l_line_no pls_integer;
  begin
    dbug.split(p_str, chr(10), l_line_tab);

    l_line_no := l_line_tab.first;
    while l_line_no is not null
    loop
      begin
        dbms_output.put_line( substr(l_line_tab(l_line_no), 1, 255) );
      exception
        when others
        then
          if not handle_buffer_overflow(sqlerrm)
          then
            raise;
          end if;
      end;
      l_line_no := l_line_tab.next(l_line_no);
    end loop;
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2
  ) is
  begin
    print( dbug.format_print(p_break_point, p_fmt, 1, p_arg1) );
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2
  ) is
  begin
    print( dbug.format_print(p_break_point, p_fmt, 2, p_arg1, p_arg2) );
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2
  ) is
  begin
    print( dbug.format_print(p_break_point, p_fmt, 3, p_arg1, p_arg2, p_arg3) );
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2,
    p_arg4 in varchar2
  ) is
  begin
    print( dbug.format_print(p_break_point, p_fmt, 4, p_arg1, p_arg2, p_arg3, p_arg4) );
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2,
    p_arg4 in varchar2,
    p_arg5 in varchar2
  ) is
  begin
    print( dbug.format_print(p_break_point, p_fmt, 5, p_arg1, p_arg2, p_arg3, p_arg4, p_arg5) );
  end print;

  procedure ignore_buffer_overflow(p_value in boolean)
  is
  begin
    g_ignore_buffer_overflow := p_value;
  end ignore_buffer_overflow;

  function ignore_buffer_overflow
  return boolean
  is
  begin
    return g_ignore_buffer_overflow;
  end ignore_buffer_overflow;

end dbug_dbms_output;
/

show errors

@dbug_verify dbug_dbms_output "package body"
