use role sysadmin;
use warehouse compute_wh;
use schema cricket.clean;

--step-1
--the meta column has no real domain value, and it just capture the JSON file version. Since it is an object data type.
--here is the select statement that can extract each element.
--extract element from object data type
select 
    meta['data_version']::text as data_version,
    meta['created']::date as created,
    meta['revision']::number as revision
from
    cricket.raw.match_raw_tbl;

--step-2 extract elements from info column that is of variant data type
--it has a lot of imp info, and we need to analyse them.

select
    info:match_type_number::int as match_type_number,
    info:match_type::text as match_type,
    info:season::text as season,
    info:team_type::text as team_type,
    info:overs::text as overs,
    info:city::text as city,
    info:venue::text as venue
from
    cricket.raw.match_raw_tbl;
----

create or replace transient table cricket.clean.match_detail_clean as
select
    info:match_type_number::int as match_type_number,
    info:event.name::text as event_name,
    case
    when
        info:event.match_number::text is not null then info:event.match_number::text
    when
        info:event.stage::text is not null then info:event.stage::text
    else
        'NA'
    end as match_stage,

    info:dates[0]::date as event_date,
    date_part('year',info:dates[0]::date)as event_year,
    date_part('month',info:dates[0]::date)as event_month,
    date_part('day',info:dates[0]::date)as event_day,
    info:match_type::text as match_type,
    info:season::text as season,
    info:team_type::text as team_type,
    info:overs::text as overs,
    info:city::text as city,
    info:venue::text as venue,
    info:teams[0]::text as first_team,
    info:teams[1]::text as second_team,
    case
        when info:outcome.winner is not null then 'Result declared'
        when info:outcome.result='tie' then 'Tie'
        when info:outcome.result='no result' then 'No Result'
        else info:outcome.result
    end as match_result,
    case
        when info:outcome.winner is not null then info:outcome.winner
        else 'NA'
    end as winner,
    info:toss.winner::text as toss_winner,
    initcap(info:toss.decision::text) as toss_decision,
    --
    stg_file_name,
    stg_file_number,
    stg_file_hashkey,
    stg_modified_ts
from
    cricket.raw.match_raw_tbl;
    