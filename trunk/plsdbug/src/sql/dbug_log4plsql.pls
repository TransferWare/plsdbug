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

  /* global modules */

  procedure log_ctx2dbug_log4plsql_obj
  ( p_ctx in plog.log_ctx
  , p_obj in out nocopy dbug_log4plsql_obj_t
  )
  is
  begin
    p_obj.isdefaultinit := case when p_ctx.isdefaultinit then 1 else 0 end;
    p_obj.llevel := p_ctx.llevel;
    p_obj.lsection := p_ctx.lsection;
    p_obj.ltexte := p_ctx.ltexte;
    p_obj.use_log4j := case when p_ctx.use_log4j then 1 else 0 end;
    p_obj.use_out_trans := case when p_ctx.use_out_trans then 1 else 0 end;
    p_obj.use_logtable := case when p_ctx.use_logtable then 1 else 0 end;
    p_obj.use_alert := case when p_ctx.use_alert then 1 else 0 end;
    p_obj.use_trace := case when p_ctx.use_trace then 1 else 0 end;
    p_obj.use_dbms_output := case when p_ctx.use_dbms_output then 1 else 0 end;
    p_obj.init_lsection := p_ctx.init_lsection;
    p_obj.init_llevel := p_ctx.init_llevel;
    p_obj.dbms_pipe_name := p_ctx.dbms_pipe_name;
  end;

  procedure dbug_log4plsql_obj2log_ctx
  ( p_obj in dbug_log4plsql_obj_t
  , p_ctx in out nocopy plog.log_ctx
  )
  is
  begin
    p_ctx.isdefaultinit := p_obj.isdefaultinit = 1;
    p_ctx.llevel := p_obj.llevel;
    p_ctx.lsection := p_obj.lsection;
    p_ctx.ltexte := p_obj.ltexte;
    p_ctx.use_log4j := p_obj.use_log4j = 1;
    p_ctx.use_out_trans := p_obj.use_out_trans = 1;
    p_ctx.use_logtable := p_obj.use_logtable = 1;
    p_ctx.use_alert := p_obj.use_alert = 1;
    p_ctx.use_trace := p_obj.use_trace = 1;
    p_ctx.use_dbms_output := p_obj.use_dbms_output = 1;
    p_ctx.init_lsection := p_obj.init_lsection;
    p_ctx.init_llevel := p_obj.init_llevel;
    p_ctx.dbms_pipe_name := p_obj.dbms_pipe_name;
  end;

  procedure get_log_ctx
  ( p_ctx out nocopy plog.log_ctx
  )
  is
    l_object_name constant std_objects.object_name%type := 'DBUG_LOG4PLSQL';
    l_std_object std_object;
  begin
    begin
      std_object_mgr.get_std_object(l_object_name, l_std_object);

      dbug_log4plsql_obj2log_ctx
      ( p_obj => treat(l_std_object as dbug_log4plsql_obj_t)
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
    l_object_name constant std_objects.object_name%type := 'DBUG_LOG4PLSQL';
    l_obj dbug_log4plsql_obj_t;
  begin
    log_ctx2dbug_log4plsql_obj
    ( p_ctx => p_ctx
    , p_obj => l_obj
    );
    std_object_mgr.set_std_object(l_object_name, l_obj);
  end set_log_ctx;

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
