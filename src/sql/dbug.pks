--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL$
REMARK

WHENEVER SQLERROR EXIT FAILURE

/*

  The following documentation uses the Perl pod format. A html file
  can be constructed by: 

        pod2html --infile=dbug.pls --outfile=dbug.html

=pod

=head1 NAME

dbug - Perform debugging in Oracle PL/SQL

=head1 SYNOPSIS

=cut

*/

-- [ 641894 ] Perl pod comment in dbug.pls

-- =pod

create or replace package dbug is

  subtype method_t is varchar2(25); -- dbug_ || method

  c_method_plsdbug constant method_t := 'plsdbug';
  c_method_dbms_output constant method_t := 'dbms_output';
  c_method_log4plsql constant method_t := 'log4plsql';
  c_method_dbms_application_info constant method_t := 'dbms_application_info';

  subtype module_name_t is varchar2(2000);

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

  procedure leave;

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

show errors

@@dbug_verify "dbug" "package"

/*

=head1 DESCRIPTION

The I<dbug> package is used for debugging. The destination of the debugging is
flexible. Initially three methods can be activated: I<plsdbug>, I<dbms_output>
and I<log4plsql>. The user of this package may provide his own method and
activate that (see the NOTES for section Plug and play).

The I<plsdbug> method implements the functionality of the I<dbug> library
written in the programming language C. This I<dbug> library can be used to
perform regression testing and profiling.

The communication to the I<plsdbug> application server must use a pipe:
'DBUG_' concatenated with the Oracle username. This enables private debugging
sessions. The I<plsdbug> application server must use this pipe too.

Debugging is by default not active and must be activated by the
client. Depending on the method, some extra initialisation may be needed
too (for example with plsdbug).

These are the functions/procedures:

=over 4

=item done

Cleanup all the mess. Run the done function for each activated
package. So call DBUG_DBMS_OUTPUT.DONE when DBMS_OUTPUT is activated.

=item activate

The activate method is used to activate or deactivate debugging by the
client. Parameters are the method of debugging and enabling/disabling that
method. Initially the available methods are 'PLSDBUG', 'DBMS_OUTPUT' and
'LOG4PLSQL'. A method indicates which implementation package to use for
debugging. An implementation package is the method name prefixed with
dbug_. More than one method may be enabled, hence output to different
destinations is possible.

=item active

Is debugging active for a method?

=item set_level

Set the current threshold level which determines which dbug operations
(dbug.enter, dbug.print, dbug.leave, dbug.on_error,
dbug.leave_on_error or their buffered variants) will be executed or
not. The default threshold level is DEBUG. 

This method may only be used when no dbug work is in progress. Dbug work is in
progress if dbug.enter operations are waiting to be matched by their
dbug.leave.

The exception PROGRAM_ERROR is raised when dbug work is in
progress. The exception VALUE_ERROR is raised when the level is not
between C_LEVEL_ALL and C_LEVEL_OFF.

When the level of a dbug operation is at least the current threshold
level, the dbug operation is executed.

The dbug operations dbug.enter, dbug.leave use a fixed break point
'trace' with level DEBUG.

The level for dbug.print (and dbug.on_error which calls dbug.print
with break point 'error') is determined by its break point. 

For historical reasons 'debug', 'trace', 'input', 'output' have all the DEBUG
level, 'info' has the INFO level, 'warning' has the WARNING level, 'error' the
ERROR level and 'fatal' the FATAL level. Other break points not mentioned
here, have the DEBUG level by default.

You may override the default break point levels by calling
B<set_breakpoint_level>.

=item get_level

Returns the current log level.

=item set_breakpoint_level

Assign levels to break points. When dbug encounters a break point not
set in this table, that break point will get a default level of
DEBUG. See B<set_level> for the default break point levels.

The exception PROGRAM_ERROR is raised when dbug work is in
progress. The exception VALUE_ERROR is raised when the level for a
break point is not between C_LEVEL_DEBUG and C_LEVEL_FATAL.

=item get_breakpoint_level

Returns the current break point levels.

=item enter

Enter a function called I<p_module>. To be used at the start of a function.

=item leave

Leave a function. To be used at the end of a function.

=item on_error

Show errors. To be used in an exception block. Must be the first dbug
operation in such a block. Errors shown include sqlerrm,
dbms_utility.format_error_backtrace (if package dbms_utility is available) and
Oracle Headstart errors (if package cg$errors is available). The availability
of the last two packages is verified using dynamic SQL. Please note that the
Oracle Headstart errors are not removed by displaying them (the error stack is
reconstructed).

=item leave_on_error

Leave a function. To be used in an exception block. Calls on_error and
leave. This must be last dbug operation in an exception block.

=item cast_to_varchar2

Casts a boolean to varchar2. It returns 'TRUE' for TRUE, 'FALSE' for FALSE and
'UNKNOWN' for NULL.

=item print

Print a line. Parameters are a break point and a string or a I<printf> format
string and up till 5 string arguments. If the string arguments are NULL, the
string <NULL> is used. A date argument (p_arg1) uses to_char(p_arg1,
'YYYYMMDDHH24MISS') to convert to a varchar2.

=item set_ignore_buffer_overflow

Set the flag for ignoring a dbms_output buffer overflow.

=item get_ignore_buffer_overflow

Get the flag for ignoring a dbms_output buffer overflow.

=back

=head1 NOTES

=head2 Plug and play

Each method must be implemented by an implementation package named after the
method name with a prefix of dbug_. So for dbms_output there is a package
dbug_dbms_output which uses dbms_output to do the logging.

The I<dbug> package uses dynamic SQL internally which calls the method
specific procedures. Each implementation package should at least provide the
following procedures:

=over 4

=item done

  procedure done;

=item enter

  procedure enter(
    p_module in dbug.module_name_t
  );

=item leave

  procedure leave;

=item print

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2
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

=back

=head2 Missing dbug.leave calls

For every dbug.enter call at the start of a method the program has to execute
dbug.leave too. But, since exceptions and program logic errors (method may
return before calling dbug.leave) may occur, the dbug package tries to adjust
for those missing dbug.leave calls.

So, given this anonymous block:

   1  declare
   2
   3  procedure f1(p_count pls_integer := 5)
   4  is
   5  begin
   6    dbug.enter('f1');
   7    if p_count > 0
   8    then
   9      f1(p_count-1);
  10    end if;
  11    -- Oops, forgot to dbug.leave;
  12  end;
  13
  14  procedure f2
  15  is
  16  begin
  17    dbug.enter('f2');
  18    f1;
  19    dbug.leave;
  20  end;
  21
  22  procedure f3
  23  is
  24  begin
  25    dbug.enter('f3');
  26    f2;
  27    dbug.leave;
  28  end;
  29
  30  begin
  31    dbug.activate('dbms_output');
  32    dbug.enter('main');
  33    f3;
  34    dbug.leave;
  35* end;

the stack trace will be (without any adjustments):

  >main
  |   >f3
  |       >f2
  |           >f1
  |               >f1
  |                   >f1
  |                       >f1
  |                           >f1
  |                               >f1
  |                               <
  |                           <
  |                       <

However, the task is to show a normal trace like this:

  >main
  |   >f3
  |       >f2
  |           >f1
  |               >f1
  |                   >f1
  |                       >f1
  |                           >f1
  |                               >f1
  |                               <
  |                           <
  |                       <
  |                   <
  |               <
  |           <
  |       <
  |   <
  <

=head3 Analysis

The dbms_utility.format_call_stack provides us information about the
PL/SQL call stack. In our example when dbug.enter is called in f1
while being called from f2, this is the call stack (XXX is any line number):

  ----- PL/SQL Call Stack -----
    object      line  object
    handle    number  name
  69E09330       XXX  package body EPCAPP.DBUG
  69E09330       XXX  package body EPCAPP.DBUG
  6953B000         6  anonymous block
  6953B000        18  anonymous block
  6953B000        26  anonymous block
  ...

When line 11 would have contained dbug.leave, this would be the call
stack when dbug.leave is called in f1 while being called from f2:

  ----- PL/SQL Call Stack -----
    object      line  object
    handle    number  name
  69E09330       XXX  package body EPCAPP.DBUG
  69E09330       XXX  package body EPCAPP.DBUG
  6953B000        11  anonymous block
  6953B000        18  anonymous block
  6953B000        26  anonymous block
  ...

However, since the first dbug.leave called is in line 19, this is the
call stack when dbug.leave is called for the first time:

  ----- PL/SQL Call Stack -----
    object      line  object
    handle    number  name
  69E09330       XXX  package body EPCAPP.DBUG
  69E09330       XXX  package body EPCAPP.DBUG
  6953B000        19  anonymous block
  6953B000        26  anonymous block
  ...

So, given these stack traces, the idea is to store (stackwise) at each
dbug.enter call the second line after the last EPCAPP.DBUG line. Thus
when dbug.enter is called from f1 and f2, that line will be:

  6953B000        18  anonymous block

When dbug.leave is called, the second line after the last EPCAPP.DBUG
line is compared against the stored line. When dbug.leave has not been
forgotton, these lines are the same. But when one or more
dbug.leave calls have been forgotton (due to an exception or
program logic error), we have to check previous lines stored when
dbug.enter was called.

In our example the line when dbug.leave is called first is:

  6953B000        26  anonymous block

and the stack maintained by dbug.enter is

  6953B000         9  anonymous block
  6953B000         9  anonymous block
  6953B000         9  anonymous block
  6953B000         9  anonymous block
  6953B000         9  anonymous block
  6953B000        18  anonymous block
  6953B000        26  anonymous block

So now we know that 6 dbug.leave calls have been missed.

=head2 Restarting a PL/SQL block with dbug.leave calls missing due to an exception

When this anonymous block is invoked twice in SQL*Plus:

   1  begin
   2    dbug.activate('dbms_output');
   3    dbug.enter('main');
   4    raise value_error;
   5    dbug.leave;
   6  exception
   7   when others then null;
   8* end;

the stack trace will be (without any adjustments):

  >main
  |   >main

The task is to show a normal trace like this:

  >main
  <
  >main

=head3 Analysis

This problem can be solved by storing the call stack and module name
the first time dbug.enter has been called. Now when a subsequent
dbug.enter call is made with the same module name and call stack, we
know that the second dbug.enter call should be the first on the
stack. So we adjust for the missing dbug.leave calls and reset the
stack.

=head1 EXAMPLES

=head2 Using the plsdbug method

  declare
    function
    factorial(p_value in pls_integer)
    return pls_integer
    is
      l_value pls_integer := p_value;
    begin
      dbug.enter( 'factorial' );
      dbug.print( 'find', 'find %s factorial', l_value );
      if (l_value > 1) 
      then
        l_value := l_value * factorial( l_value-1 );
      end if;
      dbug.print( 'result', 'result is %s', l_value );
      dbug.leave;
      return (l_value);
    exception
      when others
      then
        dbug.leave;
        return -1;
    end;
  begin
    dbug.activate('PLSDBUG', true);
    dbug_plsdbug.init( 'd;t;g' ); -- debugging, tracing and profiling
    dbms_output.put_line( factorial( 5 ) );
    dbug.done;
  end;

=head2 Changing log level

The following SQL*Plus script will not print anything, because only error
break point are printed:

  set serveroutput on

  begin
    dbug.set_level(c_level_error);
    dbug.activate('DBMS_OUTPUT');
    dbug.enter('main');
    dbug.leave;
  end;

The following SQL*Plus script will print the error line:

  set serveroutput on

  begin
    dbug.set_level(c_level_error);
    dbug.activate('DBMS_OUTPUT');
    dbug.enter('main');
    dbug.print('error', 'Only this line will be printed');
    dbug.leave;
  end;

=head1 AUTHOR

Gert-Jan Paulissen, E<lt>gpaulissen@transfer-solutions.comE<gt>.

=head1 BUGS

=head1 SEE ALSO

=over 4

=item dbug

See L<http://sourceforge.net/projects/transferware>.

=item LOG4PLSQL

See L<http://sourceforge.net/projects/log4plsql>.

=back

=head1 COPYRIGHT

All rights reserved by Transfer Solutions b.v.

=cut

*/

