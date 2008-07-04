set pagesize 0 feedback off linesize 2000 trimspool on

select  ltexte
from    tlog
where   ltexte not like '%Purge by user:%'
order by
        id
/

set termout off

truncate table tlog;
