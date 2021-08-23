CREATE OR REPLACE PACKAGE "DBUG" AUTHID DEFINER IS

  c_trace constant pls_integer := 0; -- trace dbug itself for values > 0
  c_trace_log4plsql constant pls_integer := 0; -- use log4plsql to trace instead of dbms_output
  c_ignore_errors constant pls_integer := 1; -- ignore dbug.enter / dbug.leave / dbug.print errors

  subtype method_t is varchar2(25); -- dbug_ || method

  c_method_plsdbug constant method_t := 'plsdbug';
  c_method_dbms_output constant method_t := 'dbms_output';
  c_method_log4plsql constant method_t := 'log4plsql';
  c_method_dbms_application_info constant method_t := 'dbms_application_info';

  subtype module_name_t is varchar2(4000);

  -- Break points
  subtype break_point_t is varchar2(100);

  -- Some double quoted identifiers which you can use instead of literals.
  -- Note that double quoted identifiers are case sensitive.
  "debug"   constant break_point_t := 'debug';
  "trace"   constant break_point_t := 'trace';
  "input"   constant break_point_t := 'input';
  "output"  constant break_point_t := 'output';
  "info"    constant break_point_t := 'info';
  "warning" constant break_point_t := 'warning';
  "error"   constant break_point_t := 'error';
  "fatal"   constant break_point_t := 'fatal';

  -- Log levels
  subtype level_t is positive;

  c_level_all constant level_t := 1;
  c_level_debug constant level_t := 2;
  c_level_info constant level_t := 3;
  c_level_warning constant level_t := 4;
  c_level_error constant level_t := 5;
  c_level_fatal constant level_t := 6;
  c_level_off constant level_t := 7;

  c_level_default constant level_t := c_level_debug;

  -- Some synonyms which you can use instead of literals.
  -- Note that double quoted identifiers are case sensitive.
  "ALL"     constant level_t := c_level_all;
  "DEBUG"   constant level_t := c_level_debug;
  "INFO"    constant level_t := c_level_info;
  "WARNING" constant level_t := c_level_warning;
  "ERROR"   constant level_t := c_level_error;
  "FATAL"   constant level_t := c_level_fatal;
  "OFF"     constant level_t := c_level_off;

  -- Table of levels indexed by a break point
  type break_point_level_t is table of level_t index by break_point_t;

  -- Table of lines
  type line_tab_t is table of varchar2(32767) index by binary_integer;

  procedure done;

  procedure activate(
    p_method in method_t,
    p_status in boolean default true
  );

  function active(
    p_method in method_t
  )
  return boolean;

  procedure set_level(
    p_level in level_t
  );

  function get_level
  return level_t;

  procedure set_break_point_level(
    p_break_point_level_tab in break_point_level_t
  );

  function get_break_point_level
  return break_point_level_t;

  procedure enter(
    p_module in module_name_t
  );

  -- To be used when dbug.enter / dbug.leave pairs are not in the call / procedure.
  -- For example: dbug_trigger.enter() and dbug_trigger.leave().
  procedure enter(
    p_module in module_name_t
  , p_called_from out nocopy module_name_t
  );

  procedure leave;

  -- See enter(p_module in module_name_t, p_called_from out module_name_t) above
  procedure leave(
    p_called_from in module_name_t
  );

  procedure on_error;

  -- called by on_error without parameters
  procedure on_error(
    p_function in varchar2,
    p_output in varchar2,
    p_sep in varchar2
  );

  procedure on_error(
    p_function in varchar2,
    p_output in dbug.line_tab_t
  );

  procedure leave_on_error;

  function cast_to_varchar2( p_value in boolean )
  return varchar2;

  procedure print(
    p_break_point in varchar2,
    p_str in varchar2
  );

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2
  );

  -- date is printed as YYYYMMDDHH24MISS
  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in date
  );

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in boolean
  );

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2
  );

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2
  );

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2,
    p_arg4 in varchar2
  );

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2,
    p_arg4 in varchar2,
    p_arg5 in varchar2
  );

  procedure split(
    p_buf in varchar2
  , p_sep in varchar2
  , p_line_tab out nocopy line_tab_t
  );

  /* Sourceforge transferware issue 2027441 Ignore dbms_output buffer overflow */

  /* setter */
  procedure set_ignore_buffer_overflow(
    p_value in boolean
  );

  /* getter */
  function get_ignore_buffer_overflow
  return boolean;

  --  functions to be used by DBUG_<method> packages

  function format_enter(
    p_module in module_name_t
  )
  return varchar2;

  function format_leave
  return varchar2;

  function format_print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_nr_arg in pls_integer,
    p_arg1 in varchar2,
    p_arg2 in varchar2 default null,
    p_arg3 in varchar2 default null,
    p_arg4 in varchar2 default null,
    p_arg5 in varchar2 default null
  )
  return varchar2;

end dbug;

-- [ 641894 ] Perl pod comment in dbug.pls

-- =cut
/

