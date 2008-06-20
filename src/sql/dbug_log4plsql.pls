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

@verify dbug_log4plsql package

create or replace package body dbug_log4plsql is

  /* global modules */

  procedure log_ctx2dbug_log4plsql_obj
  ( p_ctx in plog.log_ctx
  , p_obj in out nocopy dbug_log4plsql_obj_t
  )
  is
    function bool2int(p_bool in boolean)
    return integer
    is
    begin
      return case p_bool when true then 1 when false then 0 else null end;
    end bool2int;
  begin
    p_obj.isdefaultinit := bool2int(p_ctx.isdefaultinit);
    p_obj.llevel := p_ctx.llevel;
    p_obj.lsection := p_ctx.lsection;
    p_obj.ltexte := p_ctx.ltexte;
    p_obj.use_log4j := bool2int(p_ctx.use_log4j);
    p_obj.use_out_trans := bool2int(p_ctx.use_out_trans);
    p_obj.use_logtable := bool2int(p_ctx.use_logtable);
    p_obj.use_alert := bool2int(p_ctx.use_alert);
    p_obj.use_trace := bool2int(p_ctx.use_trace);
    p_obj.use_dbms_output := bool2int(p_ctx.use_dbms_output);
    p_obj.init_lsection := p_ctx.init_lsection;
    p_obj.init_llevel := p_ctx.init_llevel;
    p_obj.dbms_pipe_name := p_ctx.dbms_pipe_name;
  end;

  procedure dbug_log4plsql_obj2log_ctx
  ( p_obj in dbug_log4plsql_obj_t
  , p_ctx in out nocopy plog.log_ctx
  )
  is
    function int2bool(p_int in integer)
    return boolean
    is
    begin
      return case p_int when 1 then true when 0 then false else null end;
    end int2bool;
  begin
    p_ctx.isdefaultinit := int2bool(p_obj.isdefaultinit);
    p_ctx.llevel := p_obj.llevel;
    p_ctx.lsection := p_obj.lsection;
    p_ctx.ltexte := p_obj.ltexte;
    p_ctx.use_log4j := int2bool(p_obj.use_log4j);
    p_ctx.use_out_trans := int2bool(p_obj.use_out_trans);
    p_ctx.use_logtable := int2bool(p_obj.use_logtable);
    p_ctx.use_alert := int2bool(p_obj.use_alert);
    p_ctx.use_trace := int2bool(p_obj.use_trace);
    p_ctx.use_dbms_output := int2bool(p_obj.use_dbms_output);
    p_ctx.init_lsection := p_obj.init_lsection;
    p_ctx.init_llevel := p_obj.init_llevel;
    p_ctx.dbms_pipe_name := p_obj.dbms_pipe_name;
  end;

  procedure get_log_ctx
  ( p_ctx out nocopy plog.log_ctx
  )
  is
    l_obj dbug_log4plsql_obj_t;
  begin
    begin
      l_obj := new dbug_log4plsql_obj_t();

      dbug_log4plsql_obj2log_ctx
      ( p_obj => l_obj
      , p_ctx => p_ctx
      );
    exception
      when no_data_found
      then
        p_ctx := 
          plog.init
          ( plevel => plog.ldebug
          , plogtable => true
          , pout_trans => true
          );
    end;
  end get_log_ctx;

  procedure set_log_ctx
  ( p_ctx in plog.log_ctx
  )
  is
    l_obj dbug_log4plsql_obj_t;
  begin
    log_ctx2dbug_log4plsql_obj
    ( p_ctx => p_ctx
    , p_obj => l_obj
    );
    l_obj.store();
  end set_log_ctx;

  /* global modules */

  procedure done
  is
    l_obj dbug_log4plsql_obj_t;
  begin
    l_obj := new dbug_log4plsql_obj_t(); -- may raise no_data_found
    l_obj.remove();    
  exception
    when no_data_found
    then
      null;
  end done;

  procedure enter(
    i_module in dbug.module_name_t
  )
  is
    l_ctx plog.log_ctx;
  begin
    get_log_ctx(l_ctx);
    plog.debug
    ( l_ctx
    , dbug.format_enter(i_module)
    );
    set_log_ctx(l_ctx);
  end enter;

  procedure leave
  is
    l_ctx plog.log_ctx;
  begin
    get_log_ctx(l_ctx);
    plog.debug
    ( l_ctx
    , dbug.format_leave
    );
    set_log_ctx(l_ctx);
  end leave;

  procedure print( i_str in varchar2 )
  is
    v_pos pls_integer;
    v_prev_pos pls_integer;
    v_str varchar2(32767) := i_str;
    l_ctx plog.log_ctx;
  begin
    get_log_ctx(l_ctx);
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
    set_log_ctx(l_ctx);
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

end dbug_log4plsql;
/

show errors

@verify dbug_log4plsql "package body"
