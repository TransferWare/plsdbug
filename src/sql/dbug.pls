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

  c_method_plsdbug constant method_t := 'PLSDBUG';
  c_method_dbms_output constant method_t := 'DBMS_OUTPUT';

  subtype module_name_t is varchar2(2000);

  procedure activate(
    i_method in method_t,
    i_status in boolean default true
  );

  function active(
    i_method in method_t
  )
  return boolean;

  procedure init(
    i_options in varchar2
  );

  procedure push(
    i_options in varchar2
  );

  procedure process(
    i_process in varchar2
  );

  procedure done;

  procedure pop;

  procedure enter(
    i_module in module_name_t
  );

  procedure enter_b(
    i_module in module_name_t
  );

  pragma restrict_references( enter_b, wnds );

  procedure enter(
    i_module in module_name_t,
    o_module_info out pls_integer
  );

  procedure enter_b(
    i_module in module_name_t,
    o_module_info out pls_integer
  );

  pragma restrict_references( enter_b, wnds );

  procedure leave;

  procedure leave_b;

  pragma restrict_references( leave_b, wnds );

  procedure leave(
    i_module_info in pls_integer
  );

  procedure leave_b(
    i_module_info in pls_integer
  );

  pragma restrict_references( leave_b, wnds );

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

=item activate

The activate method is used to activate or deactivate debugging by the
client. Parameters are the method of debugging and enabling/disabling that
method. Current methods are 'PLSDBUG' and 'DBMS_OUTPUT', which identify the
package to use for debugging. More than one method may be enabled, hence
output to different destinations is possible.

=item active

Is debugging active for a method?

=item init

Only for the 'PLSDBUG' method. Initialise a debugging context and set
debugging options. Should be used before any other of the following functions
is used.

=item push

Only available to keep B<dbug> compatible with older versions. Old version of
C<init>. The parameter I<i_options> is in an old format: options are separated
by a semi-colon and options modifiers (value of an option) are separated by a
comma. Example for I<i_options> 'd;t;o,myfile'.

=item process

This procedure does nothing. Only available to keep B<dbug> compatible with
older versions.

=item done

Destroy a debugging context. Only for the 'PLSDBUG' method.

=item pop

Only available to keep B<dbug> compatible with older versions. Old version of
C<done>.

=item enter, enter_b

Enter a function called I<i_module>. The parameter I<o_module_info> is
obsolete, but keeps B<dbug> compatible with older versions.

The buffered version B<enter_b> postpones its action till one of the
unbuffered functions (enter, leave, print) is called. This is useful for
debugging which have restrictions on its use (for example read/write no
database state).

=item leave, leave_b

Leave a function. This must always be called if enter was called before, even
if an exception has been raised. The parameter I<i_module_info> is obsolete,
but keeps B<dbug> compatible with older versions.

The buffered version B<leave_b> postpones its action.

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

=head2 Obsolete functions

The functions

  procedure push(
    i_options in varchar2
  );

  procedure process(
    i_process in varchar2
  );

  procedure pop;

  procedure enter(
    i_module in module_name_t,
    o_module_info out pls_integer
  );

  procedure leave(
    i_module_info in pls_integer
  );

will be removed in a future release.

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
    dbug.init( 'd;t;g' ); -- debugging, tracing and profiling
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
  c_active_plsdbug constant pls_integer := 1; /* base^0 */
  c_active_dbms_output constant pls_integer := c_active_base; /* base^1 */

  type action_t is record (
    active pls_integer,
    module_id module_id_t,
    module_name module_name_t,
    break_point varchar2(32767),
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

  v_dbug_pipe epc.pipe_name_t := 'DBUG_' || user;
  v_prev_pipe epc.pipe_name_t := NULL;

  v_dbug_ctx pls_integer := 0; /* dbug context: session specific */

  generic_error exception;

  /* local modules */

  function active(
    i_active in pls_integer
  , i_method in pls_integer
  )
  return boolean
  is
  begin
    return mod(i_active, i_method*c_active_base) >= i_method;
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
    v_pos pls_integer;
    v_prev_pos pls_integer;
    v_str varchar2(32767);
    v_arg_nr pls_integer;
    v_arg varchar2(32767);
  begin
    if v_action_table.count = 0 
    then
      return; 
    end if;

    for v_nr in v_action_table.first .. v_action_table.last
    loop
      v_action := v_action_table(v_nr);

      if active(v_action.active, c_active_plsdbug)
      then
      begin
        v_prev_pipe := epc.get_request_pipe;
        epc.set_request_pipe( v_dbug_pipe );

        if v_action.module_id = c_module_id_enter
        then
          plsdbug.plsdbug_enter( v_dbug_ctx, v_action.module_name );
        elsif v_action.module_id = c_module_id_leave
        then
          plsdbug.plsdbug_leave( v_dbug_ctx );
        elsif v_action.module_id = c_module_id_print1
        then
          plsdbug.plsdbug_print1( v_dbug_ctx, 
                              v_action.break_point,
                              v_action.fmt,
                              nvl(v_action.arg1, c_null) );
        elsif v_action.module_id = c_module_id_print2
        then
          plsdbug.plsdbug_print2( v_dbug_ctx, 
                              v_action.break_point,
                              v_action.fmt,
                              nvl(v_action.arg1, c_null),
                              nvl(v_action.arg2, c_null) );
        elsif v_action.module_id = c_module_id_print3
        then
          plsdbug.plsdbug_print3( v_dbug_ctx, 
                              v_action.break_point,
                              v_action.fmt,
                              nvl(v_action.arg1, c_null),
                              nvl(v_action.arg2, c_null),
                              nvl(v_action.arg3, c_null) );
        elsif v_action.module_id = c_module_id_print4
        then
          plsdbug.plsdbug_print4( v_dbug_ctx, 
                              v_action.break_point,
                              v_action.fmt,
                              nvl(v_action.arg1, c_null),
                              nvl(v_action.arg2, c_null),
                              nvl(v_action.arg3, c_null),
                              nvl(v_action.arg4, c_null) );
        elsif v_action.module_id = c_module_id_print5
        then
          plsdbug.plsdbug_print5( v_dbug_ctx, 
                              v_action.break_point,
                              v_action.fmt,
                              nvl(v_action.arg1, c_null),
                              nvl(v_action.arg2, c_null),
                              nvl(v_action.arg3, c_null),
                              nvl(v_action.arg4, c_null),
                              nvl(v_action.arg5, c_null) );
        end if;

        epc.set_request_pipe( v_prev_pipe );
      exception
        when others
        then 
          epc.set_request_pipe( v_prev_pipe );
          handle_error( SQLCODE, SQLERRM );
      end;
      end if;

      if active(v_action.active, c_active_dbms_output)
      then
      begin
        if v_action.module_id = c_module_id_enter
        then
          dbms_output.put_line( 
            rpad( c_indent, v_level*4, ' ' ) || '>' || v_action.module_name );
          v_level := v_level + 1;
        elsif v_action.module_id = c_module_id_leave
        then
          /* when methods are switched level should be at least 0 */
          v_level := greatest(v_level - 1, 0); 
          dbms_output.put_line( rpad( c_indent, v_level*4, ' ' ) || '<' );
        elsif v_action.module_id between c_module_id_print1 and c_module_id_print5
        then
          /* Replace printf format string %s by its arguments */

          v_pos := 1;
          v_str := v_action.fmt;
          v_arg_nr := 1;
          loop
            v_pos := instr(v_str, '%s', v_pos);

            /* stop if '%s' is not found or when the arguments have been exhausted */
            exit when v_pos = 0 or v_arg_nr > v_action.module_id - c_module_id_print1 + 1;

            if v_arg_nr = 1 then v_arg := v_action.arg1;
            elsif v_arg_nr = 2 then v_arg := v_action.arg2;
            elsif v_arg_nr = 3 then v_arg := v_action.arg3;
            elsif v_arg_nr = 4 then v_arg := v_action.arg4;
            elsif v_arg_nr = 5 then v_arg := v_action.arg5;
            else /* ?? */ v_arg := null;
            end if;
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

          /* Only print a single line every time for dbms_output (255 limit) */

          v_str :=
            rpad( c_indent, v_level*4, ' ' ) ||
            v_action.break_point ||
            ': ' ||
            v_str;

          v_prev_pos := 1;
          loop
            exit when v_prev_pos > nvl(length(v_str), 0);

            v_pos := instr(v_str, chr(10), v_prev_pos);

            if v_pos = 0
            then
              dbms_output.put_line( substr(v_str, v_prev_pos) );
              exit;
            else
              dbms_output.put_line( substr(v_str, v_prev_pos, v_pos - v_prev_pos) );
            end if;

            v_prev_pos := v_pos + 1;
          end loop;
        end if;
      exception
        when others
        then 
          handle_error( SQLCODE, SQLERRM );
      end;
      end if;
      
      v_action_table.delete(v_nr);
    end loop;
  end flush;

  /* global modules */

  procedure activate(
    i_method in method_t,
    i_status in boolean default true
  )
  is
    v_method pls_integer := null;
  begin
    if upper(i_method) like '___DBUG' -- backwards compability with TS_DBUG
    then
      v_method := c_active_plsdbug;
    elsif upper(i_method) = c_method_dbms_output
    then
      v_method := c_active_dbms_output;
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
    elsif upper(i_method) = c_method_dbms_output
    then
      return active(v_active, c_active_dbms_output);
    else
      return null;
    end if;
  end active;

  procedure init(
    i_options in varchar2
  ) is
    v_status pls_integer := 0;
  begin
    if active(v_active, c_active_plsdbug)
    then
      v_prev_pipe := epc.get_request_pipe;
      epc.set_request_pipe( v_dbug_pipe );
      v_status := plsdbug.plsdbug_init( i_options, v_dbug_ctx );
      epc.set_request_pipe( v_prev_pipe );
      if ( v_status <> 0 )
      then
        epc.set_request_pipe( v_prev_pipe );
        handle_error( SQLCODE, plsdbug.strerror(v_status) );
      end if;   
    end if;
  exception
    when others
    then 
      epc.set_request_pipe( v_prev_pipe );
      handle_error( SQLCODE, SQLERRM );
  end init;

  procedure push(
    i_options in varchar2
  ) is
    v_options varchar2(32767);
  begin
    /* replace old modifier separator , by equal sign = */
    v_options := replace( i_options, ',', '=' ); 
    /* replace old options separator : by the new one , */
    v_options := replace( v_options, ':', ',' ); 

    init( v_options );
  end push;

  procedure process(
    i_process in varchar2
  ) is
  begin
    null;
  end process;

  procedure done
  is
    v_status pls_integer := 0;
  begin
    if active(v_active, c_active_plsdbug)
    then
    begin
      v_prev_pipe := epc.get_request_pipe;
      epc.set_request_pipe( v_dbug_pipe );
      v_status := plsdbug.plsdbug_done( v_dbug_ctx );
      epc.set_request_pipe( v_prev_pipe );
      if ( v_status <> 0 )
      then
        raise generic_error;
      end if;
    exception
      when generic_error
      then 
        epc.set_request_pipe( v_prev_pipe );
        handle_error( SQLCODE, plsdbug.strerror(v_status) );
      when others
      then 
        epc.set_request_pipe( v_prev_pipe );
        handle_error( SQLCODE, SQLERRM );
    end;
    end if;
  end done;

  procedure pop 
  is
  begin
    done;
  end pop;

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

    v_action_table(v_action_table.COUNT+1).active := v_active;
    v_action_table(v_action_table.COUNT).module_id := c_module_id_enter;
    v_action_table(v_action_table.COUNT).module_name := i_module;
  end enter_b;

  procedure enter(
    i_module in module_name_t,
    o_module_info out pls_integer
  )
  is
  begin
    enter( i_module => i_module );
  end enter;

  procedure enter_b(
    i_module in module_name_t,
    o_module_info out pls_integer
  )
  is
  begin
    enter_b( i_module => i_module );
  end enter_b;

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

    v_action_table(v_action_table.COUNT+1).active := v_active;
    v_action_table(v_action_table.COUNT).module_id := c_module_id_leave;
  end leave_b;

  procedure leave(
    i_module_info in pls_integer
  )
  is
  begin
    leave;
  end leave;

  procedure leave_b(
    i_module_info in pls_integer
  )
  is
  begin
    leave_b;
  end leave_b;

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

end dbug;
/
