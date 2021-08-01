CREATE OR REPLACE PACKAGE BODY "DBUG_DBMS_APPLICATION_INFO" IS

  c_module_name_size constant pls_integer := 48;
  c_action_name_size constant pls_integer := 32;
  c_client_info_size constant pls_integer := 64;

  subtype module_name_t is varchar2(48);
  subtype action_name_t is varchar2(32);
  -- subtype client_info_t is varchar2(64);

  g_module_name_tab dbms_sql.varchar2_table;

  /* global modules */

  procedure done
  is
  begin
    null;
  end done;

  procedure enter(
    p_module in dbug.module_name_t
  )
  is
    l_item_tab dbug.line_tab_t;
  begin
    -- push
    g_module_name_tab(g_module_name_tab.count+1) := p_module;

    -- p_module is of van de vorm PACKAGE.SUBROUTINE of van de vorm SUBROUTINE
    dbug.split(p_module, '.', l_item_tab);

    case
      when l_item_tab.count = 1
      then
        dbms_application_info.set_module
        ( module_name => substr(l_item_tab(l_item_tab.first), 1, c_module_name_size) -- subroutine
        , action_name => null
        );

      when l_item_tab.count >= 2
      then
        dbms_application_info.set_module
        ( module_name => substr(l_item_tab(l_item_tab.first), 1, c_module_name_size) -- package
        , action_name => substr(p_module, 1 + length(l_item_tab(l_item_tab.first)) + 1, c_action_name_size) -- subroutine(s)
        );

    end case;
  end enter;

  procedure leave
  is
    l_item_tab dbug.line_tab_t;
  begin
    -- pop, zie ook init block
    g_module_name_tab.delete(g_module_name_tab.last);

    -- g_module_name_tab(g_module_name_tab.last) is of van de vorm PACKAGE.SUBROUTINE of van de vorm SUBROUTINE
    dbug.split(g_module_name_tab(g_module_name_tab.last), '.', l_item_tab);

    case
      when l_item_tab.count = 1
      then
        dbms_application_info.set_module
        ( module_name => substr(l_item_tab(l_item_tab.first), 1, c_module_name_size) -- subroutine
        , action_name => null
        );

      when l_item_tab.count >= 2
      then
        dbms_application_info.set_module
        ( module_name => substr(l_item_tab(l_item_tab.first), 1, c_module_name_size) -- package
        , action_name => substr(g_module_name_tab(g_module_name_tab.last), 1 + length(l_item_tab(l_item_tab.first)) + 1, c_action_name_size) -- subroutine(s)
        );

    end case;
  end leave;

  procedure print( p_str in varchar2 )
  is
    l_line_tab dbug.line_tab_t;
  begin
    dbug.split(p_str, chr(10), l_line_tab);
    -- can only display one line
    dbms_application_info.set_client_info
    ( client_info => substr(ltrim(l_line_tab(l_line_tab.first), '|   '), 1, c_client_info_size)
    );
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2
  ) is
  begin
    print( dbug.format_print(p_break_point, p_fmt, 1, p_arg1) );
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2
  ) is
  begin
    print( dbug.format_print(p_break_point, p_fmt, 2, p_arg1, p_arg2) );
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2
  ) is
  begin
    print( dbug.format_print(p_break_point, p_fmt, 3, p_arg1, p_arg2, p_arg3) );
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2,
    p_arg4 in varchar2
  ) is
  begin
    print( dbug.format_print(p_break_point, p_fmt, 4, p_arg1, p_arg2, p_arg3, p_arg4) );
  end print;

  procedure print(
    p_break_point in varchar2,
    p_fmt in varchar2,
    p_arg1 in varchar2,
    p_arg2 in varchar2,
    p_arg3 in varchar2,
    p_arg4 in varchar2,
    p_arg5 in varchar2
  ) is
  begin
    print( dbug.format_print(p_break_point, p_fmt, 5, p_arg1, p_arg2, p_arg3, p_arg4, p_arg5) );
  end print;

begin
  declare
    l_module_name module_name_t;
    l_action_name action_name_t;
  begin
    dbms_application_info.read_module
    ( module_name => l_module_name
    , action_name => l_action_name
    );
    -- so there will always be at least one entry
    g_module_name_tab(g_module_name_tab.count+1) := l_module_name || '.' || l_action_name;
  end;
end dbug_dbms_application_info;
/

