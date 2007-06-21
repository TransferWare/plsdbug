REMARK $Id$ 

WHENEVER SQLERROR EXIT FAILURE

SET DOCUMENT OFF

DOCUMENT

  The following documentation uses the Perl pod format. A html file
  can be constructed by: 

        pod2html --infile=dbug.pls --outfile=dbug.html

=pod

=head1 NAME

dbug - Perform debugging in Oracle PL/SQL

=head1 SYNOPSIS

=cut

#

-- [ 641894 ] Perl pod comment in dbug.pls

-- =pod

create or replace package dbug is

  subtype method_t is varchar2(20);

  c_method_plsdbug constant method_t := 'plsdbug';
  c_method_dbms_output constant method_t := 'dbms_output';
  c_method_log4plsql constant method_t := 'log4plsql';

  subtype module_name_t is varchar2(2000);

  procedure done;

  procedure activate(
    i_method in method_t,
    i_status in boolean default true
  );

  function active(
    i_method in method_t
  )
  return boolean;

  procedure enter(
    i_module in module_name_t
  );

  procedure enter_b(
    i_module in module_name_t
  );

  pragma restrict_references( enter_b, wnds );

  procedure leave;

  procedure leave_b;

  pragma restrict_references( leave_b, wnds );

  procedure on_error;

  procedure leave_on_error;

  function cast_to_varchar2( i_value in boolean )
  return varchar2;

  pragma restrict_references( cast_to_varchar2, wnds );

  procedure print(
    i_break_point in varchar2,
    i_str in varchar2
  );

  procedure print_b(
    i_break_point in varchar2,
    i_str in varchar2
  );

  pragma restrict_references( print_b, wnds );

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2
  );

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2
  );

  pragma restrict_references( print_b, wnds );

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in boolean
  );

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in boolean
  );

  pragma restrict_references( print_b, wnds );

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2
  );

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2
  );

  pragma restrict_references( print_b, wnds );

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2
  );

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2
  );

  pragma restrict_references( print_b, wnds );

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2,
    i_arg4 in varchar2
  );

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2,
    i_arg4 in varchar2
  );

  pragma restrict_references( print_b, wnds );

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2,
    i_arg4 in varchar2,
    i_arg5 in varchar2
  );

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2,
    i_arg4 in varchar2,
    i_arg5 in varchar2
  );

  pragma restrict_references( print_b, wnds );

  --  functions to be used by DBUG_<method> packages

  function format_enter(
    i_module in module_name_t
  )
  return varchar2;

  function format_leave
  return varchar2;

  function format_print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_nr_arg in pls_integer,
    i_arg1 in varchar2,
    i_arg2 in varchar2 default null,
    i_arg3 in varchar2 default null,
    i_arg4 in varchar2 default null,
    i_arg5 in varchar2 default null
  ) 
  return varchar2;

end dbug;

-- [ 641894 ] Perl pod comment in dbug.pls

-- =cut

/

DOCUMENT

=head1 DESCRIPTION

The I<dbug> package is used for debugging. Currently two methods are available
for debugging: the I<plsdbug> package and the Oracle package I<dbms_output>.

The I<plsdbug> package implements the functionality of the I<dbug> library
written in the programming language C. This I<dbug> library can be used to
perform regression testing and profiling.

The communication to the I<plsdbug> application server must use a pipe:
'DBUG_' concatenated with the Oracle username. This enables private debugging
sessions. The I<plsdbug> application server must use this pipe too.

Debugging is by default not active and must be activated by the client.

=over 4

=done

Cleanup all the mess. Run the done function for each activated package. So DBUG_DBMS_OUTPUT.DONE when DBMS_OUTPUT is activated.

=item activate

The activate method is used to activate or deactivate debugging by the
client. Parameters are the method of debugging and enabling/disabling that
method. Current methods are 'PLSDBUG' and 'DBMS_OUTPUT', which identify the
package to use for debugging. More than one method may be enabled, hence
output to different destinations is possible.

=item active

Is debugging active for a method?

=item enter, enter_b

Enter a function called I<i_module>.

The buffered version B<enter_b> postpones its action till one of the
unbuffered functions (enter, leave, print) is called. This is useful for
debugging which have restrictions on its use (for example read/write no
database state).

=item leave, leave_b

Leave a function. This must always be called if enter was called before, even
if an exception has been raised.

The buffered version B<leave_b> postpones its action.

=item on_error

Show errors when in an exception block. Must be the first dbug
operation in such a block. Errors shown include sqlerrm,
dbms_utility.format_error_backtrace (if
dbms_utility.format_error_backtrace is available) and Oracle Headstart
errors (if cg$errors.geterrors is available). The availability of the
last two errors is verified with dynamic SQL.

=item leave_on_error

Leave a function in an exception block. Calls on_error and leave. This
must be last dbug operation in an exception block.

=item cast_to_varchar2

Cast boolean value to varchar2. Returns 'TRUE' for TRUE, 'FALSE' for FALSE and
'UNKNOWN' for NULL.

=item print, print_b

Print a line. Parameters are a break point and a string or a I<printf> format
string and up till 5 string arguments. If the string arguments are NULL, the
string <NULL> is sent. For the 'DBMS_OUTPUT' method only '%s' format strings
may be used.

The buffered version B<print_b> postpones its action.

=back

=head1 NOTES

=head1 EXAMPLES

  declare
    function
    factorial(i_value in pls_integer)
    return pls_integer
    is
      v_value pls_integer := i_value;
    begin
      dbug.enter( 'factorial' );
      dbug.print( 'find', 'find %s factorial', v_value );
      if (v_value > 1) 
      then
        v_value := v_value * factorial( v_value-1 );
      end if;
      dbug.print( 'result', 'result is %s', v_value );
      dbug.leave;
      return (v_value);
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

=head1 AUTHOR

Gert-Jan Paulissen, E<lt>gpaulissen@transfer-solutions.comE<gt>.

=head1 BUGS

=head1 SEE ALSO

=over 4

=item dbug documentation

The I<dbug> documentation by G.J. Paulissen

=item epc documentation

The B<E>xternal B<P>rocedure B<C>all toolkit by H.G. Wouden and G.J. Paulissen.

=back

=head1 COPYRIGHT

All rights reserved by Transfer Solutions b.v.

=cut

#

create or replace package body dbug is

  subtype module_id_t is pls_integer;

  c_module_id_enter  constant module_id_t := 1;
  c_module_id_leave  constant module_id_t := 2;
  c_module_id_print1 constant module_id_t := 3;
  c_module_id_print2 constant module_id_t := 4;
  c_module_id_print3 constant module_id_t := 5;
  c_module_id_print4 constant module_id_t := 6;
  c_module_id_print5 constant module_id_t := 7;

  c_active_base constant pls_integer := 2;
  c_active_plsdbug constant pls_integer := power(c_active_base, 0); /* base^0 */
  c_active_dbms_output constant pls_integer := power(c_active_base, 1); /* base^1 */
  c_active_log4plsql constant pls_integer := power(c_active_base, 2); /* base^2 */

  type active_str_t is table of user_objects.object_name%type index by binary_integer;

  g_active_str active_str_t;

  -- this records saves an action to be processed (flushed) later on
  type action_t is record (
    active pls_integer, -- which components were active at the time of the call
    module_id module_id_t, -- the module id to call
    module_name module_name_t, -- the module name
    break_point varchar2(32767), -- the break point
    fmt varchar2(32767),
    arg1 varchar2(32767),
    arg2 varchar2(32767),
    arg3 varchar2(32767),
    arg4 varchar2(32767),
    arg5 varchar2(32767)
  );

  type action_table_t is table of action_t index by binary_integer;

  v_action_table action_table_t;

  v_active pls_integer := 0;

  v_level pls_integer := 0;
  c_indent constant char(4) := '|   ';

  c_null constant varchar2(6) := '<NULL>';

  type call_rec_t is record (
    module_name varchar2(32767)
  , called_from varchar2(32767) -- the location from which this module is called (initially null)
  , other_calls varchar2(32767) -- only set for the first index
  );
  
  type call_tab_t is table of call_rec_t index by binary_integer;

  v_call_tab call_tab_t;

  type cursor_tabtype is table of integer index by varchar2(4000);

  -- table of dbms_sql cursors
  g_cursor_tab cursor_tabtype;

  /* local modules */
  procedure show_error( i_line in varchar2 )
  is
  begin
    dbms_output.put_line(substr('ERROR: ' || i_line, 1, 255));
  end show_error;

  function format_print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_nr_arg in pls_integer,
    i_arg1 in varchar2,
    i_arg2 in varchar2 default null,
    i_arg3 in varchar2 default null,
    i_arg4 in varchar2 default null,
    i_arg5 in varchar2 default null
  ) 
  return varchar2
  is
    v_pos pls_integer;
    v_arg varchar2(32767);
    v_str varchar2(32767);
    v_arg_nr pls_integer;
  begin
    v_pos := 1;
    v_str := i_fmt;
    v_arg_nr := 1;
    loop
      v_pos := instr(v_str, '%s', v_pos);

      /* stop if '%s' is not found or when the arguments have been exhausted */
      exit when v_pos is null or v_pos = 0 or v_arg_nr > i_nr_arg;

      v_arg := 
        case v_arg_nr
          when 1 then i_arg1
          when 2 then i_arg2
          when 3 then i_arg3
          when 4 then i_arg4
          when 5 then i_arg5
        end;

      if v_arg is null then v_arg := c_null; end if;

      /* '%s' is two characters long so replace substr from 1 till v_pos+1 */
      v_str := 
        replace( substr(v_str, 1, v_pos+1), '%s', v_arg ) ||
        substr( v_str, v_pos+2 );

      /* '%s' is replaced  by v_arg hence continue at position after
         substituted string */
      v_pos := v_pos + 1 + nvl(length(v_arg), 0) - 2 /* '%s' */;
      v_arg_nr := v_arg_nr + 1;
    end loop;

    v_str :=
      rpad( c_indent, v_level*4, ' ' ) ||
      i_break_point ||
      ': ' ||
      v_str;

    return v_str;
  end format_print;

  procedure get_cursor
  ( p_key in varchar2
  , p_plsql_stmt in varchar2
  , p_cursor out integer
  )
  is
  begin
    if g_cursor_tab.exists(p_key)
    then
      p_cursor := g_cursor_tab(p_key);
    else
      p_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(p_cursor, p_plsql_stmt, dbms_sql.native);
      g_cursor_tab(p_key) := p_cursor;
    end if;
  end get_cursor;

  function active(
    i_active in pls_integer
  , i_method in pls_integer
  )
  return boolean
  is
    l_result constant boolean := mod(i_active, i_method*c_active_base) >= i_method;
  begin
    return l_result;
  end active;

  procedure handle_error( 
    i_sqlcode in pls_integer, 
    i_sqlerrm in varchar2
  )
  is
  begin
    dbms_output.put_line( substr( i_sqlerrm, 1, 255 ) );
  exception
    when others
    then
      null;
  end handle_error;

  procedure flush
  is
    v_action action_t;
    l_active binary_integer;
    l_active_str varchar2(30);
    l_cursor integer;
    l_dummy integer;
  begin
    if v_action_table.count = 0 
    then
      return; 
    end if;

    for v_nr in v_action_table.first .. v_action_table.last
    loop
      v_action := v_action_table(v_nr);

      l_active := 0;

      -- [ 1677186 ] Enter/leave pairs are not displayed correctly
      -- The level should be increased/decreased only once no matter how many methods are active.
      -- Decrement must take place before the leave.
      if v_action.module_id = c_module_id_leave
      then
        v_level := greatest(v_level - 1, 0);
      end if;

      loop
        exit when not(g_active_str.exists(l_active));
 
        l_active_str := g_active_str(l_active);

        if active(v_action.active, power(c_active_base, l_active))
        then
        begin
          if v_action.module_id = c_module_id_enter
          then
            get_cursor
            ( 'dbug_'||l_active_str||'.enter'
            , 'begin dbug_'||l_active_str||'.enter(:0); end;'
            , l_cursor
            );
            dbms_sql.bind_variable(l_cursor, '0', v_action.module_name);
            l_dummy := dbms_sql.execute(l_cursor);
          elsif v_action.module_id = c_module_id_leave
          then
            get_cursor
            ( 'dbug_'||l_active_str||'.leave'
            , 'begin dbug_'||l_active_str||'.leave; end;'
            , l_cursor
            );
            l_dummy := dbms_sql.execute(l_cursor);
          elsif v_action.module_id = c_module_id_print1
          then
            get_cursor
            ( 'dbug_'||l_active_str||'.print1'
            , 'begin dbug_'||l_active_str||'.print(:0, :1, :2); end;'
            , l_cursor
            );
            dbms_sql.bind_variable(l_cursor, '0', v_action.break_point);
            dbms_sql.bind_variable(l_cursor, '1', v_action.fmt);
            dbms_sql.bind_variable(l_cursor, '2', nvl(v_action.arg1, c_null));
            l_dummy := dbms_sql.execute(l_cursor);
          elsif v_action.module_id = c_module_id_print2
          then
            get_cursor
            ( 'dbug_'||l_active_str||'.print2'
            , 'begin dbug_'||l_active_str||'.print(:0, :1, :2, :3); end;'
            , l_cursor
            );
            dbms_sql.bind_variable(l_cursor, '0', v_action.break_point);
            dbms_sql.bind_variable(l_cursor, '1', v_action.fmt);
            dbms_sql.bind_variable(l_cursor, '2', nvl(v_action.arg1, c_null));
            dbms_sql.bind_variable(l_cursor, '3', nvl(v_action.arg2, c_null));
            l_dummy := dbms_sql.execute(l_cursor);
          elsif v_action.module_id = c_module_id_print3
          then
            get_cursor
            ( 'dbug_'||l_active_str||'.print3'
            , 'begin dbug_'||l_active_str||'.print(:0, :1, :2, :3, :4); end;'
            , l_cursor
            );
            dbms_sql.bind_variable(l_cursor, '0', v_action.break_point);
            dbms_sql.bind_variable(l_cursor, '1', v_action.fmt);
            dbms_sql.bind_variable(l_cursor, '2', nvl(v_action.arg1, c_null));
            dbms_sql.bind_variable(l_cursor, '3', nvl(v_action.arg2, c_null));
            dbms_sql.bind_variable(l_cursor, '4', nvl(v_action.arg3, c_null));
            l_dummy := dbms_sql.execute(l_cursor);
          elsif v_action.module_id = c_module_id_print4
          then
            get_cursor
            ( 'dbug_'||l_active_str||'.print4'
            , 'begin dbug_'||l_active_str||'.print(:0, :1, :2, :3, :4, :5); end;'
            , l_cursor
            );
            dbms_sql.bind_variable(l_cursor, '0', v_action.break_point);
            dbms_sql.bind_variable(l_cursor, '1', v_action.fmt);
            dbms_sql.bind_variable(l_cursor, '2', nvl(v_action.arg1, c_null));
            dbms_sql.bind_variable(l_cursor, '3', nvl(v_action.arg2, c_null));
            dbms_sql.bind_variable(l_cursor, '4', nvl(v_action.arg3, c_null));
            dbms_sql.bind_variable(l_cursor, '5', nvl(v_action.arg4, c_null));
            l_dummy := dbms_sql.execute(l_cursor);
          elsif v_action.module_id = c_module_id_print5
          then
            get_cursor
            ( 'dbug_'||l_active_str||'.print5'
            , 'begin dbug_'||l_active_str||'.print(:0, :1, :2, :3, :4, :5, :6); end;'
            , l_cursor
            );
            dbms_sql.bind_variable(l_cursor, '0', v_action.break_point);
            dbms_sql.bind_variable(l_cursor, '1', v_action.fmt);
            dbms_sql.bind_variable(l_cursor, '2', nvl(v_action.arg1, c_null));
            dbms_sql.bind_variable(l_cursor, '3', nvl(v_action.arg2, c_null));
            dbms_sql.bind_variable(l_cursor, '4', nvl(v_action.arg3, c_null));
            dbms_sql.bind_variable(l_cursor, '5', nvl(v_action.arg4, c_null));
            dbms_sql.bind_variable(l_cursor, '6', nvl(v_action.arg5, c_null));
            l_dummy := dbms_sql.execute(l_cursor);
          end if;
        exception
          when others
          then 
            handle_error( SQLCODE, SQLERRM );
        end;
        end if;

        l_active := l_active + 1;
      end loop;

      -- [ 1677186 ] Enter/leave pairs are not displayed correctly
      -- Increment after all actions have been done.
      if v_action.module_id = c_module_id_enter
      then
        v_level := v_level + 1;
      end if;

      v_action_table.delete(v_nr);
    end loop;
  end flush;

  procedure get_called_from
  ( o_latest_call out varchar2
  , o_other_calls out varchar2
  )
  is
    v_format_call_stack constant varchar2(32767) := dbms_utility.format_call_stack;
    v_pos pls_integer;
    v_start pls_integer := 1;
    v_lines_without_dbug pls_integer := null;
  begin
    /* 

        Given this anonymous block

  1  declare
  2
  3  procedure f1(i_count pls_integer := 5)
  4  is
  5  begin
  6    dbug.enter('f1');
  7    if i_count > 0
  8    then
  9      f1(i_count-1);
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

        the task is to show a normal trace like this:

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

        The stack trace will be (without any adjustments):

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


        The format_call_stack in the DBUG package when dbug.enter is called in
        f1 while being called from f2 is this:

----- PL/SQL Call Stack -----
  object      line  object
  handle    number  name
69E09330       439  package body EPCAPP.DBUG
69E09330       421  package body EPCAPP.DBUG
6953B000         6  anonymous block
6953B000        18  anonymous block
6953B000        26  anonymous block
...

       	Now let us assume that we store the format call stack each
       	time when dbug.enter is called (a stack of format call
       	stacks).

       	In the example the last format call stack will be:

6953B000        18  anonymous block (f2 invokes f1 which invokes dbug.enter)
6953B000        26  anonymous block (f3 invokes f1 which invokes dbug.enter)
...

        Now when the first call to dbug.leave is made after all
        dbug.enter calls, the format call stack will be:

----- PL/SQL Call Stack -----
  object      line  object
  handle    number  name
69E09330       560  package body EPCAPP.DBUG
69E09330       464  package body EPCAPP.DBUG
6953B000        19  anonymous block
6953B000        26  anonymous block (f3 invokes f1 which invokes dbug.leave)
...

	But now let us assume that line 11 in the anonymous block is
	fixed (i.e. calls dbug.leave).
       	The format_call_stack in the DBUG package when dbug.leave is
       	called in f1 while being called from f2 is:


----- PL/SQL Call Stack -----
  object      line  object
  handle    number  name
69E09330       560  package body EPCAPP.DBUG
69E09330       464  package body EPCAPP.DBUG
6953B000        11  anonymous block 
6953B000        18  anonymous block (f2 invokes f1 which invokes dbug.leave)
6953B000        26  anonymous block (f3 invokes f1 which invokes dbug.leave)
...

        Now you can conclude that one dbug.leave has been forgotten in
        the original anonymous block, so you extra dbug.leave calls
        have to be made.

	So the algorithm seems to be:
	1) remove the header and subsequent lines from the DBUG
	package from the format call stack when dbug.enter/dbug.leave
	is called.
	2a) when dbug.enter is called, push the adjusted format call
	stack to the internal stack.
	2b) when dbug.leave is called, find the first common line (26
	here) and determine the number of lines before this common
	line. Everything is OK when the enter/leave line counts are the
	same, otherwise the difference tells you how many times you
	have to simulate dbug.leave. Adjust the internal stack (pop at
	least once plus the difference).

    */

    loop
      v_pos := instr(v_format_call_stack, chr(10), v_start);

      exit when v_pos is null or v_pos = 0;
        
      v_lines_without_dbug := 
        case instr(substr(v_format_call_stack, v_start, v_pos-v_start), '.DBUG')
          when 0 
          then v_lines_without_dbug + 1 /* null+1 is null */
          else 0
        end;

      if v_lines_without_dbug = 2 -- the line from which the method invoking dbug is called
      then
        o_latest_call := substr(v_format_call_stack, v_start, v_pos-v_start);
        o_other_calls := substr(v_format_call_stack, v_pos+1);
	exit;
      end if;
  
      v_start := v_pos+1;
    end loop;
  end get_called_from;

  procedure pop_call_stack( i_lwb in binary_integer )
  is
  begin
    -- GJP 21-04-2006 
    -- When there is a mismatch in enter/leave pairs 
    -- (for example caused by uncaught expections or program errors)
    -- we must pop from the call stack (v_call_tab) all entries through
    -- the one which has the same called from location as this call.
    -- When there is no mismatch this means the top entry from v_call_tab will be removed.
    -- See also get_called_from for an example.

    if i_lwb = v_call_tab.last
    then
      null;
    else
      show_error('Popping ' || to_char(v_call_tab.last - i_lwb) || ' missing dbug.leave calls');
    end if;

    for i_idx in reverse i_lwb .. v_call_tab.last
    loop
      v_action_table(v_action_table.COUNT+1).active := v_active;
      v_action_table(v_action_table.COUNT).module_id := c_module_id_leave;
    end loop;
    v_call_tab.delete(i_lwb, v_call_tab.last);
  end pop_call_stack;
  
  /* global modules */

  procedure done
  is
    l_active binary_integer;
    l_active_str varchar2(30);
    l_cursor integer;
    l_dummy binary_integer;
  begin
    dbug.flush; -- GJP 23-11-2005 Always flush at the end.

    l_active := 0;

    loop
      exit when not(g_active_str.exists(l_active));
 
      l_active_str := g_active_str(l_active);

      if active(v_active, power(c_active_base, l_active))
      then
        begin
          get_cursor
          ( 'dbug_'||l_active_str||'.done'
          , 'begin dbug_'||l_active_str||'.done; end;'
          , l_cursor
          );
          l_dummy := dbms_sql.execute(l_cursor);
        end;
      end if;

      l_active := l_active + 1;
    end loop;

  end done;

  procedure activate(
    i_method in method_t,
    i_status in boolean
  )
  is
    v_method pls_integer := null;
  begin
    if upper(i_method) like '___DBUG' -- backwards compability with TS_DBUG
    then
      v_method := c_active_plsdbug;
    elsif upper(i_method) = upper(c_method_dbms_output)
    then
      v_method := c_active_dbms_output;
    elsif upper(i_method) = upper(c_method_log4plsql)
    then
      v_method := c_active_log4plsql;
    else
      raise value_error;
    end if;

    if v_method is not null and i_status is not null and
       active(v_active, v_method) <> i_status
    then
      if i_status = false
      then
        /* active() = true */
        v_active := v_active - v_method;
      else
        /* active() = false */
        v_active := v_active + v_method;
      end if;
    end if;

    if v_method is not null and i_status is not null
    then
      if active(v_active, v_method) = i_status
      then
        null;
      else
        raise value_error;
      end if;
    end if;
  end activate;

  function active(
    i_method in method_t
  )
  return boolean
  is
  begin
    if upper(i_method) like '___DBUG' -- backwards compability with TS_DBUG
    then
      return active(v_active, c_active_plsdbug);
    elsif upper(i_method) = upper(c_method_dbms_output)
    then
      return active(v_active, c_active_dbms_output);
    elsif upper(i_method) = upper(c_method_log4plsql)
    then
      return active(v_active, c_active_log4plsql);
    else
      return null;
    end if;
  end active;

  procedure enter(
    i_module in module_name_t
  ) is
  begin
    enter_b( i_module => i_module );
    flush;
  end enter;

  procedure enter_b(
    i_module in module_name_t
  ) is
  begin
    if v_active = 0 then return; end if;

    -- GJP 21-04-2006 Store the location from which dbug.enter is called
    declare
      v_idx constant pls_integer := v_call_tab.count + 1;
      v_other_calls varchar2(32767);
    begin
       v_call_tab(v_idx).module_name := i_module;
       -- only the first other_calls has to be stored
       if v_idx = 1
       then
         get_called_from(v_call_tab(v_idx).called_from, v_call_tab(v_idx).other_calls);
       else
         get_called_from(v_call_tab(v_idx).called_from, v_other_calls);

	 if ( v_call_tab(v_call_tab.first).module_name = i_module and
              nvl(v_call_tab(v_call_tab.first).other_calls, 'X') = nvl(v_other_calls, 'X') )
	 then
           show_error('Module name and other calls equal to the first one while the dbug call stack count is ' || v_call_tab.count);

	   -- this is probably a situation where an outermost PL/SQL block
	   -- is called for another time and where the previous time did not
	   -- not have all dbug.enter calls matched by a dbug.leave.

	   -- save the called_from info before destroying v_call_tab
	   v_call_tab(0) := v_call_tab(v_idx);

	   v_call_tab.delete(v_idx); -- this one is moved to nr 1
	   pop_call_stack(1); -- erase the complete stack (except index 0)
	   v_call_tab(1) := v_call_tab(0);
	   v_call_tab(1).other_calls := v_other_calls;
	   v_call_tab.delete(0);
	 end if;
       end if; 
    end;

    v_action_table(v_action_table.COUNT+1).active := v_active;
    v_action_table(v_action_table.COUNT).module_id := c_module_id_enter;
    v_action_table(v_action_table.COUNT).module_name := i_module;
  end enter_b;

  function format_enter(
    i_module in module_name_t
  )
  return varchar2
  is
  begin
    return rpad( c_indent, v_level*4, ' ' ) || '>' || i_module;
  end format_enter;

  procedure leave
  is
  begin
    leave_b;
    flush;
  end leave;

  procedure leave_b
  is
  begin
    if v_active = 0 then return; end if;

    -- GJP 21-04-2006 
    -- When there is a mismatch in enter/leave pairs 
    -- (for example caused by uncaught expections or program errors)
    -- we must pop from the call stack (v_call_tab) all entries through
    -- the one which has the same called from location as this call.
    -- When there is no mismatch this means the top entry from v_call_tab will be removed.
    -- See also get_called_from for an example.

    declare
      v_called_from varchar2(32767);
      v_other_calls_dummy varchar2(32767);
      v_idx pls_integer := v_call_tab.last;
    begin
       get_called_from(v_called_from, v_other_calls_dummy);

      -- adjust for mismatch in enter/leave pairs
      loop
        if v_idx is null
	then
          -- called_from location for leave does not exist in v_call_tab
          raise program_error;
        elsif nvl(v_call_tab(v_idx).called_from, 'X') = nvl(v_called_from, 'X')
	then
          pop_call_stack(v_idx);
          exit;
        else
          v_idx := v_call_tab.prior(v_idx);
	end if;
      end loop;
    end;
  end leave_b;

  procedure on_error
  is
    v_output varchar2(32767);

    procedure output_each_line( i_function in varchar2, i_output in varchar2, i_sep in varchar2 )
    is
      v_pos pls_integer;
      v_start pls_integer := 1;
      v_length constant pls_integer := length(i_output);
      v_line varchar2(100) := null;
      v_line_no pls_integer := 1;
    begin
      loop
        v_pos := instr(i_output, i_sep, v_start);

        if v_pos > 0
        then
          print('error', '%s: %s', i_function || v_line, substr(substr(i_output, v_start, v_pos-v_start), 1, 255));
          v_start := v_pos + length(i_sep);
	  v_line_no := v_line_no + 1;
	  v_line := ' (' || v_line_no || ')';
        else
          if v_start <= v_length
          then
	    -- output the remainder of i_output
            print('error', '%s: %s', i_function || v_line, substr(substr(i_output, v_start), 1, 255));
	  end if;

	  exit;
        end if;
      end loop;
    end output_each_line;
  begin
    if v_active = 0 then return; end if;
 
    output_each_line('sqlerrm', sqlerrm, chr(10));

    begin
      execute immediate 'begin :s := dbms_utility.format_error_backtrace; end;' using out v_output;
      output_each_line('dbms_utility.format_error_backtrace', v_output, chr(10));
    exception
      when others
      then
        null;
    end;

    begin
      execute immediate 'begin :s := cg$errors.geterrors; end;' using out v_output;
      output_each_line('cg$errors.geterrors', v_output, '<br>');
    exception
      when others
      then
        null;
    end;
  end on_error;

  procedure leave_on_error
  is
  begin
    if v_active = 0 then return; end if;
 
    on_error;
    leave;
  end leave_on_error;

  function format_leave
  return varchar2
  is
  begin
    return rpad( c_indent, v_level*4, ' ' ) || '<';
  end format_leave;

  function cast_to_varchar2( i_value in boolean )
  return varchar2
  is
  begin
    if i_value then
      return 'TRUE';
    elsif not(i_value) then
      return 'FALSE';
    else
      return 'UNKNOWN';
    end if;
  end cast_to_varchar2;

  procedure print(
    i_break_point in varchar2,
    i_str in varchar2
  ) is
  begin
    print_b( i_break_point => i_break_point, i_str => i_str );
    flush;
  end print;

  procedure print_b(
    i_break_point in varchar2,
    i_str in varchar2
  ) is
  begin
    print_b( i_break_point => i_break_point, i_fmt => '%s', i_arg1 => i_str );
  end print_b;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2
  ) is
  begin
    print_b( i_break_point => i_break_point, i_fmt => i_fmt, i_arg1 => i_arg1 );
    flush;
  end print;

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2
  ) is
  begin
    if v_active = 0 then return; end if;

    v_action_table(v_action_table.COUNT+1).active := v_active;
    v_action_table(v_action_table.COUNT).module_id := c_module_id_print1;
    v_action_table(v_action_table.COUNT).break_point := i_break_point;
    v_action_table(v_action_table.COUNT).fmt := i_fmt;
    v_action_table(v_action_table.COUNT).arg1 := i_arg1;
  end print_b;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in boolean
  ) is
  begin
    print_b( i_break_point => i_break_point, i_fmt => i_fmt, i_arg1 => i_arg1 );
    flush;
  end print;

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in boolean
  ) is
  begin
    print_b( i_break_point => i_break_point, i_fmt => i_fmt, i_arg1 => cast_to_varchar2(i_arg1) );
  end print_b;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2
  ) is
  begin
    print_b(
      i_break_point => i_break_point,
      i_fmt => i_fmt,
      i_arg1 => i_arg1,
      i_arg2 => i_arg2 );
    flush;
  end print;

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2
  ) is
  begin
    if v_active = 0 then return; end if;

    v_action_table(v_action_table.COUNT+1).active := v_active;
    v_action_table(v_action_table.COUNT).module_id := c_module_id_print2;
    v_action_table(v_action_table.COUNT).break_point := i_break_point;
    v_action_table(v_action_table.COUNT).fmt := i_fmt;
    v_action_table(v_action_table.COUNT).arg1 := i_arg1;
    v_action_table(v_action_table.COUNT).arg2 := i_arg2;
  end print_b;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2
  ) is
  begin
    print_b(
      i_break_point => i_break_point,
      i_fmt => i_fmt,
      i_arg1 => i_arg1,
      i_arg2 => i_arg2,
      i_arg3 => i_arg3 );
    flush;
  end print;

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2
  ) is
  begin
    if v_active = 0 then return; end if;

    v_action_table(v_action_table.COUNT+1).active := v_active;
    v_action_table(v_action_table.COUNT).module_id := c_module_id_print3;
    v_action_table(v_action_table.COUNT).break_point := i_break_point;
    v_action_table(v_action_table.COUNT).fmt := i_fmt;
    v_action_table(v_action_table.COUNT).arg1 := i_arg1;
    v_action_table(v_action_table.COUNT).arg2 := i_arg2;
    v_action_table(v_action_table.COUNT).arg3 := i_arg3;
  end print_b;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2,
    i_arg4 in varchar2
  ) is
  begin
    print_b(
      i_break_point => i_break_point,
      i_fmt => i_fmt,
      i_arg1 => i_arg1,
      i_arg2 => i_arg2,
      i_arg3 => i_arg3,
      i_arg4 => i_arg4 );
    flush;
  end print;

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2,
    i_arg4 in varchar2
  ) is
  begin
    if v_active = 0 then return; end if;

    v_action_table(v_action_table.COUNT+1).active := v_active;
    v_action_table(v_action_table.COUNT).module_id := c_module_id_print4;
    v_action_table(v_action_table.COUNT).break_point := i_break_point;
    v_action_table(v_action_table.COUNT).fmt := i_fmt;
    v_action_table(v_action_table.COUNT).arg1 := i_arg1;
    v_action_table(v_action_table.COUNT).arg2 := i_arg2;
    v_action_table(v_action_table.COUNT).arg3 := i_arg3;
    v_action_table(v_action_table.COUNT).arg4 := i_arg4;
  end print_b;

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
    print_b(
      i_break_point => i_break_point,
      i_fmt => i_fmt,
      i_arg1 => i_arg1,
      i_arg2 => i_arg2,
      i_arg3 => i_arg3,
      i_arg4 => i_arg4,
      i_arg5 => i_arg5 );
    flush;
  end print;

  procedure print_b(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in varchar2,
    i_arg2 in varchar2,
    i_arg3 in varchar2,
    i_arg4 in varchar2,
    i_arg5 in varchar2
  ) is
  begin
    if v_active = 0 then return; end if;

    v_action_table(v_action_table.COUNT+1).active := v_active;
    v_action_table(v_action_table.COUNT).module_id := c_module_id_print5;
    v_action_table(v_action_table.COUNT).break_point := i_break_point;
    v_action_table(v_action_table.COUNT).fmt := i_fmt;
    v_action_table(v_action_table.COUNT).arg1 := i_arg1;
    v_action_table(v_action_table.COUNT).arg2 := i_arg2;
    v_action_table(v_action_table.COUNT).arg3 := i_arg3;
    v_action_table(v_action_table.COUNT).arg4 := i_arg4;
    v_action_table(v_action_table.COUNT).arg5 := i_arg5;
  end print_b;

begin
  g_active_str(0) := c_method_plsdbug;
  g_active_str(1) := c_method_dbms_output;
  g_active_str(2) := c_method_log4plsql;
end dbug;
/

show errors
