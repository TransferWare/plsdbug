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
  
  procedure get_dbug_plsdbug_obj
  ( p_dbug_plsdbug_obj out nocopy dbug_plsdbug_obj_t
  )
  is
    l_object_name constant std_objects.object_name%type := 'DBUG_PLSDBUG';
    l_std_object std_object;
  begin
    begin
      std_object_mgr.get_std_object(l_object_name, l_std_object);
      p_dbug_plsdbug_obj := treat(l_std_object as dbug_plsdbug_obj_t);
      p_dbug_plsdbug_obj.dirty := 0;
    exception
      when no_data_found
      then
        p_dbug_plsdbug_obj := new dbug_plsdbug_obj_t(1, null);
    end;
  end get_dbug_plsdbug_obj;

  procedure set_dbug_plsdbug_obj
  ( p_dbug_plsdbug_obj in dbug_plsdbug_obj_t
  )
  is
    l_object_name constant std_objects.object_name%type := 'DBUG_PLSDBUG';
  begin
    std_object_mgr.set_std_object(l_object_name, p_dbug_plsdbug_obj);
  end set_dbug_plsdbug_obj;

  /* global modules */

  procedure init(
    i_options in varchar2
  )
  is
    l_status pls_integer := 0;
    l_epc_clnt_object epc_clnt_object;
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t;
  begin
    epc_clnt.get_epc_clnt_object
    ( p_epc_clnt_object => l_epc_clnt_object
    , p_interface_name => 'plsdbug'
    );

    /* register plsdbug and set the pipe name */
    epc_clnt.set_connection_info
    ( l_epc_clnt_object
    , 'DBUG_' || user 
    );

    /* save the details */
    epc_clnt.set_epc_clnt_object
    ( p_epc_clnt_object => l_epc_clnt_object
    , p_interface_name => 'plsdbug'
    );

    get_dbug_plsdbug_obj
    ( p_dbug_plsdbug_obj => l_dbug_plsdbug_obj
    );

    l_status := plsdbug.plsdbug_init( i_options, l_dbug_plsdbug_obj.ctx );
    if ( l_status <> 0 )
    then
      raise_application_error(-20000, plsdbug.strerror(l_status) );
    end if;

    set_dbug_plsdbug_obj
    ( p_dbug_plsdbug_obj => l_dbug_plsdbug_obj
    );
  end init;

  procedure done
  is
    l_status pls_integer := 0;
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t;
  begin
    get_dbug_plsdbug_obj
    ( p_dbug_plsdbug_obj => l_dbug_plsdbug_obj
    );

    l_status := plsdbug.plsdbug_done( l_dbug_plsdbug_obj.ctx );
    if ( l_status <> 0 )
    then
      raise_application_error(-20000, plsdbug.strerror(l_status) );
    end if;

    set_dbug_plsdbug_obj
    ( p_dbug_plsdbug_obj => l_dbug_plsdbug_obj
    );
  end done;

  procedure enter(
    i_module in dbug.module_name_t
  )
  is
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t;
  begin
    get_dbug_plsdbug_obj
    ( p_dbug_plsdbug_obj => l_dbug_plsdbug_obj
    );
    plsdbug.plsdbug_enter( l_dbug_plsdbug_obj.ctx, i_module );
  end enter;

  procedure leave
  is
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t;
  begin
    get_dbug_plsdbug_obj
    ( p_dbug_plsdbug_obj => l_dbug_plsdbug_obj
    );
    plsdbug.plsdbug_leave( l_dbug_plsdbug_obj.ctx );
  end leave;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2
  )
  is
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t;
  begin
    get_dbug_plsdbug_obj
    ( p_dbug_plsdbug_obj => l_dbug_plsdbug_obj
    );
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
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t;
  begin
    get_dbug_plsdbug_obj
    ( p_dbug_plsdbug_obj => l_dbug_plsdbug_obj
    );
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
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t;
  begin
    get_dbug_plsdbug_obj
    ( p_dbug_plsdbug_obj => l_dbug_plsdbug_obj
    );
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
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t;
  begin
    get_dbug_plsdbug_obj
    ( p_dbug_plsdbug_obj => l_dbug_plsdbug_obj
    );
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
    l_dbug_plsdbug_obj dbug_plsdbug_obj_t;
  begin
    get_dbug_plsdbug_obj
    ( p_dbug_plsdbug_obj => l_dbug_plsdbug_obj
    );
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
