CREATE OR REPLACE PACKAGE BODY "PLSDBUG" IS

  FUNCTION plsdbug_init(
    i_options IN epc.string_subtype,
    o_dbug_ctx OUT NOCOPY epc.long_subtype
  )
  RETURN epc.int_subtype
  IS
    l_result epc.int_subtype;
    l_epc_clnt_object epc_clnt_object := new epc_clnt_object('plsdbug');
  BEGIN
    BEGIN
      epc_clnt.new_request(l_epc_clnt_object, 'plsdbug_init', 0);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_options', epc.data_type_string, i_options, 4096);
      epc_clnt.send_request(l_epc_clnt_object);
      epc_clnt.recv_response(l_epc_clnt_object);
      epc_clnt.get_response_parameter(l_epc_clnt_object, 'o_dbug_ctx', epc.data_type_long, o_dbug_ctx);
      epc_clnt.get_response_parameter(l_epc_clnt_object, 'result', epc.data_type_int, l_result);
    EXCEPTION
      WHEN OTHERS
      THEN
        l_epc_clnt_object.store();
        RAISE;
    END;
    l_epc_clnt_object.store();
    RETURN l_result;
  END;

  FUNCTION plsdbug_done(
    io_dbug_ctx IN OUT NOCOPY epc.long_subtype
  )
  RETURN epc.int_subtype
  IS
    l_result epc.int_subtype;
    l_epc_clnt_object epc_clnt_object := new epc_clnt_object('plsdbug');
  BEGIN
    BEGIN
      epc_clnt.new_request(l_epc_clnt_object, 'plsdbug_done', 0);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'io_dbug_ctx', epc.data_type_long, io_dbug_ctx);
      epc_clnt.send_request(l_epc_clnt_object);
      epc_clnt.recv_response(l_epc_clnt_object);
      epc_clnt.get_response_parameter(l_epc_clnt_object, 'io_dbug_ctx', epc.data_type_long, io_dbug_ctx);
      epc_clnt.get_response_parameter(l_epc_clnt_object, 'result', epc.data_type_int, l_result);
    EXCEPTION
      WHEN OTHERS
      THEN
        l_epc_clnt_object.store();
        RAISE;
    END;
    l_epc_clnt_object.store();
    RETURN l_result;
  END;

  PROCEDURE plsdbug_enter(
    i_dbug_ctx IN epc.long_subtype,
    i_function IN epc.string_subtype
  )
  IS
    l_epc_clnt_object epc_clnt_object := new epc_clnt_object('plsdbug');
  BEGIN
    BEGIN
      epc_clnt.new_request(l_epc_clnt_object, 'plsdbug_enter', 1);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_dbug_ctx', epc.data_type_long, i_dbug_ctx);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_function', epc.data_type_string, i_function, 4096);
      epc_clnt.send_request(l_epc_clnt_object);
    EXCEPTION
      WHEN OTHERS
      THEN
        l_epc_clnt_object.store();
        RAISE;
    END;
    l_epc_clnt_object.store();
  END;

  PROCEDURE plsdbug_leave(
    i_dbug_ctx IN epc.long_subtype
  )
  IS
    l_epc_clnt_object epc_clnt_object := new epc_clnt_object('plsdbug');
  BEGIN
    BEGIN
      epc_clnt.new_request(l_epc_clnt_object, 'plsdbug_leave', 1);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_dbug_ctx', epc.data_type_long, i_dbug_ctx);
      epc_clnt.send_request(l_epc_clnt_object);
    EXCEPTION
      WHEN OTHERS
      THEN
        l_epc_clnt_object.store();
        RAISE;
    END;
    l_epc_clnt_object.store();
  END;

  PROCEDURE plsdbug_print1(
    i_dbug_ctx IN epc.long_subtype,
    i_break_point IN epc.string_subtype,
    i_fmt IN epc.string_subtype,
    i_arg1 IN epc.string_subtype
  )
  IS
    l_epc_clnt_object epc_clnt_object := new epc_clnt_object('plsdbug');
  BEGIN
    BEGIN
      epc_clnt.new_request(l_epc_clnt_object, 'plsdbug_print1', 1);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_dbug_ctx', epc.data_type_long, i_dbug_ctx);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_break_point', epc.data_type_string, i_break_point, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_fmt', epc.data_type_string, i_fmt, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg1', epc.data_type_string, i_arg1, 4096);
      epc_clnt.send_request(l_epc_clnt_object);
    EXCEPTION
      WHEN OTHERS
      THEN
        l_epc_clnt_object.store();
        RAISE;
    END;
    l_epc_clnt_object.store();
  END;

  PROCEDURE plsdbug_print2(
    i_dbug_ctx IN epc.long_subtype,
    i_break_point IN epc.string_subtype,
    i_fmt IN epc.string_subtype,
    i_arg1 IN epc.string_subtype,
    i_arg2 IN epc.string_subtype
  )
  IS
    l_epc_clnt_object epc_clnt_object := new epc_clnt_object('plsdbug');
  BEGIN
    BEGIN
      epc_clnt.new_request(l_epc_clnt_object, 'plsdbug_print2', 1);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_dbug_ctx', epc.data_type_long, i_dbug_ctx);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_break_point', epc.data_type_string, i_break_point, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_fmt', epc.data_type_string, i_fmt, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg1', epc.data_type_string, i_arg1, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg2', epc.data_type_string, i_arg2, 4096);
      epc_clnt.send_request(l_epc_clnt_object);
    EXCEPTION
      WHEN OTHERS
      THEN
        l_epc_clnt_object.store();
        RAISE;
    END;
    l_epc_clnt_object.store();
  END;

  PROCEDURE plsdbug_print3(
    i_dbug_ctx IN epc.long_subtype,
    i_break_point IN epc.string_subtype,
    i_fmt IN epc.string_subtype,
    i_arg1 IN epc.string_subtype,
    i_arg2 IN epc.string_subtype,
    i_arg3 IN epc.string_subtype
  )
  IS
    l_epc_clnt_object epc_clnt_object := new epc_clnt_object('plsdbug');
  BEGIN
    BEGIN
      epc_clnt.new_request(l_epc_clnt_object, 'plsdbug_print3', 1);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_dbug_ctx', epc.data_type_long, i_dbug_ctx);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_break_point', epc.data_type_string, i_break_point, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_fmt', epc.data_type_string, i_fmt, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg1', epc.data_type_string, i_arg1, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg2', epc.data_type_string, i_arg2, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg3', epc.data_type_string, i_arg3, 4096);
      epc_clnt.send_request(l_epc_clnt_object);
    EXCEPTION
      WHEN OTHERS
      THEN
        l_epc_clnt_object.store();
        RAISE;
    END;
    l_epc_clnt_object.store();
  END;

  PROCEDURE plsdbug_print4(
    i_dbug_ctx IN epc.long_subtype,
    i_break_point IN epc.string_subtype,
    i_fmt IN epc.string_subtype,
    i_arg1 IN epc.string_subtype,
    i_arg2 IN epc.string_subtype,
    i_arg3 IN epc.string_subtype,
    i_arg4 IN epc.string_subtype
  )
  IS
    l_epc_clnt_object epc_clnt_object := new epc_clnt_object('plsdbug');
  BEGIN
    BEGIN
      epc_clnt.new_request(l_epc_clnt_object, 'plsdbug_print4', 1);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_dbug_ctx', epc.data_type_long, i_dbug_ctx);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_break_point', epc.data_type_string, i_break_point, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_fmt', epc.data_type_string, i_fmt, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg1', epc.data_type_string, i_arg1, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg2', epc.data_type_string, i_arg2, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg3', epc.data_type_string, i_arg3, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg4', epc.data_type_string, i_arg4, 4096);
      epc_clnt.send_request(l_epc_clnt_object);
    EXCEPTION
      WHEN OTHERS
      THEN
        l_epc_clnt_object.store();
        RAISE;
    END;
    l_epc_clnt_object.store();
  END;

  PROCEDURE plsdbug_print5(
    i_dbug_ctx IN epc.long_subtype,
    i_break_point IN epc.string_subtype,
    i_fmt IN epc.string_subtype,
    i_arg1 IN epc.string_subtype,
    i_arg2 IN epc.string_subtype,
    i_arg3 IN epc.string_subtype,
    i_arg4 IN epc.string_subtype,
    i_arg5 IN epc.string_subtype
  )
  IS
    l_epc_clnt_object epc_clnt_object := new epc_clnt_object('plsdbug');
  BEGIN
    BEGIN
      epc_clnt.new_request(l_epc_clnt_object, 'plsdbug_print5', 1);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_dbug_ctx', epc.data_type_long, i_dbug_ctx);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_break_point', epc.data_type_string, i_break_point, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_fmt', epc.data_type_string, i_fmt, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg1', epc.data_type_string, i_arg1, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg2', epc.data_type_string, i_arg2, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg3', epc.data_type_string, i_arg3, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg4', epc.data_type_string, i_arg4, 4096);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_arg5', epc.data_type_string, i_arg5, 4096);
      epc_clnt.send_request(l_epc_clnt_object);
    EXCEPTION
      WHEN OTHERS
      THEN
        l_epc_clnt_object.store();
        RAISE;
    END;
    l_epc_clnt_object.store();
  END;

  FUNCTION strerror(
    i_error IN epc.int_subtype
  )
  RETURN epc.string_subtype
  IS
    l_result VARCHAR2(4096 BYTE);
    l_epc_clnt_object epc_clnt_object := new epc_clnt_object('plsdbug');
  BEGIN
    BEGIN
      epc_clnt.new_request(l_epc_clnt_object, 'strerror', 0);
      epc_clnt.set_request_parameter(l_epc_clnt_object, 'i_error', epc.data_type_int, i_error);
      epc_clnt.send_request(l_epc_clnt_object);
      epc_clnt.recv_response(l_epc_clnt_object);
      epc_clnt.get_response_parameter(l_epc_clnt_object, 'result', epc.data_type_string, l_result);
    EXCEPTION
      WHEN OTHERS
      THEN
        l_epc_clnt_object.store();
        RAISE;
    END;
    l_epc_clnt_object.store();
    RETURN l_result;
  END;

END;
/

