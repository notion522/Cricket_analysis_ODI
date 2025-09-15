--score card for team  A with match_id = 4680
select 
    OVERS_PLAYED_BY_TEAM_A as Team_A_overs 
from 
    cricket.consumption.match_fact
where
    match_id=4680;

--score card for team  B with match_id = 4680
select 
    OVERS_PLAYED_BY_TEAM_B as Team_B_overs 
from 
    cricket.consumption.match_fact
where
    match_id=4680;

--total runs scored by team A and b with match_id = 4680(there are multiple versions that i was trying)
--v1
select 
    sum(runs)
from 
    cricket.consumption.delivery_fact 
join cricket.consumption.match_fact
on cricket.consumption.delivery_fact.team_id = cricket.consumption.match_fact.team_a_id
    where
    cricket.consumption.delivery_fact.match_id=4680;
--v2
select 
    tA.team_name as team_a,
    tB.team_name as team_b,
    full_dt 
from 
    cricket.consumption.match_fact f
join 
    cricket.consumption.date_dim d 
    on f.date_id=d.date_id
join 
    cricket.consumption.team_dim tA 
    on f.team_a_id=tA.team_id
join 
    cricket.consumption.team_dim tB on 
    f.team_b_id=tB.team_id
where match_id=4680;

select team_id,runs from cricket.consumption.delivery_fact
where match_id=4680;

--v3

SELECT 
    tA.team_name AS team_a,
    tB.team_name AS team_b,
    d.full_dt,
    df.team_id,
    sum(df.runs)
FROM cricket.consumption.match_fact f
JOIN cricket.consumption.date_dim d 
    ON f.date_id = d.date_id
JOIN cricket.consumption.team_dim tA 
    ON f.team_a_id = tA.team_id
JOIN cricket.consumption.team_dim tB 
    ON f.team_b_id = tB.team_id
JOIN cricket.consumption.delivery_fact df 
    ON f.match_id = df.match_id
WHERE f.match_id = 4680;

--v4

SELECT 
    td.team_name AS scoring_team,
    SUM(df.runs) AS total_runs
FROM cricket.consumption.match_fact f
JOIN cricket.consumption.delivery_fact df 
    ON f.match_id = df.match_id
JOIN cricket.consumption.team_dim td 
    ON df.team_id = td.team_id
WHERE f.match_id = 4680
GROUP BY
    td.team_name;

--runs made by the players in ODI
select player_name, t.team_name , sum(m.runs) as total_runs_made,sum(extra_runs) as extra_runs_made
from cricket.consumption.delivery_fact m
join cricket.consumption.player_dim p on m.batter_id=p.player_id
join cricket.consumption.team_dim t on m.team_id=t.team_id
group by player_name,team_name
order by sum(m.runs) desc;

--count of matches per venue
select venue_name, count(match_id)
from cricket.consumption.match_fact m
join cricket.consumption.venue_dim v on m.venue_id=v.venue_id
group by venue_name;

--no.of wins by each team
select t.team_name,count(winner_team_id)
from cricket.consumption.match_fact m 
join cricket.consumption.team_dim t
on m.winner_team_id=t.team_id
group by t.team_name,m.winner_team_id
order by count(*) desc;

--toss decision in winning matches
--v1
select player_name, t.team_name , sum(m.runs) as total_runs_made,sum(extra_runs) as extra_runs_made
from cricket.consumption.delivery_fact m
join cricket.consumption.player_dim p on m.bowler_id=p.player_id
join cricket.consumption.team_dim t on m.team_id=t.team_id
group by player_name,team_name
order by sum(m.runs) desc;

--v2
select t.team_name,toss_decision,count(toss_decision) 
from cricket.consumption.match_fact m
join cricket.consumption.team_dim t on m.winner_team_id=t.team_id
group by toss_decision,team_name
order by toss_decision,count(toss_decision) desc;

