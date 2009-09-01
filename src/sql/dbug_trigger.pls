--$NO_KEYWORD_EXPANSION$
REMARK
REMARK  $HeadURL$
REMARK

WHENEVER SQLERROR EXIT FAILURE

SET DOCUMENT OFF

DOCUMENT

  The following documentation uses the Perl pod format. A html file
  can be constructed by: 

        pod2html --infile=dbug.pls --outfile=dbug.html

=pod

=head1 NAME

dbug_trigger - Perform debugging in Oracle PL/SQL triggers

=head1 SYNOPSIS

=cut

#

-- =pod

create or replace package dbug_trigger is

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

show errors

@@dbug_verify dbug_trigger package

DOCUMENT

=head1 DESCRIPTION

The I<dbug_trigger> package is used for debugging after row triggers.

The I<dbug> package is used by I<dbug_trigger>.

=over 4

=item enter

Enter a trigger I<p_trigger_name> of table I<p_table_name>. The trigger mode
is specified by either I<p_inserting>, I<p_updating> or I<p_deleting>.

=item leave

Leave the trigger. This must always be called if enter was called before, even
if an exception has been raised.

=item print

Print a line containing info about the column. The parameter I<p_key> denotes
whether the column is a key column. The parameter I<p_column_name> shows the
column name. Information is only printed in the following occasions: a non
null column while inserting; a changed value while updating or the key column
while deleting. The I<p_old_value> is only used when the trigger is updating
or when it is a key column in a deleting trigger. The I<new_value> is only
used for an inserting or updating trigger.

=back

=head1 NOTES

=head1 EXAMPLES

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

create or replace package body dbug_trigger is

  g_inserting boolean := null;
  g_updating boolean := null;
  g_deleting boolean := null;
  g_date_format_cst constant varchar2(16) := 'YYYYMMDDHH24MISS';

  /* scratch variable */
  g_text varchar2(32767);
  g_break_point varchar2(4); /* key|data */

  type dml_info_rectype is record (
    rindex binary_integer := dbms_application_info.set_session_longops_nohint
  , slno binary_integer
  , rows_processed pls_integer := 0
  );

  type dml_info_tabtype is table of dml_info_rectype index by varchar2(100);

  g_dml_info_tab dml_info_tabtype;

  procedure process_row
  ( p_table_name in dbug.module_name_t
  , p_operation in varchar2
  )
  is
    l_dml_info_rec dml_info_rectype;
  begin
    -- retrieve info
    if g_dml_info_tab.exists(p_table_name||':'||p_operation)
    then
      l_dml_info_rec := g_dml_info_tab(p_table_name||':'||p_operation);
    end if;

    l_dml_info_rec.rows_processed := l_dml_info_rec.rows_processed + 1;

    dbms_application_info.set_session_longops
    ( rindex => l_dml_info_rec.rindex
    , slno => l_dml_info_rec.slno
    , op_name => p_operation
    , sofar => l_dml_info_rec.rows_processed
    , target_desc => p_table_name
    , units => 'rows'
    );

    -- store info
    g_dml_info_tab(p_table_name||':'||p_operation) := l_dml_info_rec;
  end process_row;

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

    if g_inserting then
      g_text := 'INSERT';
    elsif g_updating then
      g_text := 'UPDATE';
    else
      g_text := 'DELETE';
    end if;

    process_row(p_table_name => p_table_name, p_operation => g_text);

    g_text := g_text || ' ROW TRIGGER ' || p_trigger_name || ' ON ' || p_table_name;


    dbug.enter( g_text );
  end enter;

  procedure leave
  is
  begin
    g_inserting := null;
    g_updating := null;
    g_deleting := null;
    dbug.leave;
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
    if g_inserting and p_new_value is not null then
      g_text := '"' || p_new_value || '"';
    elsif g_updating then
      if p_new_value is null and p_old_value is null
      or p_new_value = p_old_value then
        /* no change: print key value only */
        if p_key then
          g_text := '"' || p_old_value || '"';
        end if;
      else
        g_text := '"' || p_old_value || '"' || ' -> ' || '"' || p_new_value || '"';
      end if;
    elsif g_deleting and p_key then
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

show errors

@@dbug_verify dbug_trigger "package body"

