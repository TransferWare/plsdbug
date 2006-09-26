REMARK $Id: dbug.pls 1094 2006-04-21 17:46:05Z gpaulissen $ 

WHENEVER SQLERROR EXIT FAILURE

create or replace package dbug_plsdbug is

  procedure init(
    i_options in varchar2
  );

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

end dbug_plsdbug;
/

show errors

create or replace package body dbug_plsdbug is
  
  v_dbug_ctx pls_integer := 0; /* dbug context: session specific */

  /* global modules */

  procedure init(
    i_options in varchar2
  ) is
    v_status pls_integer := 0;
  begin
    /* register plsdbug and set the pipe name */
    epc_clnt.set_connection_info
    ( epc_clnt.register('plsdbug')
    , 'DBUG_' || user 
    );

    v_status := plsdbug.plsdbug_init( i_options, v_dbug_ctx );
    if ( v_status <> 0 )
    then
      raise_application_error(-20000, plsdbug.strerror(v_status) );
    end if;
  end init;

  procedure done
  is
    v_status pls_integer := 0;
  begin
    v_status := plsdbug.plsdbug_done( v_dbug_ctx );
    if ( v_status <> 0 )
    then
      raise_application_error(-20000, plsdbug.strerror(v_status) );
    end if;
  end done;

  procedure enter(
    i_module in dbug.module_name_t
  ) is
  begin
    plsdbug.plsdbug_enter( v_dbug_ctx, i_module );
  end enter;

  procedure leave
  is
  begin
    plsdbug.plsdbug_leave( v_dbug_ctx );
  end leave;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2
  ) is
  begin
    plsdbug.plsdbug_print1( v_dbug_ctx, 
                            i_break_point,
                            i_fmt,
                            i_arg1 );
  end print;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2
  ) is
  begin
    plsdbug.plsdbug_print2( v_dbug_ctx, 
                            i_break_point,
                            i_fmt,
                            i_arg1,
                            i_arg2 );
  end print;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2
  ) is
  begin
    plsdbug.plsdbug_print3( v_dbug_ctx, 
                            i_break_point,
                            i_fmt,
                            i_arg1,
                            i_arg2,
                            i_arg3 );
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
    plsdbug.plsdbug_print4( v_dbug_ctx, 
                            i_break_point,
                            i_fmt,
                            i_arg1,
                            i_arg2,
                            i_arg3,
                            i_arg4 );
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
    plsdbug.plsdbug_print5( v_dbug_ctx, 
                            i_break_point,
                            i_fmt,
                            i_arg1,
                            i_arg2,
                            i_arg3,
                            i_arg4,
                            i_arg5 );
  end print;

end dbug_plsdbug;
/

show errors
