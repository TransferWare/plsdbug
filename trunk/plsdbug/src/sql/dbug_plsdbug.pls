--$NO_KEYWORD_EXPANSION$
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

@verify dbug_plsdbug package

create or replace package body dbug_plsdbug is
  
  /* global modules */

  procedure init(
    i_options in varchar2
  )
  is
    l_status pls_integer := 0;
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  begin
    /* set the pipe name */
    epc_clnt.set_connection_info
    ( 'plsdbug'
    , 'DBUG_' || user 
    );

    l_status := plsdbug.plsdbug_init( i_options, l_dbug_plsdbug_obj.ctx );
    if ( l_status <> 0 )
    then
      raise_application_error(-20000, plsdbug.strerror(l_status) );
    end if;

    l_dbug_plsdbug_obj.store();
  end init;

  procedure done
  is
    l_status pls_integer := 0;
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  begin
    l_status := plsdbug.plsdbug_done( l_dbug_plsdbug_obj.ctx );
    if ( l_status <> 0 )
    then
      raise_application_error(-20000, plsdbug.strerror(l_status) );
    end if;
    l_dbug_plsdbug_obj.store();
  end done;

  procedure enter(
    i_module in dbug.module_name_t
  )
  is
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  begin
    plsdbug.plsdbug_enter( l_dbug_plsdbug_obj.ctx, i_module );
  end enter;

  procedure leave
  is
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  begin
    plsdbug.plsdbug_leave( l_dbug_plsdbug_obj.ctx );
  end leave;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2
  )
  is
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  begin
    plsdbug.plsdbug_print1( l_dbug_plsdbug_obj.ctx, 
                            i_break_point,
                            i_fmt,
                            i_arg1 );
  end print;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2
  )
  is
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  begin
    plsdbug.plsdbug_print2( l_dbug_plsdbug_obj.ctx, 
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
  )
  is
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  begin
    plsdbug.plsdbug_print3( l_dbug_plsdbug_obj.ctx, 
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
  )
  is
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  begin
    plsdbug.plsdbug_print4( l_dbug_plsdbug_obj.ctx, 
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
  )
  is
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  begin
    plsdbug.plsdbug_print5( l_dbug_plsdbug_obj.ctx, 
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

@verify dbug_plsdbug "package body"
