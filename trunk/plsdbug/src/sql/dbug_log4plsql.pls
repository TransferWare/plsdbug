-- $NO_KEYWORD_EXPANSION$
REMARK $Id: dbug.pls 1094 2006-04-21 17:46:05Z gpaulissen $ 

WHENEVER SQLERROR EXIT FAILURE

create or replace package dbug_log4plsql is

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

end dbug_log4plsql;
/

show errors

create or replace package body dbug_log4plsql is
  
  l_ctx plog.log_ctx;

  /* global modules */

  procedure done
  is
  begin
    null;
  end done;

  procedure enter(
    i_module in dbug.module_name_t
  )
  is
  begin
    plog.debug
    ( l_ctx
    , dbug.format_enter(i_module)
    );
  end enter;

  procedure leave
  is
  begin
    plog.debug
    ( l_ctx
    , dbug.format_leave
    );
  end leave;

  procedure print( i_str in varchar2 )
  is
    v_pos pls_integer;
    v_prev_pos pls_integer;
    v_str varchar2(32767) := i_str;
  begin
    v_prev_pos := 1;
    loop
      exit when v_prev_pos > nvl(length(v_str), 0);

      v_pos := instr(v_str, chr(10), v_prev_pos);

      if v_pos = 0
      then
        plog.debug
        ( l_ctx
        , substr(v_str, v_prev_pos)
        );
        exit;
      else
        plog.debug
        ( l_ctx
        , substr(v_str, v_prev_pos, v_pos - v_prev_pos)
        );
      end if;

      v_prev_pos := v_pos + 1;
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

begin
  l_ctx := plog.init(plevel       => plog.ldebug,
                     plogtable    => true,
                     pout_trans   => true);
end dbug_log4plsql;
/

show errors
