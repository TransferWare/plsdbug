CREATE OR REPLACE PACKAGE BODY "DBUG_PROFILER" AS

$if dbms_db_version.ver_le_10 $then

subtype simple_integer is pls_integer;

$end

-- implementation details
subtype t_time_ms is simple_integer; -- elapsed time in milliseconds

subtype t_count is simple_integer;

type t_count_tab is table of t_count index by dbug.module_name_t;

type t_time_ms_tab is table of t_time_ms index by dbug.module_name_t;

type t_module_name_stack is table of dbug.module_name_t index by pls_integer;

g_count_tab t_count_tab;
g_time_ms_tab t_time_ms_tab;
g_module_name_stack t_module_name_stack;
g_timestamp timestamp := null;

-- LOCAL ROUTINES
procedure start_timer;

function end_timer return t_time_ms;

$if dbug_profiler.c_testing $then

procedure sleep(p_seconds in number)
is
begin
$if dbms_db_version.version >= 18 $then
  dbms_session.sleep(p_seconds);
$else
  dbms_lock.sleep(p_seconds);
$end
end;

$end

-- GLOBAL ROUTINES
procedure start_timer
is
begin
  if g_timestamp is not null
  then
    raise program_error;
  end if;
  g_timestamp := systimestamp;
end start_timer;

function end_timer return t_time_ms
is
  l_timestamp constant timestamp := systimestamp;
  l_diff_timestamp constant interval day to second := l_timestamp - g_timestamp;
begin
  g_timestamp := null;
  return 1000 * extract(day    from l_diff_timestamp) * 24 * 60 * 60 +
         1000 * extract(hour   from l_diff_timestamp) * 60 * 60 +
         1000 * extract(minute from l_diff_timestamp) * 60 +
         round(1000 * extract(second from l_diff_timestamp));
end end_timer;

procedure enter(
  p_module in dbug.module_name_t
)
is
begin
  -- stop timing for the previous module and add the elapsed time to it
  if g_module_name_stack.last is not null
  then
    g_time_ms_tab(g_module_name_stack(g_module_name_stack.last)) := g_time_ms_tab(g_module_name_stack(g_module_name_stack.last)) + end_timer;
  end if;

  -- add this module to the stack
  g_module_name_stack(g_module_name_stack.count+1) := p_module;

  -- initialise this module if necessary
  if not g_count_tab.exists(p_module)
  then
    g_count_tab(p_module) := 0;
    g_time_ms_tab(p_module) := 0;
  end if;

  -- start the timer for this module
  start_timer;
end enter;

procedure leave
is
begin
  -- stop the timer and add the elapsed time to the current module
  g_time_ms_tab(g_module_name_stack(g_module_name_stack.last)) := g_time_ms_tab(g_module_name_stack(g_module_name_stack.last)) + end_timer;
  -- increase the count as well
  g_count_tab(g_module_name_stack(g_module_name_stack.last)) := g_count_tab(g_module_name_stack(g_module_name_stack.last)) + 1;
  -- delete the module from the stack
  g_module_name_stack.delete(g_module_name_stack.last);
  -- if there was a previous module start the timer again for that module
  if g_module_name_stack.last is not null
  then
    start_timer;
  end if;
end leave;

procedure done
is
begin
  g_count_tab.delete;
  g_time_ms_tab.delete;
  g_module_name_stack.delete;
  g_timestamp := null;
end done;

function show
return t_profile_tab pipelined
is
  l_profile_rec t_profile_rec;
begin
  l_profile_rec.module_name := g_count_tab.first;
  while l_profile_rec.module_name is not null
  loop
    l_profile_rec.nr_calls := g_count_tab(l_profile_rec.module_name);
    l_profile_rec.elapsed_time := g_time_ms_tab(l_profile_rec.module_name) / 1000;
    l_profile_rec.avg_time := case when l_profile_rec.nr_calls <> 0 then l_profile_rec.elapsed_time / l_profile_rec.nr_calls end;
    pipe row (l_profile_rec);
    l_profile_rec.module_name := g_count_tab.next(l_profile_rec.module_name);
  end loop;
  done; -- cleanup everything
  return;
end show;

-- necessary functions for the dbug interface but they do nothing
procedure print(
  p_break_point in varchar2,
  p_fmt in varchar2,
  p_arg1 in varchar2
)
is
begin
  null;
end print;

procedure print(
  p_break_point in varchar2,
  p_fmt in varchar2,
  p_arg1 in varchar2,
  p_arg2 in varchar2
)
is
begin
  null;
end print;

procedure print(
  p_break_point in varchar2,
  p_fmt in varchar2,
  p_arg1 in varchar2,
  p_arg2 in varchar2,
  p_arg3 in varchar2
)
is
begin
  null;
end print;

procedure print(
  p_break_point in varchar2,
  p_fmt in varchar2,
  p_arg1 in varchar2,
  p_arg2 in varchar2,
  p_arg3 in varchar2,
  p_arg4 in varchar2
)
is
begin
  null;
end print;

procedure print(
  p_break_point in varchar2,
  p_fmt in varchar2,
  p_arg1 in varchar2,
  p_arg2 in varchar2,
  p_arg3 in varchar2,
  p_arg4 in varchar2,
  p_arg5 in varchar2
)
is
begin
  null;
end print;

-- test procedures
-- enable by: alter package xxyss_admin.dbug_profiler compile body PLSQL_CCFlags = 'Testing:true' reuse settings
procedure ut_setup
is
begin
$if dbug_profiler.c_testing $then
  null;
$else
  raise program_error;
$end
end ut_setup;

procedure ut_teardown
is
begin
$if dbug_profiler.c_testing $then
  null;
$else
  raise program_error;
$end
end ut_teardown;

procedure ut_test
is
$if dbug_profiler.c_testing $then
  procedure p1
  is
  begin
    dbug.enter('p1');
    sleep(0);
    dbug.leave;
  end p1;

  procedure p2
  is
  begin
    dbug.enter('p2');
    sleep(1);
    p1;
    sleep(2);
    dbug.leave;
  end p2;

  procedure p3
  is
  begin
    dbug.enter('p3');
    sleep(3);
    p2;
    sleep(4);
    dbug.leave;
  end p3;
  $end
begin
$if dbug_profiler.c_testing $then
  ut_setup;

  dbug.activate('dbms_output');
  dbug.activate('profiler');

  p3;
  sleep(5); -- should not count
  p3;

  for r in (select * from table(dbug_profiler.show))
  loop
    dbms_output.put_line('module_name: ' || r.module_name);
    dbms_output.put_line('nr_calls: ' || r.nr_calls);
    dbms_output.put_line('elapsed_time: ' || r.elapsed_time);
    dbms_output.put_line('avg_time: ' || r.avg_time);

    if r.nr_calls = 2
    then
      null;
    else
      raise value_error;
    end if;

    if trunc(r.avg_time) = case r.module_name when 'p1' then 0 when 'p2' then 3 when 'p3' then 7 end
    then
      null;
    else
      raise value_error;
    end if;

    if trunc(r.elapsed_time, 3) = trunc(r.nr_calls * r.avg_time, 3)
    then
      null;
    else
      raise value_error;
    end if;
  end loop;

  ut_teardown;
$else
  raise program_error;
$end
end ut_test;

end dbug_profiler;
/

