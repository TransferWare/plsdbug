REMARK $Id$

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
    i_table_name in dbug.module_name_t
  , i_trigger_name in dbug.module_name_t
  , i_inserting in boolean
  , i_updating in boolean
  , i_deleting in boolean
  );

  procedure leave;

  procedure print(
    i_key in boolean
  , i_column_name in varchar2
  , i_old_value in number
  , i_new_value in number
  );

  procedure print(
    i_key in boolean
  , i_column_name in varchar2
  , i_old_value in varchar2
  , i_new_value in varchar2
  );

  procedure print(
    i_key in boolean
  , i_column_name in varchar2
  , i_old_value in date
  , i_new_value in date
  );

end dbug_trigger;

-- =cut

/

DOCUMENT

=head1 DESCRIPTION

The I<dbug_trigger> package is used for debugging after row triggers.

The I<dbug> package is used by I<dbug_trigger>.

=over 4

=item enter

Enter a trigger I<i_trigger_name> of table I<i_table_name>. The trigger mode
is specified by either I<i_inserting>, I<i_updating> or I<i_deleting>.

=item leave

Leave the trigger. This must always be called if enter was called before, even
if an exception has been raised.

=item print

Print a line containing info about the column. The parameter I<i_key> denotes
whether the column is a key column. The parameter I<i_column_name> shows the
column name. Information is only printed in the following occasions: a non
null column while inserting; a changed value while updating or the key column
while deleting. The I<i_old_value> is only used when the trigger is updating
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

  procedure enter(
    i_table_name in dbug.module_name_t
  , i_trigger_name in dbug.module_name_t
  , i_inserting in boolean
  , i_updating in boolean
  , i_deleting in boolean
  )
  is
  begin
    g_inserting := i_inserting;
    g_updating := i_updating;
    g_deleting := i_deleting;

    if g_inserting then
      g_text := 'INSERT';
    elsif g_updating then
      g_text := 'UPDATE';
    else
      g_text := 'DELETE';
    end if;

    g_text := g_text || ' ROW TRIGGER ' || i_trigger_name || ' ON ' || i_table_name;

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
    i_key in boolean
  , i_column_name in varchar2
  , i_old_value in number
  , i_new_value in number
  ) 
  is
  begin
    print( i_key, i_column_name, to_char(i_old_value), to_char(i_new_value) );
  end print;

  procedure print(
    i_key in boolean
  , i_column_name in varchar2
  , i_old_value in varchar2
  , i_new_value in varchar2
  )
  is
  begin
    g_text := null;
    if g_inserting and i_new_value is not null then
      g_text := '"' || i_new_value || '"';
    elsif g_updating then
      if i_new_value is null and i_old_value is null
      or i_new_value = i_old_value then
        /* no change: print key value only */
        if i_key then
          g_text := '"' || i_old_value || '"';
        end if;
      else
        g_text := '"' || i_old_value || '"' || ' -> ' || '"' || i_new_value || '"';
      end if;
    elsif g_deleting and i_key then
      g_text := '"' || i_old_value || '"';
    end if;

    if g_text is not null then
      /* column_name: */
      if i_key then
        g_break_point := 'key';
      else
        g_break_point := 'data';
      end if;

      dbug.print( g_break_point, '%s: %s', i_column_name, g_text );
    end if;
  end print;

  procedure print(
    i_key in boolean
  , i_column_name in varchar2
  , i_old_value in date
  , i_new_value in date
  )
  is
  begin
    print( i_key
         , i_column_name
         , to_char(i_old_value, g_date_format_cst)
         , to_char(i_new_value, g_date_format_cst) );
  end print;

end dbug_trigger;
/
