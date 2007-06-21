REM $Id$
REM
REM This script is there to verify that missing dbug.leave calls are adjusted for
REM later on.

set serveroutput on size 1000000
set feedback off
set trimspool on
set linesize 1000 trimspool on

var nr number

execute :nr := 1;

declare

  procedure f1(i_count natural := 5)
  is
  begin
    dbug.enter('f1');
    f1(i_count-1); -- since i_count is natural (>= 0) this will end in an exception
    if :nr = 0
    then
      -- Oops, forgot to dbug.leave;
      null;
    else
      dbug.leave;
    end if;
  exception
    when others
    then
      if :nr <= 1
      then
        -- Oops, forgot to dbug.leave_on_error;
        null;
      else
        dbug.leave_on_error;
      end if;
      raise;
  end;

  procedure f2
  is
  begin
    dbug.enter('f2');
    f1;
    dbug.leave;
  end;

  procedure f3
  is
  begin
    dbug.enter('f3');
    f2;
    dbug.leave;
  end;

begin
  dbug.activate('dbms_output');
  dbug.enter('main');
  f3;
  dbug.leave;
exception
  when others
  then
    if :nr <= 2
    then
      -- Oops, forgot to dbug.leave_on_error;
      null;
    else
      dbug.leave_on_error;
    end if;
    raise;
end;
.

list

/

execute :nr := :nr + 1;

/

execute :nr := :nr + 1;

/

execute :nr := :nr + 1;

/
