CREATE OR REPLACE PACKAGE "DBUG_TRIGGER" AUTHID DEFINER IS

  procedure print_all
  ( p_print_all in boolean default true
  );

  procedure process_dml
  ( p_table_name in dbug.module_name_t
  , p_inserting in boolean
  , p_updating in boolean
  , p_deleting in boolean
  , p_dml_finished in boolean default false
  );

  procedure enter(
    p_table_name in dbug.module_name_t
  , p_trigger_name in dbug.module_name_t
  , p_inserting in boolean
  , p_updating in boolean
  , p_deleting in boolean
  );

  procedure leave;

  procedure print(
    p_key in boolean
  , p_column_name in varchar2
  , p_old_value in number
  , p_new_value in number
  );

  procedure print(
    p_key in boolean
  , p_column_name in varchar2
  , p_old_value in varchar2
  , p_new_value in varchar2
  );

  procedure print(
    p_key in boolean
  , p_column_name in varchar2
  , p_old_value in date
  , p_new_value in date
  );

end dbug_trigger;

-- =cut
/

