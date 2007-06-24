REM $Id$
REM
REM This script is there to verify that missing dbug.leave calls are adjusted for
REM later on.

ALTER SESSION SET NLS_LANGUAGE = 'AMERICAN';

set serveroutput on size 1000000
set feedback off
set trimspool on
set linesize 1000 trimspool on

var testcase number

execute :testcase := 8;

REM :testcase represents a testcase.
REM :testcase is decremented before each run of the test block.

REM This is the default behaviour for functions f1, f2, f3 and the main block:
REM a) f2 does not handle exceptions
REM b) in other funcions every dbug.enter is (eventually) followed by 
REM    a call to dbug.leave (or dbug.leave_on_error in an exception block)
REM c) f1 raises an exception when :testcase is even because the recursion does not stop correctly

REM These are the testcases:
REM 1) all goes well
REM 2) function f1 only leaves correctly when no exception occurs
REM 3) function f1 only leaves correctly when an exception occurs
REM 4) function f1 never leaves correctly
REM 5) function f3 never leaves correctly
REM 6) the main block only leaves correctly when no exception occurs
REM 7) the main block only leaves correctly when an exception occurs
REM 8) the main block never leaves correctly

declare

  procedure f1(i_count natural := 5)
  is
  begin
    dbug.enter('f1');
    if mod(:testcase, 2) = 1 and i_count = 0
    then
      null;
    else
      f1(i_count-1); -- since i_count is natural (>= 0) this will end in an exception
    end if;
    if :testcase in (3, 4)
    then
      -- Oops, forgot to dbug.leave;
      null;
    else
      dbug.leave;
    end if;
  exception
    when others
    then
      if :testcase in (2, 4)
      then
        -- Oops, forgot to dbug.leave_on_error;
        null;
      else
        dbug.leave_on_error;
      end if;
      raise;
  end f1;

  procedure f2
  is
  begin
    dbug.enter('f2');
    f1;
    dbug.leave;
  end f2;

  procedure f3
  is
  begin
    dbug.enter('f3');
    f2;
    if :testcase in (5)
    then
      -- Oops, forgot to dbug.leave;
      null;
    else
      dbug.leave;
    end if;
  exception
    when others
    then
      if :testcase in (5)
      then
        -- Oops, forgot to dbug.leave_on_error;
        null;
      else
        dbug.leave_on_error;
      end if;
      raise;
  end f3;

begin
  dbms_output.put_line('testcase: ' || :testcase || ' (log level ' || dbug.get_level || ')');
  dbug.activate('dbms_output');
  dbug.enter('main');
  f3;
  if :testcase in (7, 8)
  then
    -- Oops, forgot to dbug.leave;
    null;
  else
    dbug.leave;
  end if;
exception
  when others
  then
    if :testcase in (6, 8)
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
execute :testcase := :testcase - 1;
/
execute :testcase := :testcase - 1;
/
execute :testcase := :testcase - 1;
/
execute :testcase := :testcase - 1;
/
execute dbug.set_level(dbug.c_level_error)
/
execute dbug.set_level(dbug.c_level_all)
execute :testcase := :testcase - 1;
/
execute :testcase := :testcase - 1;
/
execute :testcase := :testcase - 1;
/
execute dbug.set_level(dbug.c_level_off)
/

print testcase
