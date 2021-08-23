CREATE OR REPLACE PACKAGE BODY "DBUG_TRIGGER" IS

  g_print_all boolean := false;

  g_inserting boolean := null;
  g_updating boolean := null;
  g_deleting boolean := null;
  g_date_format_cst constant varchar2(16) := 'YYYYMMDDHH24MISS';

  /* scratch variable */
  g_text varchar2(32767);
  g_called_from dbug.module_name_t := null;
  g_break_point varchar2(4); /* key|data */

  type dml_info_rectype is record (
    rindex binary_integer := dbms_application_info.set_session_longops_nohint
  , slno binary_integer
  , rows_processed pls_integer := 0
  );

  type dml_info_tabtype is table of dml_info_rectype index by varchar2(100);

  g_dml_info_tab dml_info_tabtype;

  function get_operation
  ( p_inserting in boolean
  , p_updating in boolean
  , p_deleting in boolean
  )
  return varchar2
  is
  begin
    return
      case
        when p_inserting then 'INSERT'
        when p_updating then 'UPDATE'
        when p_deleting then 'DELETE'
      end;
  end get_operation;

  procedure print_all
  ( p_print_all in boolean
  )
  is
  begin
    g_print_all := p_print_all;
  end print_all;

  procedure process_dml
  ( p_table_name in dbug.module_name_t
  , p_inserting in boolean
  , p_updating in boolean
  , p_deleting in boolean
  , p_dml_finished in boolean default false
  )
  is
    l_operation constant varchar2(6) :=
      get_operation(p_inserting, p_updating, p_deleting);
    l_dml_info_rec dml_info_rectype;
  begin
    -- retrieve info
    if g_dml_info_tab.exists(p_table_name||':'||l_operation)
    then
      l_dml_info_rec := g_dml_info_tab(p_table_name||':'||l_operation);
    end if;

    if p_dml_finished
    then
      dbms_application_info.set_session_longops
      ( rindex => l_dml_info_rec.rindex
      , slno => l_dml_info_rec.slno
      , op_name => l_operation
      , sofar => l_dml_info_rec.rows_processed
      , totalwork => l_dml_info_rec.rows_processed
      , target_desc => p_table_name
      , units => 'rows'
      );
      l_dml_info_rec.rows_processed := 0; -- for the next time
    else
      -- row trigger
      l_dml_info_rec.rows_processed := l_dml_info_rec.rows_processed + 1;

      dbms_application_info.set_session_longops
      ( rindex => l_dml_info_rec.rindex
      , slno => l_dml_info_rec.slno
      , op_name => l_operation
      , sofar => l_dml_info_rec.rows_processed
      , target_desc => p_table_name
      , units => 'rows'
      );
    end if;

    -- store info
    g_dml_info_tab(p_table_name||':'||l_operation) := l_dml_info_rec;
  end process_dml;

  -- GLOBAL

  procedure enter(
    p_table_name in dbug.module_name_t
  , p_trigger_name in dbug.module_name_t
  , p_inserting in boolean
  , p_updating in boolean
  , p_deleting in boolean
  )
  is
  begin
    g_inserting := p_inserting;
    g_updating := p_updating;
    g_deleting := p_deleting;

    g_text := get_operation(g_inserting, g_updating, g_deleting);

    process_dml
    ( p_table_name => p_table_name
    , p_inserting => p_inserting
    , p_updating => p_updating
    , p_deleting => p_deleting
    );

    g_text := g_text || ' ROW TRIGGER ' || p_trigger_name || ' ON ' || p_table_name;

    dbug.enter( g_text, g_called_from );
    dbug.print
    ( dbug."info"
    , 'user: %s; OS user: %s; sid: %s'
    , user
    , sys_context('USERENV', 'OS_USER')
    , sys_context('USERENV', 'SID')
    );
  end enter;

  procedure leave
  is
  begin
    g_inserting := null;
    g_updating := null;
    g_deleting := null;
    dbug.leave( g_called_from );
  end leave;

  procedure print(
    p_key in boolean
  , p_column_name in varchar2
  , p_old_value in number
  , p_new_value in number
  )
  is
  begin
    print( p_key, p_column_name, to_char(p_old_value), to_char(p_new_value) );
  end print;

  procedure print(
    p_key in boolean
  , p_column_name in varchar2
  , p_old_value in varchar2
  , p_new_value in varchar2
  )
  is
  begin
    g_text := null;
    if g_inserting and (g_print_all or p_new_value is not null) then
      g_text := '"' || p_new_value || '"';
    elsif g_updating then
      if p_new_value is null and p_old_value is null
      or p_new_value = p_old_value then
        /* no change: print key value only (unless print all) */
        if p_key or g_print_all then
          g_text := '"' || p_old_value || '"';
        end if;
      else
        g_text := '"' || p_old_value || '"' || ' -> ' || '"' || p_new_value || '"';
      end if;
    elsif g_deleting and (p_key or g_print_all) then
      g_text := '"' || p_old_value || '"';
    end if;

    if g_text is not null then
      /* column_name: */
      if p_key then
        g_break_point := 'key';
      else
        g_break_point := 'data';
      end if;

      dbug.print( g_break_point, '%s: %s', p_column_name, g_text );
    end if;
  end print;

  procedure print(
    p_key in boolean
  , p_column_name in varchar2
  , p_old_value in date
  , p_new_value in date
  )
  is
  begin
    print( p_key
         , p_column_name
         , to_char(p_old_value, g_date_format_cst)
         , to_char(p_new_value, g_date_format_cst) );
  end print;

end dbug_trigger;
/

