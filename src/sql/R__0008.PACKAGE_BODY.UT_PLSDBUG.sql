CREATE OR REPLACE PACKAGE BODY "UT_PLSDBUG" AS

$if ut_dbug.c_testing $then

/*
FUNCTION plsdbug_init(
    i_options IN epc.string_subtype,
    o_dbug_ctx OUT NOCOPY epc.long_subtype
  )
  RETURN epc.int_subtype;

  FUNCTION plsdbug_done(
    io_dbug_ctx IN OUT NOCOPY epc.long_subtype
  )
  RETURN epc.int_subtype;

  PROCEDURE plsdbug_enter(
    i_dbug_ctx IN epc.long_subtype,
    i_function IN epc.string_subtype
  );

  PROCEDURE plsdbug_leave(
    i_dbug_ctx IN epc.long_subtype
  );

  PROCEDURE plsdbug_print1(
    i_dbug_ctx IN epc.long_subtype,
    i_break_point IN epc.string_subtype,
    i_fmt IN epc.string_subtype,
    i_arg1 IN epc.string_subtype
  );

  PROCEDURE plsdbug_print2(
    i_dbug_ctx IN epc.long_subtype,
    i_break_point IN epc.string_subtype,
    i_fmt IN epc.string_subtype,
    i_arg1 IN epc.string_subtype,
    i_arg2 IN epc.string_subtype
  );

  PROCEDURE plsdbug_print3(
    i_dbug_ctx IN epc.long_subtype,
    i_break_point IN epc.string_subtype,
    i_fmt IN epc.string_subtype,
    i_arg1 IN epc.string_subtype,
    i_arg2 IN epc.string_subtype,
    i_arg3 IN epc.string_subtype
  );

  PROCEDURE plsdbug_print4(
    i_dbug_ctx IN epc.long_subtype,
    i_break_point IN epc.string_subtype,
    i_fmt IN epc.string_subtype,
    i_arg1 IN epc.string_subtype,
    i_arg2 IN epc.string_subtype,
    i_arg3 IN epc.string_subtype,
    i_arg4 IN epc.string_subtype
  );

  PROCEDURE plsdbug_print5(
    i_dbug_ctx IN epc.long_subtype,
    i_break_point IN epc.string_subtype,
    i_fmt IN epc.string_subtype,
    i_arg1 IN epc.string_subtype,
    i_arg2 IN epc.string_subtype,
    i_arg3 IN epc.string_subtype,
    i_arg4 IN epc.string_subtype,
    i_arg5 IN epc.string_subtype
  );

  FUNCTION strerror(
    i_error IN epc.int_subtype
  )
  RETURN epc.string_subtype;
*/

procedure init
is
  l_epc_clnt_object epc_clnt_object;
  l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  l_epc_key epc_srvr.epc_key_subtype;
begin
  /* set the pipe name */
  epc_clnt.set_connection_info
  ( 'plsdbug'
  , 'DBUG_' || user 
  );
  l_epc_clnt_object := new epc_clnt_object('plsdbug');

  l_dbug_plsdbug_obj.ctx := 1;
  l_dbug_plsdbug_obj.dirty := 1; -- ctx has changed
  l_dbug_plsdbug_obj.store();

  l_epc_key := epc_srvr.register;
  epc_srvr.set_connection_info( epc_srvr.get_epc_key, l_epc_clnt_object.request_pipe );
end init;

procedure done
is
  l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
begin
  l_dbug_plsdbug_obj.ctx := 0;
  l_dbug_plsdbug_obj.dirty := 1; -- ctx has changed
  l_dbug_plsdbug_obj.remove();
end done;

-- PUBLIC

procedure ut_setup
is
begin
  dbug.activate('LOG4PLSQL', true);
  init;
end ut_setup;

procedure ut_teardown
is
begin
  done;
  dbug.activate('LOG4PLSQL', false);
end ut_teardown;

procedure ut_plsdbug_init
is
begin
  null;
end ut_plsdbug_init;

procedure ut_plsdbug_done
is
begin
  null;
end ut_plsdbug_done;

procedure ut_plsdbug_enter
is
  l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  l_msg_info epc_srvr.msg_info_subtype;
  l_msg_request varchar2(32767 byte);
begin
  plsdbug.plsdbug_enter( l_dbug_plsdbug_obj.ctx, 'main' );
  epc_srvr.recv_request
  ( p_epc_key => epc_srvr.get_epc_key
  , p_msg_info => l_msg_info
  , p_msg_request => l_msg_request
  );
  ut.expect(l_msg_info, 'msg info').to_equal(to_char(epc_clnt."NATIVE")); -- oneway: just protocol
  ut.expect(l_msg_request, 'msg request').to_equal('10007plsdbug1000Dplsdbug_enter301110004main');
end ut_plsdbug_enter;

procedure ut_plsdbug_leave
is
  l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  l_msg_info epc_srvr.msg_info_subtype;
  l_msg_request varchar2(32767 byte);
begin
  plsdbug.plsdbug_leave( l_dbug_plsdbug_obj.ctx );
  epc_srvr.recv_request
  ( p_epc_key => epc_srvr.get_epc_key
  , p_msg_info => l_msg_info
  , p_msg_request => l_msg_request
  );
  ut.expect(l_msg_info, 'msg info').to_equal(to_char(epc_clnt."NATIVE"));
  ut.expect(l_msg_request, 'msg request').to_equal('10007plsdbug1000Dplsdbug_leave3011');
end ut_plsdbug_leave;

procedure ut_plsdbug_print1
is
  l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  l_msg_info epc_srvr.msg_info_subtype;
  l_msg_request varchar2(32767 byte);
begin
  plsdbug.plsdbug_print1( l_dbug_plsdbug_obj.ctx, 
                          'input',
                          'arg1: %s',
                          'arg1' );
  epc_srvr.recv_request
  ( p_epc_key => epc_srvr.get_epc_key
  , p_msg_info => l_msg_info
  , p_msg_request => l_msg_request
  );
  ut.expect(l_msg_info, 'msg info').to_equal(to_char(epc_clnt."NATIVE"));
  ut.expect(l_msg_request, 'msg request').to_equal('10007plsdbug1000Eplsdbug_print1301110005input10008arg1: %s10004arg1');
end ut_plsdbug_print1;

procedure ut_plsdbug_print2
is
  l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  l_msg_info epc_srvr.msg_info_subtype;
  l_msg_request varchar2(32767 byte);
begin
  plsdbug.plsdbug_print2( l_dbug_plsdbug_obj.ctx, 
                          'input',
                          'arg1: %s; arg2: %s',
                          'arg1',
                          'arg2' );
  epc_srvr.recv_request
  ( p_epc_key => epc_srvr.get_epc_key
  , p_msg_info => l_msg_info
  , p_msg_request => l_msg_request
  );
  ut.expect(l_msg_info, 'msg info').to_equal(to_char(epc_clnt."NATIVE"));
  ut.expect(l_msg_request, 'msg request').to_equal('10007plsdbug1000Eplsdbug_print2301110005input10012arg1: %s; arg2: %s10004arg110004arg2');
end ut_plsdbug_print2;

procedure ut_plsdbug_print3
is
  l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  l_msg_info epc_srvr.msg_info_subtype;
  l_msg_request varchar2(32767 byte);
begin
  plsdbug.plsdbug_print3( l_dbug_plsdbug_obj.ctx, 
                          'input',
                          'arg1: %s; arg2: %s; arg3: %s',
                          'arg1',
                          'arg2',
                          'arg3' );
  epc_srvr.recv_request
  ( p_epc_key => epc_srvr.get_epc_key
  , p_msg_info => l_msg_info
  , p_msg_request => l_msg_request
  );
  ut.expect(l_msg_info, 'msg info').to_equal(to_char(epc_clnt."NATIVE"));
  ut.expect(l_msg_request, 'msg request').to_equal('10007plsdbug1000Eplsdbug_print3301110005input1001Carg1: %s; arg2: %s; arg3: %s10004arg110004arg210004arg3');
end ut_plsdbug_print3;

procedure ut_plsdbug_print4
is
  l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  l_msg_info epc_srvr.msg_info_subtype;
  l_msg_request varchar2(32767 byte);
begin
  plsdbug.plsdbug_print4( l_dbug_plsdbug_obj.ctx, 
                          'input',
                          'arg1: %s; arg2: %s; arg3: %s; arg4: %s',
                          'arg1',
                          'arg2',
                          'arg3',
                          'arg4' );
  epc_srvr.recv_request
  ( p_epc_key => epc_srvr.get_epc_key
  , p_msg_info => l_msg_info
  , p_msg_request => l_msg_request
  );
  ut.expect(l_msg_info, 'msg info').to_equal(to_char(epc_clnt."NATIVE"));
  ut.expect(l_msg_request, 'msg request').to_equal('10007plsdbug1000Eplsdbug_print4301110005input10026arg1: %s; arg2: %s; arg3: %s; arg4: %s10004arg110004arg210004arg310004arg4');
end ut_plsdbug_print4;

procedure ut_plsdbug_print5
is
  l_dbug_plsdbug_obj dbug_plsdbug_obj_t := new dbug_plsdbug_obj_t();
  l_msg_info epc_srvr.msg_info_subtype;
  l_msg_request varchar2(32767 byte);
begin
  plsdbug.plsdbug_print5( l_dbug_plsdbug_obj.ctx, 
                          'input',
                          'arg1: %s; arg2: %s; arg3: %s; arg4: %s; arg5: %s',
                          'arg1',
                          'arg2',
                          'arg3',
                          'arg4',
                          'arg5' );
  epc_srvr.recv_request
  ( p_epc_key => epc_srvr.get_epc_key
  , p_msg_info => l_msg_info
  , p_msg_request => l_msg_request
  );
  ut.expect(l_msg_info, 'msg info').to_equal(to_char(epc_clnt."NATIVE"));
  ut.expect(l_msg_request, 'msg request').to_equal('10007plsdbug1000Eplsdbug_print5301110005input10030arg1: %s; arg2: %s; arg3: %s; arg4: %s; arg5: %s10004arg110004arg210004arg310004arg410004arg5');
end ut_plsdbug_print5;

procedure ut_strerror
is
begin
  null;
end ut_strerror;

$else

procedure ut_setup
is
begin
  raise program_error;
end;

procedure ut_teardown
is
begin
  raise program_error;
end;

procedure ut_plsdbug_init
is
begin
  raise program_error;
end;

procedure ut_plsdbug_done
is
begin
  raise program_error;
end;

procedure ut_plsdbug_enter
is
begin
  raise program_error;
end;

procedure ut_plsdbug_leave
is
begin
  raise program_error;
end;

procedure ut_plsdbug_print1
is
begin
  raise program_error;
end;

procedure ut_plsdbug_print2
is
begin
  raise program_error;
end;

procedure ut_plsdbug_print3
is
begin
  raise program_error;
end;

procedure ut_plsdbug_print4
is
begin
  raise program_error;
end;

procedure ut_plsdbug_print5
is
begin
  raise program_error;
end;

procedure ut_strerror
is
begin
  raise program_error;
end;

$end -- $if ut_dbug.c_testing $then

end ut_plsdbug;
/

