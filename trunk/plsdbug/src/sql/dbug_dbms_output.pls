REMARK $Id: dbug.pls 1094 2006-04-21 17:46:05Z gpaulissen $ 

WHENEVER SQLERROR EXIT FAILURE

create or replace package dbug_dbms_output is

  procedure done;

  procedure enter(
    i_module in dbug.module_name_t
  );

  procedure leave;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2
  );

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2
  );

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2
  );

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2,
    i_arg4 in varchar2
  );

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2,
    i_arg4 in varchar2,
    i_arg5 in varchar2
  );

end dbug_dbms_output;
/

show errors

create or replace package body dbug_dbms_output is
  
  /* global modules */

  procedure done
  is
  begin
    null;
  end done;

  procedure enter(
    i_module in dbug.module_name_t
  ) is
  begin
    dbms_output.put_line( substr(dbug.format_enter(i_module), 1, 255) );
  end enter;

  procedure leave
  is
  begin
    dbms_output.put_line( substr(dbug.format_leave, 1, 255) );
  end leave;

  procedure print( i_str in varchar2 )
  is
    v_line_tab dbug.line_tab_t;
    v_line_no pls_integer;
  begin
    dbug.split(i_str, chr(10), v_line_tab);

    v_line_no := v_line_tab.first;
    while v_line_no is not null
    loop
      dbms_output.put_line( substr(v_line_tab(v_line_no), 1, 255) );
      v_line_no := v_line_tab.next(v_line_no);
    end loop;
  end print;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2
  ) is
  begin
    print( dbug.format_print(i_break_point, i_fmt, 1, i_arg1) );
  end print;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2
  ) is
  begin
    print( dbug.format_print(i_break_point, i_fmt, 2, i_arg1, i_arg2) );
  end print;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2
  ) is
  begin
    print( dbug.format_print(i_break_point, i_fmt, 3, i_arg1, i_arg2, i_arg3) );
  end print;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2,
    i_arg4 in varchar2
  ) is
  begin
    print( dbug.format_print(i_break_point, i_fmt, 4, i_arg1, i_arg2, i_arg3, i_arg4) );
  end print;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2,
    i_arg4 in varchar2,
    i_arg5 in varchar2
  ) is
  begin
    print( dbug.format_print(i_break_point, i_fmt, 5, i_arg1, i_arg2, i_arg3, i_arg4, i_arg5) );
  end print;

end dbug_dbms_output;
/

show errors
