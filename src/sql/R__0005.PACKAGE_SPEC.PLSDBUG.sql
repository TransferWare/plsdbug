CREATE OR REPLACE PACKAGE plsdbug AUTHID DEFINER IS

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

END plsdbug;
/

