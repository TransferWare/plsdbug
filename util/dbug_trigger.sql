REMARK
REMARK $Header$
REMARK
REMARK Author    : Gert-Jan Paulissen
REMARK
REMARK Goal      : Create after row triggers
REMARK
REMARK Notes     : 
REMARK
REMARK Parameters:
PROMPT             1 - table name (wildcard)
PROMPT             &&1
PROMPT             2 - file name
PROMPT             &&2

SET DOCUMENT OFF

DOCUMENT

The following documentation uses the Perl pod format. A html file
can be constructed by: 

  pod2html --infile=dbug_trigger.sql --outfile=dbug_trigger.html

=pod

=head1 NAME

dbug_trigger - Create after row triggers for selected tables.

=head1 SYNOPSIS

  sqlplus @dbug_trigger.sql <table name> <file name>

=head1 DESCRIPTION

The created triggers use the dbug_trigger package for debugging the column
values of selected tables. Output is sent to a file.

=head1 NOTES

=head1 EXAMPLES

  In SQL*Plus:

  SQL> @dbug_trigger % trigger.sql

=head1 AUTHOR

Gert-Jan Paulissen, E<lt>gpaulissen@transfer-solutions.comE<gt>.

=head1 HISTORY

=head1 BUGS

=head1 SEE ALSO

=cut

#

set serveroutput on size 1000000
set pagesize 0
set linesize 1000
set trimspool on
set feedback off
set verify off
set termout on

variable table_name varchar2(100)

begin
  :table_name := upper('&&1');
end;
/

define file_name = '&&2'

set pagesize 0 trimspool on feedback off

spool &&file_name

select  'REMARK Generated by dbug_trigger.sql (' || 
        translate('$Revision$', '0123456789.$Revision: ', '0123456789.' ) ||
        ')'
from    dual
/

prompt

select  case
          when tab.column_name = 'begin'
          then
            'create or replace trigger ' ||
            substr(lower(tab.table_name), 1, 25) || '_dbug' || chr(10) ||
            'after insert or update or delete on ' || lower(tab.table_name) || chr(10) ||
            'for each row' || chr(10) ||
            'begin' || chr(10) ||
            '  dbug_trigger.enter( ''' || tab.table_name || '''' ||
            ', ''' || substr(upper(tab.table_name), 1, 25) || '_DBUG''' || 
            ', inserting, updating, deleting );'
          when tab.column_name = 'end'
          then
            chr(10) || '  dbug_trigger.leave;' || chr(10) ||
            'end;' || chr(10) || '/'
          else
            '  dbug_trigger.print( ' || 
            decode( key_position, null, 'false', 'true' ) || 
            ', ''' || tab.column_name || '''' ||
            ', :old.' || column_name ||
            ', :new.' || column_name || ' );'
        end line
from    ( select  tab.object_name table_name
          ,       'begin' column_name
          ,       -1 column_id
          ,       -1 key_position
          from    user_objects tab
          where   tab.object_name like :table_name
          and     tab.object_type = 'TABLE'
          union
          select  col.table_name
          ,       col.column_name
          ,       col.column_id
          ,       ( select  max(key.position)
                    from    user_cons_columns key
                    ,       user_constraints con
                    where   con.table_name = key.table_name
                    and     con.constraint_name = key.constraint_name
                    and     con.table_name = col.table_name
                    and     con.constraint_type = 'P'
                    and     key.column_name = col.column_name
                  ) key_position
          from    user_tab_columns col
          ,       user_objects tab
          where   col.table_name = tab.object_name
          and     tab.object_name like :table_name
          and     tab.object_type = 'TABLE'
          and     col.data_type in ( 'BINARY_INTEGER',
                                     'DEC',
                                     'DECIMAL',
                                     'DOUBLE PRECISION',
                                     'FLOAT',
                                     'INT',
                                     'INTEGER',
                                     'NATURAL',
                                     'NATURALN',
                                     'NUMBER',
                                     'NUMERIC',
                                     'PLS_INTEGER',
                                     'POSITIVE',
                                     'POSITIVEN',
                                     'REAL',
                                     'SIGNTYPE',
                                     'SMALLINT',
                                     'CHAR',
                                     'CHARACTER',
                                     'STRING',
                                     'VARCHAR',
                                     'VARCHAR2',
                                     'DATE' )
          union
          select  tab.object_name table_name
          ,       'end' column_name
          ,       to_number(null) column_id
          ,       to_number(null) key_position
          from    user_objects tab
          where   tab.object_name like :table_name
          and     tab.object_type = 'TABLE'
        ) tab
order by
        tab.table_name
,       tab.key_position
,       tab.column_id
/

spool off

undefine 1 2 file_name
