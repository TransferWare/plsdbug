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

  procedure trace( i_line in varchar2 )
  is
  begin
    dbms_output.put_line(substr('TRACE: ' || i_line, 1, 255));
  end trace;

  procedure show_error( i_line in varchar2 )
  is
  begin
    dbms_output.put_line(substr('ERROR: ' || i_line, 1, 255));
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

  procedure pop_call_stack
  ( p_obj in out nocopy dbug_obj_t
  , i_lwb in binary_integer
  )
  is
    l_idx pls_integer;
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

    if i_lwb = p_obj.call_tab.last
    then
      null;
    else
      show_error('Popping ' || to_char(p_obj.call_tab.last - i_lwb) || ' missing dbug.leave calls');
    end if;

    for i_idx in reverse i_lwb .. p_obj.call_tab.last
    loop
      -- [ 1677186 ] Enter/leave pairs are not displayed correctly
      -- The level should be increased/decreased only once no matter how many methods are active.
      -- Decrement must take place before the leave.
      p_obj.indent_level := greatest(p_obj.indent_level - 1, 0);

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
            ( 'dbug_'||l_active_str||'.leave'
            , 'begin dbug_'||l_active_str||'.leave; end;'
            , l_cursor
            );
            l_dummy := dbms_sql.execute(l_cursor);
          exception
            when others
            then 
              handle_error( SQLCODE, SQLERRM );
          end;
        end if;

        l_idx := p_obj.active_num_tab.next(l_idx);
      end loop;
    end loop;

    p_obj.call_tab.trim(p_obj.call_tab.last - i_lwb + 1);
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
  , i_method in method_t
  , i_status in boolean
  )
  is
    v_method method_t;
  begin
    --/*TRACE*/ trace('>activate('||i_method||';'||case when i_status then 'TRUE' else 'FALSE' end||')');

    if upper(i_method) = 'TS_DBUG' -- backwards compability with TS_DBUG
    then
      v_method := c_method_plsdbug;
    else
      v_method := i_method;
    end if;

    select  lower(v_method)
    into    v_method
    from    user_objects obj
    where   obj.object_type = 'PACKAGE BODY'
    and     obj.object_name = 'DBUG_' || upper(v_method);

    --/*TRACE*/ trace('v_method: '||v_method);
    set_number
    ( p_str => v_method
    , p_num => case i_status when true then 1 else 0 end
    , p_str_tab => p_obj.active_str_tab
    , p_num_tab => p_obj.active_num_tab
    );

    p_obj.dirty := 1;

    --/*TRACE*/ trace('<activate');
  end activate;

  function active
  ( p_obj in dbug_obj_t
  , i_method in method_t
  )
  return boolean
  is
    v_method method_t;
  begin
    if upper(i_method) = 'TS_DBUG' -- backwards compability with TS_DBUG
    then
      v_method := lower(c_method_plsdbug);
    else
      v_method := lower(i_method);
    end if;

    return
      case get_number
           ( p_str => v_method
           , p_str_tab => p_obj.active_str_tab
           , p_num_tab => p_obj.active_num_tab
           )
        when 1 then true
        else false
      end;
  end active;

  procedure set_level
  ( p_obj in out nocopy dbug_obj_t
  , i_level in level_t
  )
  is
  begin
    if p_obj.call_tab.count != 0
    then
      raise program_error;
    end if;

    if i_level between c_level_all and c_level_off
    then
      p_obj.dbug_level := i_level;
      p_obj.dirty := 1;
    else
      raise value_error;
    end if;
  end;

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
  , i_break_point_level_tab in break_point_level_t
  )
  is
    l_break_point break_point_t := i_break_point_level_tab.first;
  begin
    if p_obj.call_tab.count != 0
    then
      raise program_error;
    end if;

    while l_break_point is not null
    loop
      if i_break_point_level_tab(l_break_point) between c_level_debug and c_level_fatal
      then
        null;
      else
        raise value_error;
      end if;
 
      set_number
      ( p_str => l_break_point
      , p_num => i_break_point_level_tab(l_break_point)
      , p_str_tab => p_obj.break_point_level_str_tab
      , p_num_tab => p_obj.break_point_level_num_tab
      );
      p_obj.dirty := 1;

      l_break_point := i_break_point_level_tab.next(l_break_point);
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
  , i_break_point in varchar2
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
          ( p_str => i_break_point
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
  , i_module in module_name_t
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
      v_idx constant pls_integer := p_obj.call_tab.count + 1;
      v_other_calls varchar2(32767);
      v_call dbug_call_obj_t;
    begin
       p_obj.call_tab.extend(1);
       p_obj.call_tab(v_idx) := dbug_call_obj_t(i_module, null, null);
       -- only the first other_calls has to be stored, so use a variable for v_idx > 1
       if v_idx = 1
       then
         get_called_from(p_obj.call_tab(v_idx).called_from, p_obj.call_tab(v_idx).other_calls);
       else
         get_called_from(p_obj.call_tab(v_idx).called_from, v_other_calls);

         -- Same stack?
         -- See =head2 Restarting a PL/SQL block with dbug.leave calls missing due to an exception
         if ( p_obj.call_tab(p_obj.call_tab.first).module_name = i_module and
              nvl(p_obj.call_tab(p_obj.call_tab.first).called_from, 'X') = nvl(p_obj.call_tab(v_idx).called_from, 'X') and
              nvl(p_obj.call_tab(p_obj.call_tab.first).other_calls, 'X') = nvl(v_other_calls, 'X') )
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
           v_call := p_obj.call_tab(v_idx);

           p_obj.call_tab.trim; -- this one is moved to nr 1
           pop_call_stack(p_obj, 1); -- erase the complete stack (except index 0)
           p_obj.call_tab.extend(1);
           p_obj.call_tab(1) := v_call;
           p_obj.call_tab(1).other_calls := v_other_calls;
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
          dbms_sql.bind_variable(l_cursor, '0', i_module);
          l_dummy := dbms_sql.execute(l_cursor);
        exception
          when others
          then 
            handle_error( SQLCODE, SQLERRM );
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
            handle_error( SQLCODE, SQLERRM );
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
            handle_error( SQLCODE, SQLERRM );
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
            handle_error( SQLCODE, SQLERRM );
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
            handle_error( SQLCODE, SQLERRM );
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
            handle_error( SQLCODE, SQLERRM );
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
      v_called_from varchar2(32767);
      v_other_calls_dummy varchar2(32767);
      v_idx pls_integer := p_obj.call_tab.last;
    begin
       get_called_from(v_called_from, v_other_calls_dummy);

      -- adjust for mismatch in enter/leave pairs
      loop
        if v_idx is null
        then
          -- called_from location for leave does not exist in p_obj.call_tab
          raise program_error;
        elsif nvl(p_obj.call_tab(v_idx).called_from, 'X') = nvl(v_called_from, 'X')
        then
          pop_call_stack(p_obj, v_idx);
          exit;
        else
          v_idx := p_obj.call_tab.prior(v_idx);
        end if;
      end loop;
    end;
  end leave;

  procedure on_error
  ( p_obj in dbug_obj_t
  , i_function in varchar2
  , i_output in dbug.line_tab_t
  )
  is
    v_line varchar2(100) := null;
    v_line_no pls_integer;
    l_level level_t;
  begin
    --/*TRACE*/ trace('>on_error('||i_function||','||i_output.count||')');

    if not check_break_point(p_obj, "error")
    then
      return;
    end if;
 
    v_line_no := i_output.first;
    v_line := case when i_output.count > 1 then ' (' || v_line_no || ')' else null end;
    while v_line_no is not null
    loop
      print(p_obj, "error", '%s: %s', i_function || v_line, i_output(v_line_no));
      v_line_no := i_output.next(v_line_no);
      v_line := ' (' || v_line_no || ')';
    end loop;

    --/*TRACE*/ trace('<on_error');
  end on_error;

  procedure on_error
  ( p_obj in dbug_obj_t
  , i_function in varchar2
  , i_output in varchar2
  , i_sep in varchar2
  )
  is
    v_line_tab line_tab_t;
  begin
    split(i_output, i_sep, v_line_tab);

    dbug.on_error(p_obj, i_function, v_line_tab);
  end on_error;

  procedure get_state
  is
  begin
    --/*TRACE*/ trace('>get_state');
/**/
    if g_obj is not null
    then
      raise program_error;
    end if;
    g_obj := new dbug_obj_t();
    --/*TRACE*/ g_obj.print();
/**/
    null;
  end get_state;

  procedure set_state(p_store in boolean default true, p_print in boolean default false)
  is
  begin
    --/*TRACE*/ trace('>set_state');
/**/
    if p_store
    then
      g_obj.store();
    end if;
    if p_print
    then
      g_obj.print();
    end if;
    g_obj := null;
/**/
    null;
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
  end done;

  procedure activate
  ( i_method in method_t
  , i_status in boolean
  )
  is
  begin
    --/*TRACE*/ trace('>activate');
    get_state;
    begin
      activate(g_obj, i_method, i_status);
    exception
      when others
      then
        set_state(p_store => true, p_print => true);
        raise;
    end;
    set_state(p_store => true);
  end activate;

  function active
  ( i_method in method_t
  )
  return boolean
  is
    l_result boolean;
  begin
    --/*TRACE*/ trace('>active');
    get_state;
    begin
      l_result := active(g_obj, i_method);
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);

    return l_result;
  end active;

  procedure set_level
  ( i_level in level_t
  )
  is
  begin
    --/*TRACE*/ trace('>set_level');
    get_state;
    begin
      set_level(g_obj, i_level);
    exception
      when others
      then
        set_state(p_store => true, p_print => true);
        raise;
    end;
    set_state(p_store => true);
  end;

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
    return l_result;
  end;

  procedure set_break_point_level
  ( i_break_point_level_tab in break_point_level_t
  )
  is
  begin
    --/*TRACE*/ trace('>set_break_point_level');
    get_state;
    begin
      set_break_point_level(g_obj, i_break_point_level_tab);
    exception
      when others
      then
        set_state(p_store => true, p_print => true);
        raise;
    end;
    set_state(p_store => true);
  end;

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
    return l_result;
  end;

  procedure enter
  ( i_module in module_name_t
  )
  is
  begin
    --/*TRACE*/ trace('>enter');
    get_state;
    begin
      enter(g_obj, i_module);
    exception
      when others
      then
        set_state(p_store => true, p_print => true);
        raise;
    end;
    set_state(p_store => true);
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
        set_state(p_store => true, p_print => true);
        raise;
    end;
    set_state(p_store => true);
  end leave;

  procedure on_error
  is
    v_cursor integer;
    v_dummy integer;
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
          , v_cursor
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
  for i_idx in 1..l_message_count
  loop
    l_line_tab(l_line_tab.count+1) :=
      cg$errors.get_display_string
      ( p_msg_code => l_message_tab(i_idx).msg_code 
      , p_msg_text => l_message_tab(i_idx).msg_text
      , p_msg_type => l_message_tab(i_idx).severity
      );
  end loop;

  dbug.on_error('cg$errors.geterrors', l_line_tab);
end;]'
          , v_cursor
          );
        end if;

        if v_cursor is not null
        then
          v_dummy := dbms_sql.execute(v_cursor);
        end if;
      exception
        when others
        then
          show_error(sqlerrm);
      end;
    end loop;
  end on_error;

  procedure on_error
  ( i_function in varchar2
  , i_output in varchar2
  , i_sep in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>on_error');
    get_state;
    begin
      on_error
      ( g_obj
      , i_function
      , i_output
      , i_sep
      );
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);
  end on_error;

  procedure on_error
  ( i_function in varchar2
  , i_output in dbug.line_tab_t
  )
  is
  begin
    --/*TRACE*/ trace('>on_error');
    get_state;
    begin
      on_error(g_obj, i_function, i_output);
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);
  end on_error;

  procedure leave_on_error
  is
  begin
    --/*TRACE*/ trace('>leave_on_error');
    /* since on_error dynamically calls one of the global on_error routines we can not use an object */
    on_error;
    leave;
  end leave_on_error;

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

  procedure print
  ( i_break_point in varchar2
  , i_str in varchar2
  ) is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(p_obj => g_obj, p_break_point => i_break_point, p_fmt => '%s', p_arg1 => i_str); 
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);
  end print;

  procedure print
  ( i_break_point in varchar2
  , i_fmt in varchar2
  , i_arg1 in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(g_obj, i_break_point, i_fmt, i_arg1);
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);
  end;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in date
  ) is
  begin
    print
    ( i_break_point => i_break_point
    , i_fmt => i_fmt
    , i_arg1 => to_char(i_arg1, 'YYYYMMDDHH24MISS')
    );
  end print;

  procedure print(
    i_break_point in varchar2,
    i_fmt in varchar2,
    i_arg1 in boolean
  ) is
  begin
    print
    ( i_break_point => i_break_point
    , i_fmt => i_fmt
    , i_arg1 => cast_to_varchar2(i_arg1)
    );
  end print;

  procedure print
  ( i_break_point in varchar2
  , i_fmt in varchar2
  , i_arg1 in varchar2
  , i_arg2 in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(g_obj, i_break_point, i_fmt, i_arg1, i_arg2);
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);
  end;

  procedure print
  ( i_break_point in varchar2
  , i_fmt in varchar2
  , i_arg1 in varchar2
  , i_arg2 in varchar2
  , i_arg3 in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(g_obj, i_break_point, i_fmt, i_arg1, i_arg2, i_arg3);
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);
  end;

  procedure print
  ( i_break_point in varchar2
  , i_fmt in varchar2
  , i_arg1 in varchar2
  , i_arg2 in varchar2
  , i_arg3 in varchar2
  , i_arg4 in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(g_obj, i_break_point, i_fmt, i_arg1, i_arg2, i_arg3, i_arg4);
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);
  end;

  procedure print
  ( i_break_point in varchar2
  , i_fmt in varchar2
  , i_arg1 in varchar2
  , i_arg2 in varchar2
  , i_arg3 in varchar2
  , i_arg4 in varchar2
  , i_arg5 in varchar2
  )
  is
  begin
    --/*TRACE*/ trace('>print');
    get_state;
    begin
      print(g_obj, i_break_point, i_fmt, i_arg1, i_arg2, i_arg3, i_arg4, i_arg5);
    exception
      when others
      then
        set_state(p_store => false, p_print => true);
        raise;
    end;
    set_state(p_store => false);
  end print;

  procedure split(
    i_buf in varchar2
  , i_sep in varchar2
  , o_line_tab out nocopy line_tab_t
  )
  is
    v_pos pls_integer;
    v_prev_pos pls_integer := 1;
    v_length constant pls_integer := nvl(length(i_buf), 0);
  begin
    loop
      exit when v_prev_pos > v_length;

      v_pos := instr(i_buf, i_sep, v_prev_pos);

      if v_pos is null -- i_sep null?
      then
        exit;
      elsif v_pos = 0
      then
        o_line_tab(o_line_tab.count+1) := substr(i_buf, v_prev_pos);
        exit;
      else
        o_line_tab(o_line_tab.count+1) := substr(i_buf, v_prev_pos, v_pos - v_prev_pos);
      end if;

      v_prev_pos := v_pos + length(i_sep);
    end loop;
  end split;

  function format_enter(
    i_module in module_name_t
  )
  return varchar2
  is
  begin
    -- g_obj must have been set by one of the enter/leave/print routines
    return rpad( c_indent, g_obj.indent_level*4, ' ' ) || '>' || i_module;
  end format_enter;

  function format_leave
  return varchar2
  is
  begin
    -- g_obj must have been set by one of the enter/leave/print routines
    return rpad( c_indent, g_obj.indent_level*4, ' ' ) || '<';
  end format_leave;

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
    -- g_obj must have been set by one of the enter/leave/print routines
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
      rpad( c_indent, g_obj.indent_level*4, ' ' ) ||
      i_break_point ||
      ': ' ||
      v_str;

    return v_str;
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
