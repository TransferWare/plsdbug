REMARK
REMARK $Header$
REMARK
REMARK Author    : Gert-Jan Paulissen
REMARK
REMARK Goal      : Create PL/SQL code with dbug statements.
REMARK
REMARK Notes     : 
REMARK
REMARK Parameters:
PROMPT             1 - object type (wildcard)
PROMPT             &&1
PROMPT             2 - object name (wildcard)
PROMPT             &&2
PROMPT             3 - extension (default sql)
PROMPT             &&3

SET DOCUMENT OFF

DOCUMENT

The following documentation uses the Perl pod format. A html file
can be constructed by: 

  pod2html --infile=dbug_pls.sql --outfile=dbug_pls.html

=pod

=head1 NAME

dbug_pls - Create PL/SQL code with dbug statements.

=head1 SYNOPSIS

  sqlplus @dbug_pls.sql <object type> <object name> [ <extension> ]

=head1 DESCRIPTION

The source code of the stored PL/SQL objects is extracted and split into separate
files with the extension specified. Then dbug code is inserted at the begin
and end.

=head1 NOTES

The source code is extracted from USER_SOURCE/USER_TRIGGERS. The text CREATE
OR REPLACE and / is added at the end of each object. Next the generated script
is fed to the Perl scripts sql_parse.pl and pls_mod.pl which must be in the
PATH.

=head1 EXAMPLES

  In SQL*Plus:

  SQL> @dbug_pls % % sql

=head1 AUTHOR

Gert-Jan Paulissen, E<lt>gpaulissen@transfer-solutions.comE<gt>.

=head1 HISTORY

=head1 BUGS

21-jan-2005 G.J. Paulissen

Set linesize to 132 for triggers. This occurs after showing stored procedures
where linesize is 10000.

25-mar-2004 G.J. Paulissen

Linesize set to 10000 for very large tables (lots of columns).

16-apr-2008 G.J. Paulissen

Set linesize to 200 for triggers, since 132 is not enough.

=head1 SEE ALSO

pls_mod.pl

=cut

#

set serveroutput on size 1000000
set pagesize 0
set linesize 10000
set trimspool on
set feedback off
set verify off
set termout on

variable object_type varchar2(100)
variable object_name varchar2(100)

begin
  :object_type := upper('&&1');
  :object_name := upper('&&2');
end;
/

set pagesize 0 trimspool on feedback off

column d3 new_value 3

set termout off

select  'sql' d3
from    dual
where   '&&3' is null
/

column d3 clear

define extension = '&&3'
define tmp_file = 'tmp.&&extension'

spool &&tmp_file

select  'REMARK Generated by dbug_pls.sql (' || 
        translate('$Revision$', '0123456789.$Revision: ', '0123456789.' ) ||
        ')'
from    dual
/

prompt

column line noprint
column name noprint
column type noprint

prompt set define off
prompt

select  'CREATE OR REPLACE' text
,       0 line
,       src.name
,       src.type
from    user_source src
where   src.name like :object_name
and     src.type like :object_type
and     src.type in ( 'FUNCTION', 'PROCEDURE', 'PACKAGE BODY' )
and     src.name not in ( 'EPC', 'EPC_CLNT', 'EPC_SRVR', 'DBUG', 'DBUG_TRIGGER', 'PLSDBUG' )
union
select  src.text
,       src.line
,       src.name
,       src.type
from    user_source src
where   src.name like :object_name
and     src.type like :object_type
and     src.type in ( 'FUNCTION', 'PROCEDURE', 'PACKAGE BODY' )
and     src.name not in ( 'EPC', 'EPC_CLNT', 'EPC_SRVR', 'DBUG', 'DBUG_TRIGGER', 'PLSDBUG' )
union
select  '/' text
,       to_number(null) line
,       src.name
,       src.type
from    user_source src
where   src.name like :object_name
and     src.type like :object_type
and     src.type in ( 'FUNCTION', 'PROCEDURE', 'PACKAGE BODY' )
and     src.name not in ( 'EPC', 'EPC_CLNT', 'EPC_SRVR', 'DBUG', 'DBUG_TRIGGER', 'PLSDBUG' )
order by
        name
,       type            
,       line
/

column line clear
column name clear
column type clear

set long 100000
set longchunksize 1000
REMARK GJP 21-1-2005 Display triggers nicely
REMARK GJP 16-4-2008 But 132 is not enough.
set linesize 200 trimspool on

select  'CREATE OR REPLACE TRIGGER ' ||
        description ||
        case 
          when when_clause is not null
          then 'WHEN (' || when_clause || ')'
          else null
        end
,       trigger_body
,       '/'
from    user_triggers src
where   src.trigger_name like :object_name
and     'TRIGGER' like :object_type
/

prompt
prompt set define on

spool off

undefine 1 2 3

host perl -S sql_split.pl "&&tmp_file"

spool &&tmp_file

select  'host perl -S pls_mod.pl "' || obj.object_name || '.&&extension"'
from    user_objects obj
where   obj.object_name like :object_name
and     obj.object_type like :object_type
and     obj.object_type in ( 'FUNCTION', 'PROCEDURE', 'PACKAGE BODY' )
and     obj.object_name not in ( 'EPC', 'EPC_CLNT', 'EPC_SRVR', 'DBUG', 'DBUG_TRIGGER', 'PLSDBUG' )
union all
select  distinct 
        'host perl -S pls_mod.pl "' || obj.table_name || '.&&extension"'
from    user_triggers obj
where   obj.trigger_name like :object_name
and     'TRIGGER' like :object_type
/

spool off

@&&tmp_file

rem empty temp file

spool &&tmp_file
prompt
spool off

set termout on

undefine 1 2 3 extension tmp_file
