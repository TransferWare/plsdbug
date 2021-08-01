CREATE OR REPLACE PACKAGE BODY "DBUG_DBMS_OUTPUT" IS

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
  end enter;

  procedure leave
  is
  begin
    dbms_output.put_line( substr(dbug.format_leave, 1, 255) );
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

end dbug_dbms_output;
/

