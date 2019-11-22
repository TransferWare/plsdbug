set pagesize 0 feedback off linesize 2000 trimspool on

select  ltext
from    tlog
where   ltext not like '%Purge by user:%'
order by
        id
/

set termout off

truncate table tlog;
