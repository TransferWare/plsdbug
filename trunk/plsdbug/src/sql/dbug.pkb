--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL$
REMARK

create or replace package body dbug is

  /* TYPES */

  type cursor_tabtype is table of integer index by varchar2(4000);

  /* CONSTANTS */

  c_active_base constant pls_integer := 2;

  c_indent constant char(4) := '|   ';

  c_null constant varchar2(6) := '<NULL>';

  /* VARIABLES */

  g_obj dbug_obj_t := null /*dbug_obj_t()*/;

  -- table of dbms_sql cursors
  g_cursor_tab cursor_tabtype;

  /* local modules */
  procedure set_number
  ( p_str in varchar2
  , p_num in number
    -- indexes if p_str_tab and p_num_tab must be in sync
  , p_str_tab in out nocopy sys.odcivarchar2list
  , p_num_tab in out nocopy sys.odcinumberlist
  )
  is
    l_idx pls_integer;
  begin
    if p_str_tab.count != p_num_tab.count
    then
      raise program_error;
    end if;

    l_idx := p_str_tab.first;
    loop
      exit when l_idx is null or p_str_tab(l_idx) = p_str;

      if not p_num_tab.exists(l_idx)
      then
        raise program_error;
      end if;

      l_idx := p_str_tab.next(l_idx);
    end loop;

    if l_idx is null -- not found
    then
      p_str_tab.extend(1);
      p_num_tab.extend(1);
      l_idx := p_str_tab.last;
      p_str_tab(l_idx) := p_str;
    end if;

    p_num_tab(l_idx) := p_num;
  end set_number;

  function get_number
  ( p_str in varchar2
    -- indexes if p_str_tab and p_num_tab must be in sync
  , p_str_tab in sys.odcivarchar2list
  , p_num_tab in sys.odcinumberlist
  )
  return number
  is
    l_idx pls_integer;
  begin
    if p_str_tab.count != p_num_tab.count
    then
      raise program_error;
    end if;

    l_idx := p_str_tab.first;
    loop
      exit when l_idx is null or p_str_tab(l_idx) = p_str;

      if not p_num_tab.exists(l_idx)
      then
        raise program_error;
      end if;

      l_idx := p_str_tab.next(l_idx);
    end loop;

    return case when l_idx is null then null else p_num_tab(l_idx) end;
  end get_number;

  procedure trace( p_line in varchar2 )
  is
  begin
    dbms_output.put_line(substr('TRACE: ' || p_line, 1, 255));
  end trace;

  procedure show_error( p_line in varchar2 )
  is
  begin
    dbms_output.put_line(substr('ERROR: ' || p_line, 1, 255));
  end show_error;

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

      -- dbms_sql.parse() does not like <cr> (chr(13)) and 
      -- the dynamic sql here may have as the end of line
      -- 1) <cr><lf> (Windows) or
      -- 2) <cr> (Apple) 
      -- 3) <lf> (Unix)
      -- So replace those line endings by <lf>.
      begin
        --/*TRACE*/ trace(replace(replace(p_plsql_stmt, chr(13)||chr(10), chr(10)), chr(13), chr(10)));
        dbms_sql.parse
        ( p_cursor
        , replace(replace(p_plsql_stmt, chr(13)||chr(10), chr(10)), chr(13), chr(10))
        , dbms_sql.native
        );
        g_cursor_tab(p_key) := p_cursor;
      exception
        when others -- parse error
        then
          -- show_error(sqlerrm);
          dbms_sql.close_cursor(p_cursor);
          g_cursor_tab(p_key) := null;
      end;
    end if;
  end get_cursor;

  function handle_error( 
    p_obj in dbug_obj_t,
    p_sqlcode in pls_integer, 
    p_sqlerrm in varchar2
  )
  return boolean
  is
    l_result boolean := true;

    procedure empty_dbms_output_buffer
    is
      l_lines dbms_output.chararr;
      l_numlines integer := power(2, 31); /* maximum nr of lines */
    begin
      -- clear the buffer
      dbms_output.get_lines(lines => l_lines, numlines => l_numlines);
      --/*TRACE*/ trace('number of dbms_output lines cleared: ' || to_char(l_numlines));
    end empty_dbms_output_buffer;
  begin
    if p_sqlcode = -20000 and
       instr(p_sqlerrm, 'ORU-10027:') > 0 -- dbms_output buffer overflow
    then
      case p_obj.ignore_buffer_overflow
        when 1
        then
          -- clear the buffer
          empty_dbms_output_buffer;
          show_error(p_sqlerrm);
        when 0
        then
          l_result := false;
        else /* ???? */
          raise value_error;
      end case;
    else
      begin
        show_error(p_sqlerrm);
      exception
        when others then null;
      end;
    end if;
    return l_result;
  exception
    when others
    then
      return false;
  end handle_error;

  procedure get_called_from
  ( p_latest_call out varchar2
  , p_other_calls out varchar2
  )
  is
    l_format_call_stack constant varchar2(32767) := dbms_utility.format_call_stack;
    l_pos pls_integer;
    l_start pls_integer := 1;
    l_lines_without_dbug pls_integer := null;
  begin
    loop
      l_pos := instr(l_format_call_stack, chr(10), l_start);

      exit when l_pos is null or l_pos = 0;
        
      l_lines_without_dbug := 
        case instr(substr(l_format_call_stack, l_start, l_pos-l_start), '.DBUG')
          when 0 
          then l_lines_without_dbug + 1 /* null+1 is null */
          else 0
        end;

      if l_lines_without_dbug = 2 -- the line from which the method invoking dbug is called
      then
        p_latest_call := substr(l_format_call_stack, l_start, l_pos-l_start);
        p_other_calls := substr(l_format_call_stack, l_pos+1);
        exit;
      end if;
  
      l_start := l_pos+1;
    end loop;
  end get_called_from;

  procedure pop_call_stack
  ( p_obj in out nocopy dbug_obj_t
  , p_lwb in binary_integer
  )
  is
    l_active_idx pls_integer;
    l_active_str method_t;
    l_cursor integer;
    l_dummy integer;
  begin
    -- GJP 21-04-2006 
    -- When there is a mismatch in enter/leave pairs 
    -- (for example caused by uncaught expections or program errors)
    -- we must pop from the call stack (p_obj.call_tab) all entries through
    -- the one which has the same called from location as this call.
    -- When there is no mismatch this means the top entry from p_obj.call_tab will be removed.

    if p_lwb = p_obj.call_tab.last
    then
      null;
    else
      show_error('Popping ' || to_char(p_obj.call_tab.last - p_lwb) || ' missing dbug.leave calls');
    end if;

    while p_obj.call_tab.last >= p_lwb
    loop
      -- [ 1677186 ] Enter/leave pairs are not displayed correctly
      -- The level should be increased/decreased only once no matter how many methods are active.
      -- Decrement must take place before the leave.
      p_obj.indent_level := greatest(p_obj.indent_level - 1, 0);

      l_active_idx := p_obj.active_num_tab.first;
      while l_active_idx is not null
      loop
        l_active_str := p_obj.active_str_tab(l_active_idx);

        if p_obj.active_num_tab(l_active_idx) = 0
        then
          null;
        else
          begin
            get_cursor
            ( 'dbug_'||l_active_str||'.leave'
            , 'begin dbug_'||l_active_str||'.leave; end;'
            , l_cursor
            );
            l_dummy := dbms_sql.execute(l_cursor);
          exception
            when others
            then 
              if not handle_error(p_obj, sqlcode, sqlerrm)
              then
                raise;
              end if;
          end;
        end if;

        l_active_idx := p_obj.active_num_tab.next(l_active_idx);
      end loop;

      -- pop the call stack each time so format_leave can print the module name
      p_obj.call_tab.trim(1);
    end loop;

    p_obj.dirty := 1;
  end pop_call_stack;
  
  procedure done
  ( p_obj in dbug_obj_t
  )
  is
    l_idx pls_integer;
    l_active_str method_t;
    l_cursor integer;
    l_dummy binary_integer;
  begin
    l_idx := p_obj.active_num_tab.first;

    loop
      exit when l_active_str is null;
 
      l_active_str := p_obj.active_str_tab(l_idx);

      if p_obj.active_num_tab(l_idx) = 1
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

      l_idx := p_obj.active_num_tab.next(l_idx);
    end loop;
  end done;

  procedure activate
  ( p_obj in out nocopy dbug_obj_t
  , p_method in method_t
  , p_status in boolean
  )
  is
    l_method method_t;
  begin
    --/*TRACE*/ trace('>activate('''||p_method||''', '||cast_to_varchar2(p_status)||')');

    if upper(p_method) = 'TS_DBUG' -- backwards compability with TS_DBUG
    then
      l_method := c_method_plsdbug;
    else
      l_method := p_method;
    end if;

    select  lower(l_method)
    into    l_method
    from    user_objects obj
    where   obj.object_type = 'PACKAGE BODY'
    and     obj.object_name = 'DBUG_' || upper(l_method);

    set_number
    ( p_str => l_method
    , p_num => case p_status when true then 1 when false then 0 else null end
    , p_str_tab => p_obj.active_str_tab
    , p_num_tab => p_obj.active_num_tab
    );

    p_obj.dirty := 1;

    --/*TRACE*/ trace('<activate');
  end activate;

  function active
  ( p_obj in dbug_obj_t
  , p_method in method_t
  )
  return boolean
  is
    l_method method_t;
  begin
    if upper(p_method) = 'TS_DBUG' -- backwards compability with TS_DBUG
    then
      l_method := lower(c_method_plsdbug);
    else
      l_method := lower(p_method);
    end if;

    return
      case get_number
           ( p_str => l_method
           , p_str_tab => p_obj.active_str_tab
           , p_num_tab => p_obj.active_num_tab
           )
        when 1
        then true
        when 0 
        then false
        else null
      end;
  end active;

  procedure set_level
  ( p_obj in out nocopy dbug_obj_t
  , p_level in level_t
  )
  is
  begin
    if p_obj.call_tab.count != 0
    then
      raise program_error;
    end if;

    if p_level between c_level_all and c_level_off
    then
      p_obj.dbug_level := p_level;
      p_obj.dirty := 1;
    else
      raise value_error;
    end if;
  end set_level;

  function get_level
  ( p_obj in dbug_obj_t
  )
  return level_t
  is
  begin
    return p_obj.dbug_level;
  end get_level;

  procedure set_break_point_level
  ( p_obj in out nocopy dbug_obj_t
  , p_break_point_level_tab in break_point_level_t
  )
  is
    l_break_point break_point_t := p_break_point_level_tab.first;
  begin
    if p_obj.call_tab.count != 0
    then
      raise program_error;
    end if;

    while l_break_point is not null
    loop
      if p_break_point_level_tab(l_break_point) between c_level_debug and c_level_fatal
      then
        null;
      else
        raise value_error;
      end if;
 
      set_number
      ( p_str => l_break_point
      , p_num => p_break_point_level_tab(l_break_point)
      , p_str_tab => p_obj.break_point_level_str_tab
      , p_num_tab => p_obj.break_point_level_num_tab
      );
      p_obj.dirty := 1;

      l_break_point := p_break_point_level_tab.next(l_break_point);
    end loop;
  end set_break_point_level;

  function get_break_point_level
  ( p_obj in dbug_obj_t
  )
  return break_point_level_t
  is
    l_idx pls_integer := p_obj.break_point_level_str_tab.first;
    l_break_point_level_tab break_point_level_t;
  begin
    while l_idx is not null
    loop
      l_break_point_level_tab(p_obj.break_point_level_str_tab(l_idx)) :=
        p_obj.break_point_level_num_tab(l_idx);

      l_idx := p_obj.break_point_level_str_tab.next(l_idx);
    end loop;

    return l_break_point_level_tab;
  end get_break_point_level;

  function check_break_point
  ( p_obj in dbug_obj_t
  , p_break_point in varchar2
  )
  return boolean
  is
    l_level level_t;
  begin
    if p_obj.active_num_tab.count = 0
    then 
      return false;
    else
      l_level :=
        nvl
        (
          get_number
          ( p_str => p_break_point
          , p_str_tab => p_obj.break_point_level_str_tab
          , p_num_tab => p_obj.break_point_level_num_tab
          )
        , c_level_default
        );
      if l_level < p_obj.dbug_level
      then
        return false;
      end if;
    end if;
    return true;
  end check_break_point;

  procedure enter
  ( p_obj in out nocopy dbug_obj_t
  , p_module in module_name_t
  )
  is
    l_idx pls_integer;
    l_active_str method_t;
    l_cursor integer;
    l_dummy integer;
  begin
    if not check_break_point(p_obj, "trace")
    then
      return;
    end if;

    -- GJP 21-04-2006 Store the location from which dbug.enter is called
    declare
      l_idx constant pls_integer := p_obj.call_tab.count + 1;
      l_other_calls varchar2(32767);
      l_call dbug_call_obj_t;
    begin
       p_obj.call_tab.extend(1);
       p_obj.call_tab(l_idx) := dbug_call_obj_t(p_module, null, null);
       -- only the first other_calls has to be stored, so use a variable for l_idx > 1
       if l_idx = 1
       then
         get_called_from(p_obj.call_tab(l_idx).called_from, p_obj.call_tab(l_idx).other_calls);
       else
         get_called_from(p_obj.call_tab(l_idx).called_from, l_other_calls);

         -- Same stack?
         -- See =head2 Restarting a PL/SQL block with dbug.leave calls missing due to an exception
         if ( p_obj.call_tab(p_obj.call_tab.first).module_name = p_module and
              nvl(p_obj.call_tab(p_obj.call_tab.first).called_from, 'X') = nvl(p_obj.call_tab(l_idx).called_from, 'X') and
              nvl(p_obj.call_tab(p_obj.call_tab.first).other_calls, 'X') = nvl(l_other_calls, 'X') )
         then
           show_error
           ( 'Module name and other calls equal to the first one '
             ||'while the dbug call stack count is '
             ||p_obj.call_tab.count
           );

           -- this is probably a situation where an outermost PL/SQL block
           -- is called for another time and where the previous time did not
           -- not have all dbug.enter calls matched by a dbug.leave.

           -- save the called_from info before destroying p_obj.call_tab
           l_call := p_obj.call_tab(l_idx);

           p_obj.call_tab.trim; -- this one is moved to nr 1
           pop_call_stack(p_obj, 1); -- erase the complete stack (except index 0)
           p_obj.call_tab.extend(1);
           p_obj.call_tab(1) := l_call;
           p_obj.call_tab(1).other_calls := l_other_calls;
         end if;
       end if;
    end;

    l_idx := p_obj.active_num_tab.first;
    while l_idx is not null
    loop
      l_active_str := p_obj.active_str_tab(l_idx);

      if p_obj.active_num_tab(l_idx) = 0
      then
        null;
      else
        begin
          get_cursor
          ( 'dbug_'||l_active_str||'.enter'
          , 'begin dbug_'||l_active_str||'.enter(:0); end;'
          , l_cursor
          );
          dbms_sql.bind_variable(l_cursor, '0', p_module);
          l_dummy := dbms_sql.execute(l_cursor);
        exception
          when others
          then 
            if not handle_error(p_obj, sqlcode, sqlerrm)
            then
              raise;
            end if;
        end;
      end if;

      l_idx := p_obj.active_num_tab.next(l_idx);
    end loop;

    -- [ 1677186 ] Enter/leave pairs are not displayed correctly
    -- Increment after all actions have been done.
    p_obj.indent_level := p_obj.indent_level + 1;
    p_obj.dirty := 1;
  end enter;

  procedure print
  ( p_obj in dbug_obj_t
  , p_break_point in varchar2
  , p_fmt in varchar2
  , p_arg1 in varchar2
  )
  is
    l_idx pls_integer;
    l_active_str method_t;
    l_cursor integer;
    l_dummy integer;
  begin
    if not check_break_point(p_obj, p_break_point)
    then
      return;
    end if;

    l_idx := p_obj.active_num_tab.first;
    while l_idx is not null
    loop
      l_active_str := p_obj.active_str_tab(l_idx);

      if p_obj.active_num_tab(l_idx) = 0
      then
        null;
      else
        begin
          get_cursor
          ( 'dbug_'||l_active_str||'.print1'
          , 'begin dbug_'||l_active_str||'.print(:0, :1, :2); end;'
          , l_cursor
          );
          dbms_sql.bind_variable(l_cursor, '0', p_break_point);
          dbms_sql.bind_variable(l_cursor, '1', p_fmt);
          dbms_sql.bind_variable(l_cursor, '2', nvl(p_arg1, c_null));
          l_dummy := dbms_sql.execute(l_cursor);
        exception
          when others
          then 
            if not handle_error(p_obj, sqlcode, sqlerrm)
            then
              raise;
            end if;
        end;
      end if;

      l_idx := p_obj.active_num_tab.next(l_idx);
    end loop;
  end print;

  procedure print
  ( p_obj in dbug_obj_t
  , p_break_point in varchar2
  , p_fmt in varchar2
  , p_arg1 in varchar2
  , p_arg2 in varchar2
  )
  is
    l_idx pls_integer;
    l_active_str method_t;
    l_cursor integer;
    l_dummy integer;
  begin
    if not check_break_point(p_obj, p_break_point)
    then
      return;
    end if;

    l_idx := p_obj.active_num_tab.first;
    while l_idx is not null
    loop
      l_active_str := p_obj.active_str_tab(l_idx);

      if p_obj.active_num_tab(l_idx) = 0
      then
        null;
      else
        begin
          get_cursor
          ( 'dbug_'||l_active_str||'.print2'
          , 'begin dbug_'||l_active_str||'.print(:0, :1, :2, :3); end;'
          , l_cursor
          );
          dbms_sql.bind_variable(l_cursor, '0', p_break_point);
          dbms_sql.bind_variable(l_cursor, '1', p_fmt);
          dbms_sql.bind_variable(l_cursor, '2', nvl(p_arg1, c_null));
          dbms_sql.bind_variable(l_cursor, '3', nvl(p_arg2, c_null));
          l_dummy := dbms_sql.execute(l_cursor);
        exception
          when others
          then 
            if not handle_error(p_obj, sqlcode, sqlerrm)
            then
              raise;
            end if;
        end;
      end if;

      l_idx := p_obj.active_num_tab.next(l_idx);
    end loop;
  end print;

  procedure print
  ( p_obj in dbug_obj_t
  , p_break_point in varchar2
  , p_fmt in varchar2
  , p_arg1 in varchar2
  , p_arg2 in varchar2
  , p_arg3 in varchar2
  )
  is
    l_idx pls_integer;
    l_active_str method_t;
    l_cursor integer;
    l_dummy integer;
  begin
    if not check_break_point(p_obj, p_break_point)
    then
      return;
    end if;

    l_idx := p_obj.active_num_tab.first;
    while l_idx is not null
    loop
      l_active_str := p_obj.active_str_tab(l_idx);

      if p_obj.active_num_tab(l_idx) = 0
      then
        null;
      else
        begin
          get_cursor
          ( 'dbug_'||l_active_str||'.print3'
          , 'begin dbug_'||l_active_str||'.print(:0, :1, :2, :3, :4); end;'
          , l_cursor
          );
          dbms_sql.bind_variable(l_cursor, '0', p_break_point);
          dbms_sql.bind_variable(l_cursor, '1', p_fmt);
          dbms_sql.bind_variable(l_cursor, '2', nvl(p_arg1, c_null));
          dbms_sql.bind_variable(l_cursor, '3', nvl(p_arg2, c_null));
          dbms_sql.bind_variable(l_cursor, '4', nvl(p_arg3, c_null));
          l_dummy := dbms_sql.execute(l_cursor);
        exception
          when others
          then 
            if not handle_error(p_obj, sqlcode, sqlerrm)
            then
              raise;
            end if;
        end;
      end if;

      l_idx := p_obj.active_num_tab.next(l_idx);
    end loop;
  end print;

  procedure print
  ( p_obj in dbug_obj_t
  , p_break_point in varchar2
  , p_fmt in varchar2
  , p_arg1 in varchar2
  , p_arg2 in varchar2
  , p_arg3 in varchar2
  , p_arg4 in varchar2
  )
  is
    l_idx pls_integer;
    l_active_str method_t;
    l_cursor integer;
    l_dummy integer;
  begin
    if not check_break_point(p_obj, p_break_point)
    then
      return;
    end if;

    l_idx := p_obj.active_num_tab.first;
    while l_idx is not null
    loop
      l_active_str := p_obj.active_str_tab(l_idx);

      if p_obj.active_num_tab(l_idx) = 0
      then
        null;
      else
        begin
          get_cursor
          ( 'dbug_'||l_active_str||'.print4'
          , 'begin dbug_'||l_active_str||'.print(:0, :1, :2, :3, :4, :5); end;'
          , l_cursor
          );
          dbms_sql.bind_variable(l_cursor, '0', p_break_point);
          dbms_sql.bind_variable(l_cursor, '1', p_fmt);
          dbms_sql.bind_variable(l_cursor, '2', nvl(p_arg1, c_null));
          dbms_sql.bind_variable(l_cursor, '3', nvl(p_arg2, c_null));
          dbms_sql.bind_variable(l_cursor, '4', nvl(p_arg3, c_null));
          dbms_sql.bind_variable(l_cursor, '5', nvl(p_arg4, c_null));
          l_dummy := dbms_sql.execute(l_cursor);
        exception
          when others
          then 
            if not handle_error(p_obj, sqlcode, sqlerrm)
            then
              raise;
            end if;
        end;
      end if;

      l_idx := p_obj.active_num_tab.next(l_idx);
    end loop;
  end print;

  procedure print
  ( p_obj in dbug_obj_t
  , p_break_point in varchar2
  , p_fmt in varchar2
  , p_arg1 in varchar2
  , p_arg2 in varchar2
  , p_arg3 in varchar2
  , p_arg4 in varchar2
  , p_arg5 in varchar2
  )
  is
    l_idx pls_integer;
    l_active_str method_t;
    l_cursor integer;
    l_dummy integer;
  begin
    if not check_break_point(p_obj, p_break_point)
    then
      return;
    end if;

    l_idx := p_obj.active_num_tab.first;
    while l_idx is not null
    loop
      l_active_str := p_obj.active_str_tab(l_idx);

      if p_obj.active_num_tab(l_idx) = 0
      then
        null;
      else
        begin
          get_cursor
          ( 'dbug_'||l_active_str||'.print5'
          , 'begin dbug_'||l_active_str||'.print(:0, :1, :2, :3, :4, :5, :6); end;'
          , l_cursor
          );
          dbms_sql.bind_variable(l_cursor, '0', p_break_point);
          dbms_sql.bind_variable(l_cursor, '1', p_fmt);
          dbms_sql.bind_variable(l_cursor, '2', nvl(p_arg1, c_null));
          dbms_sql.bind_variable(l_cursor, '3', nvl(p_arg2, c_null));
          dbms_sql.bind_variable(l_cursor, '4', nvl(p_arg3, c_null));
          dbms_sql.bind_variable(l_cursor, '5', nvl(p_arg4, c_null));
          dbms_sql.bind_variable(l_cursor, '6', nvl(p_arg5, c_null));
          l_dummy := dbms_sql.execute(l_cursor);
        exception
          when others
          then 
            if not handle_error(p_obj, sqlcode, sqlerrm)
            then
              raise;
            end if;
        end;
      end if;

      l_idx := p_obj.active_num_tab.next(l_idx);
    end loop;
  end print;

  procedure leave
  ( p_obj in out nocopy dbug_obj_t
  )
  is
  begin
    if not check_break_point(p_obj, "trace")
    then
      return;
    end if;

    -- GJP 21-04-2006 
    -- When there is a mismatch in enter/leave pairs 
    -- (for example caused by uncaught expections or program errors)
    -- we must pop from the call stack (p_obj.call_tab) all entries through
    -- the one which has the same called from location as this call.
    -- When there is no mismatch this means the top entry from p_obj.call_tab will be removed.
    -- See also get_called_from for an example.

    declare
      l_called_from varchar2(32767);
      l_other_calls_dummy varchar2(32767);
      l_idx pls_integer := p_obj.call_tab.last;
    begin
       get_called_from(l_called_from, l_other_calls_dummy);

      -- adjust for mismatch in enter/leave pairs
      loop
        if l_idx is null
        then
          -- called_from location for leave does not exist in p_obj.call_tab
          raise program_error;
        elsif nvl(p_obj.call_tab(l_idx).called_from, 'X') = nvl(l_called_from, 'X')
        then
          pop_call_stack(p_obj, l_idx);
          exit;
        else
          l_idx := p_obj.call_tab.prior(l_idx);
        end if;
      end loop;
    end;
  end leave;

  procedure on_error
  ( p_obj in dbug_obj_t
  , p_function in varchar2
  , p_output in dbug.line_tab_t
  )
  is
    l_line varchar2(100) := null;
    l_line_no pls_integer;
    l_level level_t;
  begin
    --/*TRACE*/ trace('>on_error('''||p_function||''', '||p_output.count||')');

    if not check_break_point(p_obj, "error")
    then
      return;
    end if;
 
    l_line_no := p_output.first;
    l_line := case when p_output.count > 1 then ' (' || l_line_no || ')' else null end;
    while l_line_no is not null
    loop
      print(p_obj, "error", '%s: %s', p_function || l_line, p_output(l_line_no));
      l_line_no := p_output.next(l_line_no);
      l_line := ' (' || l_line_no || ')';
    end loop;

    --/*TRACE*/ trace('<on_error');
  end on_error;

  procedure on_error
  ( p_obj in dbug_obj_t
  , p_function in varchar2
  , p_output in varchar2
  , p_sep in varchar2
  )
  is
    l_line_tab line_tab_t;
  begin
    split(p_output, p_sep, l_line_tab);

    dbug.on_error(p_obj, p_function, l_line_tab);
  end on_error;

  procedure get_state
  is
  begin
    --/*TRACE*/ trace('>get_state');
    if g_obj is not null
    then
      raise program_error;
    end if;
    g_obj := new dbug_obj_t();
    --/*TRACE*/ g_obj.print();
    --/*TRACE*/ trace('<get_state');
  end get_state;

  procedure set_state(p_store in boolean default true, p_print in boolean default false)
  is
  begin
    --/*TRACE*/ trace('>set_state');
    if p_store
    then
      g_obj.store();
    end if;
    if p_print
    then
      g_obj.print();
    end if;
    g_obj := null;
    --/*TRACE*/ trace('<set_state');
  end set_state;

  /* global modules */

  procedure done
  is
  begin
    --/*TRACE*/ trace('>done');
    get_state;
    begin
      done(g_obj);
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);
    --/*TRACE*/ trace('<done');
  end done;

  procedure activate
  ( p_method in method_t
  , p_status in boolean
  )
  is
  begin
    --/*TRACE*/ trace('>activate');
    get_state;
    begin
      activate(g_obj, p_method, p_status);
    exception
      when others
      then
        set_state(p_store => true, p_print => true);
        raise;
    end;
    set_state(p_store => true);
    --/*TRACE*/ trace('<activate');
  end activate;

  function active
  ( p_method in method_t
  )
  return boolean
  is
    l_result boolean;
  begin
    --/*TRACE*/ trace('>active');
    get_state;
    begin
      l_result := active(g_obj, p_method);
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);

    --/*TRACE*/ trace('<active');

    return l_result;
  end active;

  procedure set_level
  ( p_level in level_t
  )
  is
  begin
    --/*TRACE*/ trace('>set_level');
    get_state;
    begin
      set_level(g_obj, p_level);
    exception
      when others
      then
        set_state(p_store => true, p_print => true);
        raise;
    end;
    set_state(p_store => true);
    --/*TRACE*/ trace('<set_level');
  end set_level;

  function get_level
  return level_t
  is
    l_result level_t;
  begin
    --/*TRACE*/ trace('>get_level');
    get_state;
    begin
      l_result := get_level(g_obj);
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);
    --/*TRACE*/ trace('<get_level');
    return l_result;
  end get_level;

  procedure set_break_point_level
  ( p_break_point_level_tab in break_point_level_t
  )
  is
  begin
    --/*TRACE*/ trace('>set_break_point_level');
    get_state;
    begin
      set_break_point_level(g_obj, p_break_point_level_tab);
    exception
      when others
      then
        set_state(p_store => true, p_print => true);
        raise;
    end;
    set_state(p_store => true);
    --/*TRACE*/ trace('<set_break_point_level');
  end set_break_point_level;

  function get_break_point_level
  return break_point_level_t
  is
    l_result break_point_level_t;
  begin
    --/*TRACE*/ trace('>get_break_point_level');
    get_state;
    begin
      l_result := get_break_point_level(g_obj);
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);
    --/*TRACE*/ trace('<get_break_point_level');
    return l_result;
  end get_break_point_level;

  procedure enter
  ( p_module in module_name_t
  )
  is
  begin
    --/*TRACE*/ trace('>enter');
    get_state;
    begin
      enter(g_obj, p_module);
    exception
      when others
      then
        set_state(p_store => true, p_print => false);
        raise;
    end;
    set_state(p_store => true);
    --/*TRACE*/ trace('<enter');
  end enter;

  procedure leave
  is
  begin
    --/*TRACE*/ trace('>leave');
    get_state;
    begin
      leave(g_obj);
    exception
      when others
      then
        set_state(p_store => true, p_print => false);
        raise;
    end;
    set_state(p_store => true);
    --/*TRACE*/ trace('<leave');
  end leave;

  procedure on_error
  is
    l_cursor integer;
    l_dummy integer;
  begin
    dbug.on_error('sqlerrm', sqlerrm, chr(10));

    for i_nr in 1..2
    loop
      begin
        if i_nr = 1
        then
          get_cursor
          ( 'dbms_utility.format_error_backtrace'
          , q'[
begin
  dbug.on_error('dbms_utility.format_error_backtrace', dbms_utility.format_error_backtrace, chr(10));
end;]'
          , l_cursor
          );
        else
          get_cursor
          ( 'cg$errors.geterrors'
          , q'[
declare
  l_message_tab hil_message.message_tabtype;
  l_message_count number;
  l_raise_error boolean;
  l_line_tab dbug.line_tab_t;
begin
  cg$errors.get_error_messages
  ( p_message_rectype_tbl=> l_message_tab 
  , p_message_count => l_message_count 
  , p_raise_error => l_raise_error
  );

  if l_message_tab.count > 0
  then
    for i_idx in reverse l_message_tab.first .. l_message_tab.last
    loop
      l_line_tab(l_line_tab.count+1) :=
        cg$errors.get_display_string
        ( p_msg_code => l_message_tab(i_idx).msg_code
        , p_msg_text => l_message_tab(i_idx).msg_text
        , p_msg_type => l_message_tab(i_idx).severity
        );

      -- reconstruct the error stack
      cg$errors.push(l_message_tab(i_idx));
    end loop;
  end if;

  dbug.on_error('cg$errors.geterrors', l_line_tab);
end;]'
          , l_cursor
          );
        end if;

        if l_cursor is not null
        then
          l_dummy := dbms_sql.execute(l_cursor);
        end if;
      exception
        when others
        then
          show_error(sqlerrm);
      end;
    end loop;
  end on_error;

  procedure on_error
  ( p_function in varchar2
  , p_output in varchar2
  , p_sep in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>on_error');
    get_state;
    begin
      on_error
      ( g_obj
      , p_function
      , p_output
      , p_sep
      );
    exception
      when others
      then
        set_state(p_store => false, p_print => false);
        raise;
    end;
    set_state(p_store => false);
    --/*TRACE*/ trace('<on_error');
  end on_error;

  procedure on_error
  ( p_function in varchar2
  , p_output in dbug.line_tab_t
  )
  is
  begin
    --/*TRACE*/ trace('>on_error');
    get_state;
    begin
      on_error(g_obj, p_function, p_output);
    exception
      when others
      then
        set_state(p_store => false, p_print => false);
        raise;
    end;
    set_state(p_store => false);
    --/*TRACE*/ trace('<on_error');
  end on_error;

  procedure leave_on_error
  is
  begin
    --/*TRACE*/ trace('>leave_on_error');
    /* since on_error dynamically calls one of the global on_error routines we can not use an object */
    on_error;
    leave;
    --/*TRACE*/ trace('<leave_on_error');
  end leave_on_error;

  function cast_to_varchar2( p_value in boolean )
  return varchar2
  is
  begin
    if p_value then
      return 'TRUE';
    elsif not(p_value) then
      return 'FALSE';
    else
      return 'UNKNOWN';
    end if;
  end cast_to_varchar2;

  procedure print
  ( p_break_point in varchar2
  , p_str in varchar2
  ) is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(p_obj => g_obj, p_break_point => p_break_point, p_fmt => '%s', p_arg1 => p_str); 
    exception
      when others
      then
        set_state(p_store => false, p_print => false);
        raise;
    end;
    set_state(p_store => false);
    --/*TRACE*/ trace('<print');
  end print;

  procedure print
  ( p_break_point in varchar2
  , p_fmt in varchar2
  , p_arg1 in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(g_obj, p_break_point, p_fmt, p_arg1);
    exception
      when others
      then
        set_state(p_store => false, p_print => false);
        raise;
    end;
    set_state(p_store => false);
    --/*TRACE*/ trace('<print');
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in date
  ) is
  begin
    print
    ( p_break_point => p_break_point
    , p_fmt => p_fmt
    , p_arg1 => to_char(p_arg1, 'YYYYMMDDHH24MISS')
    );
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in boolean
  ) is
  begin
    print
    ( p_break_point => p_break_point
    , p_fmt => p_fmt
    , p_arg1 => cast_to_varchar2(p_arg1)
    );
  end print;

  procedure print
  ( p_break_point in varchar2
  , p_fmt in varchar2
  , p_arg1 in varchar2
  , p_arg2 in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(g_obj, p_break_point, p_fmt, p_arg1, p_arg2);
    exception
      when others
      then
        set_state(p_store => false, p_print => false);
        raise;
    end;
    set_state(p_store => false);
    --/*TRACE*/ trace('<print');
  end print;

  procedure print
  ( p_break_point in varchar2
  , p_fmt in varchar2
  , p_arg1 in varchar2
  , p_arg2 in varchar2
  , p_arg3 in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(g_obj, p_break_point, p_fmt, p_arg1, p_arg2, p_arg3);
    exception
      when others
      then
        set_state(p_store => false, p_print => false);
        raise;
    end;
    set_state(p_store => false);
    --/*TRACE*/ trace('<print');
  end print;

  procedure print
  ( p_break_point in varchar2
  , p_fmt in varchar2
  , p_arg1 in varchar2
  , p_arg2 in varchar2
  , p_arg3 in varchar2
  , p_arg4 in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(g_obj, p_break_point, p_fmt, p_arg1, p_arg2, p_arg3, p_arg4);
    exception
      when others
      then
        set_state(p_store => false, p_print => false);
        raise;
    end;
    set_state(p_store => false);
    --/*TRACE*/ trace('<print');
  end print;

  procedure print
  ( p_break_point in varchar2
  , p_fmt in varchar2
  , p_arg1 in varchar2
  , p_arg2 in varchar2
  , p_arg3 in varchar2
  , p_arg4 in varchar2
  , p_arg5 in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(g_obj, p_break_point, p_fmt, p_arg1, p_arg2, p_arg3, p_arg4, p_arg5);
    exception
      when others
      then
        set_state(p_store => false, p_print => false);
        raise;
    end;
    set_state(p_store => false);
    --/*TRACE*/ trace('<print');
  end print;

  procedure split(
    p_buf in varchar2
  , p_sep in varchar2
  , p_line_tab out nocopy line_tab_t
  )
  is
    l_pos pls_integer;
    l_prev_pos pls_integer := 1;
    l_length constant pls_integer := nvl(length(p_buf), 0);
  begin
    loop
      exit when l_prev_pos > l_length;

      l_pos := instr(p_buf, p_sep, l_prev_pos);

      if l_pos is null -- p_sep null?
      then
        exit;
      elsif l_pos = 0
      then
        p_line_tab(p_line_tab.count+1) := substr(p_buf, l_prev_pos);
        exit;
      else
        p_line_tab(p_line_tab.count+1) := substr(p_buf, l_prev_pos, l_pos - l_prev_pos);
      end if;

      l_prev_pos := l_pos + length(p_sep);
    end loop;
  end split;

  procedure set_ignore_buffer_overflow(
    p_value in boolean
  )
  is
  begin
    get_state;
    begin
      g_obj.ignore_buffer_overflow := case p_value when true then 1 when false then 0 else null end;
      g_obj.dirty := 1;
    exception
      when others
      then
        set_state(p_store => true, p_print => true);
        raise;
    end;
    set_state(p_store => true);
  end set_ignore_buffer_overflow;

  function get_ignore_buffer_overflow
  return boolean
  is
    l_result boolean := false;
  begin
    get_state;
    begin
      l_result := case g_obj.ignore_buffer_overflow when 1 then true when 0 then false else null end;
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);

    return l_result;
  end get_ignore_buffer_overflow;

  function format_enter(
    p_module in module_name_t
  )
  return varchar2
  is
  begin
    -- g_obj must have been set by one of the enter/leave/print routines
    return rpad( c_indent, g_obj.indent_level*length(c_indent), c_indent ) || '>' || p_module;
  end format_enter;

  function format_leave
  return varchar2
  is
  begin
    -- g_obj must have been set by one of the enter/leave/print routines.
    -- pop_call_stack will maintain the right call_tab even though some leaves have been issing.
    return rpad( c_indent, g_obj.indent_level*length(c_indent), c_indent ) || '<' || g_obj.call_tab(g_obj.call_tab.last).module_name;
  end format_leave;

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
  return varchar2
  is
    l_pos pls_integer;
    l_arg varchar2(32767);
    l_str varchar2(32767);
    l_arg_nr pls_integer;
  begin
    -- g_obj must have been set by one of the enter/leave/print routines
    l_pos := 1;
    l_str := p_fmt;
    l_arg_nr := 1;
    loop
      l_pos := instr(l_str, '%s', l_pos);

      /* stop if '%s' is not found or when the arguments have been exhausted */
      exit when l_pos is null or l_pos = 0 or l_arg_nr > p_nr_arg;

      l_arg := 
        case l_arg_nr
          when 1 then p_arg1
          when 2 then p_arg2
          when 3 then p_arg3
          when 4 then p_arg4
          when 5 then p_arg5
        end;

      if l_arg is null then l_arg := c_null; end if;

      /* '%s' is two characters long so replace substr from 1 till l_pos+1 */
      l_str := 
        replace( substr(l_str, 1, l_pos+1), '%s', l_arg ) ||
        substr( l_str, l_pos+2 );

      /* '%s' is replaced  by l_arg hence continue at position after
         substituted string */
      l_pos := l_pos + 1 + nvl(length(l_arg), 0) - 2 /* '%s' */;
      l_arg_nr := l_arg_nr + 1;
    end loop;

    l_str :=
      rpad( c_indent, g_obj.indent_level*length(c_indent), c_indent ) ||
      p_break_point ||
      ': ' ||
      l_str;

    return l_str;
  end format_print;

begin
  /* Invoke procedure DBUG_INIT if any */
  declare
    l_found pls_integer;
    l_dbug_init constant user_objects.object_name%type := 'DBUG_INIT';
  begin
    select  1
    into    l_found
    from    user_objects
    where   object_name = l_dbug_init
    and     object_type = 'PROCEDURE';

    execute immediate 'begin ' || l_dbug_init || '; end;';
  exception
    when no_data_found
    then
      null;
  end;
end dbug;
/

show errors

@@dbug_verify "dbug" "package body"
