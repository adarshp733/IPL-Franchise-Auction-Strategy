-- id	city	date	player_of_match	venue	neutral_venue	team1	team2	toss_winner	
-- toss_decision	winner	result	result_margin	eliminator	method	umpire1	umpire2

Drop table IPL_Matches
CREATE TABLE IPL_Matches(
   Id INTEGER PRIMARY KEY, City VARCHAR, Date DATE, Player_Of_Match VARCHAR, Venue VARCHAR,
   Neutral_Venue int, Team1 VARCHAR, Team2 VARCHAR, Toss_Winner VARCHAR, Toss_Decision VARCHAR, 
   Winner VARCHAR, Result VARCHAR, Result_Margin INTEGER, Eliminator VARCHAR, Method VARCHAR, 
   Umpire1 VARCHAR, Umpire2 VARCHAR);
   
copy Ipl_matches from 'D:\STUDY MATERIAL\IPGP\SQL\IPL Dataset\IPL_matches.csv' delimiter ',' csv header;

Select * from Ipl_Matches;
						
-- id	inning	over	ball	batsman	non_striker	bowler	batsman_runs	extra_runs	total_runs	
-- is_wicket	dismissal_kind	player_dismissed	fielder	extras_type	batting_team	bowling_team

Create table IPL_Balls(id INTEGER, inning int, over int, ball int, batsman varchar, 
					   non_striker varchar,	bowler varchar, batsman_runs int, extra_runs int, total_runs int,
					   is_wicket int, dismissal_kind varchar, player_dismissed varchar, fielder varchar, 
					   extras_type	varchar, batting_team varchar, bowling_team varchar);
					   
copy Ipl_Balls from 'D:\STUDY MATERIAL\IPGP\SQL\IPL Dataset\IPL_Ball.csv' delimiter ',' csv header;			

Select * from Ipl_Balls;
Select * from Ipl_matches;

/* Your first priority is to get 2-3 players with high S.R who have faced at least 500 balls.And
 to do that you have to make a list of 10 players you want to bid in the auction so that
 when you try to grab them in auction you should not pay the amount greater than you
 have in the purse for a particular player.
 
 (strike rate is total runs scored by batsman divided by number of balls faced but remember
 when extras_type is 'wides' it is not counted as a ball faced neither counted as batsmen runs
*/

SELECT Batsman, SUM(batsman_runs) as Total_Runs, Count(ball) as Total_Balls,
Round((sum(batsman_runs)*1.0 / COUNT(ball)) * 100,2) AS batsman_sr
FROM Ipl_balls
WHERE extras_type not in ('wides')
GROUP BY batsman HAVING COUNT(ball) > 500 ORDER BY batsman_sr DESC
LIMIT 10;

 /* Now you need to get 2-3 players with good Average who have played more than 2 ipl
 seasons. And to do that you have to make a list of 10 players you want to bid in the
 auction so that when you try to grab them in auction you should not pay the amount
 greater than you have in the purse for a particular player.
 (Average is calculated as total runs scored divided by number of times batsman has been
 dismissed which can be calculated using wicket_ball field as 1 indicates out and 0 indicates not
 out, a batsman should’ve been dismissed at least once to calculate the sr i.e., you can exclude
 those players who have not been dismissed once */
 
 Select Batsman, COUNT(distinct id) as Total_Match, SUM(batsman_runs) as Total_Runs, 
 Round(SUM(batsman_runs)*1.0/sum(is_wicket),2) as Average from Ipl_balls 
 Group by Batsman Having SUM(is_wicket) > 2 AND COUNT(distinct id) > 28 Order By Average DESC LIMIT 10;
 
--   Now you need to get 2-3 Hard-hitting players who have scored most runs in boundaries
--  and have played more the 2 ipl season. To do that you have to make a list of 10 players
--  you want to bid in the auction so that when you try to grab them in auction you should
--  not pay the amount greater than you have in the purse for a particular player.
--  (only 4 and 6 will be counted as boundaries so calculate how many 4 and 6 has been hit by
--  each batsman and also calculate total runs scored to get the output as boundary percentage
--  which will be runs in boundary divided by total runs scored)

Select Batsman, Round(Sum(Case When batsman_runs in (4,6) 
						  Then batsman_runs else 0 END)* 1.0 / SUM(batsman_runs)*100 , 2)
						  AS BOUNDRY_PERCENTAGE FROM IPL_BALLS
						  Where extras_type NOT IN ('wides') GROUP BY batsman 
						  HAVING COUNT(DISTINCT id) > 28 
						  ORDER BY BOUNDRY_PERCENTAGE DESC
						  LIMIT 10;
-- Q4

Select Bowler, ROUND(SUM(total_runs)/(COUNT(bowler)/6.0), 2) as Economy FROM Ipl_Balls 
Group By Bowler Having count(bowler) > 500 Order By Economy Limit 10;
 
-- Q5

Select * from Ipl_Balls;
Select * from Ipl_matches;

Select a.bowler,Round((a.total_balls/(a.total_wickets*1.0)),2) as Balling_SR
from (select bowler, Sum(case when is_wicket=1 then 1 else 0 end) as total_wickets,
count(ball) as Total_balls
from IPL_balls group by bowler) as a
where Total_balls>=500 order by Balling_SR asc limit 10;

-- Q6
Select a.Batsman AS All_Rounder,
a.Batting_SR AS Batting_SR,
b.Balling_SR AS Balling_SR FROM
(SELECT Batsman, Round((sum(batsman_runs)*1.0 / COUNT(ball)) * 100,2) AS Batting_SR
from IPL_balls group by batsman having count (ball)>=500 order by Batting_SR desc) as a
JOIN
(SELECT bowler, Round(count(ball)*1.0/sum(case when is_wicket=1 then 1 else 0 end),2) as Balling_SR 
from IPL_balls group by bowler having count(ball)>=300 order by Balling_SR asc) as b
on a.Batsman = b.Bowler limit 10;


select a.batsman as All_Rounder, a.strike_rate, b.Bowler_SR
from
(select batsman, Round((sum(batsman_runs)*1.0 / COUNT(ball)) * 100,2) as Batting_SR
From IPL_balls group by batsman having count(ball)>=500 order by Batting_SR desc) AS a
JOIN
(select bowler, Sum(case when is_wicket=1 then 1 else 0 end) as total_wickets,
count(ball) as Total_balls from Ipl_balls group by bowler 
having count(ball)>=300 order by Bowler_SR asc) as b
on a.batsman=b.bowler limit 10;


select a.batsman as allrounder,cast(a.batting_sr as decimal(4,1)), 
cast(b.bowling_sr as decimal(3,1)) from bats_sr as a inner join bowl_sr as b on a.batsman=b.bowler 
where batting_sr>150 and bowling_sr<21;

SELECT a.batsman AS All_Rounder, a.batsman_sr, b.bowling_sr
FROM IPL_BALLS a
LEFT JOIN IPL_MATCHES b ON a.batsman = b.bowler
ORDER BY a.batsman_sr DESC,
b.bowling_sr ASC
LIMIT 10;


-- Additional Questions
Select * from ipl_matches;
Select * from ipl_balls;
Select Count(Distinct city) AS City_Counts from ipl_matches;

CREATE TABLE Deliveries_v02 AS
	SELECT *,
		CASE
			WHEN total_runs >= 4 THEN 'boundary'
			WHEN total_runs  = 0 THEN 'dot'
			ELSE 'other'
		END AS ball_result
	FROM IPL_balls;

Select * from deliveries_v03;

--  Write a query to fetch the total number of boundaries and dot balls from the
--  deliveries_v02 table.

SELECT Ball_Result, COUNT(Ball_Result) FROM Deliveries_v02 GROUP BY Ball_Result;


Select Batting_Team as Teams, Count(Ball_result) AS Boundary from Deliveries_v02 
where Ball_result='boundary' Group By Teams order by Boundary desc;

SELECT Batting_Team AS Teams, COUNT(Ball_result) AS Dot_Balls FROM Deliveries_v02 
WHERE Ball_result='dot' Group By Teams ORDER BY Dot_Balls DESC;

-- Write a query to fetch the total number of dismissals by dismissal kinds where dismissal
-- kind is not NA

SELECT COUNT(dismissal_kind) AS Disimissal_Kind_NA_Count FROM Deliveries_v02 WHERE dismissal_kind != 'NA';

-- Write a query to get the top 5 bowlers who conceded maximum extra runs from the
-- deliveries table

SELECT Bowler, SUM(extra_runs) AS Total_Extra_Runs FROM Deliveries_v02 
GROUP BY Bowler ORDER BY Total_Extra_Runs DESC LIMIT 5;

-- Write a query to create a table named deliveries_v03 with all the columns of
-- deliveries_v02 table and two additional column (named venue and match_date) of venue
-- and date from table matches

CREATE TABLE deliveries_v03 AS
	SELECT d.*,	m.venue, m.date AS Match_date
	FROM deliveries_v02 d LEFT JOIN	IPL_Matches m ON d.id = m.id;
DRop table deliveries_v03
Select * From deliveries_v03;

-- 9. Write a query to fetch the total runs scored for each venue and order it in the descending
-- order of total runs scored.

SELECT Venue, Sum(Total_runs) AS Total_Runs FROM deliveries_v03 
GROUP BY Venue ORDER BY Total_Runs DESC;



-- 10. Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the
-- descending order of total runs scored.

SELECT YEAR(match_date) as YEAR, Sum(Total_runs) AS Total_Runs FROM deliveries_v03 
WHERE Venue='Eden garden';

SELECT Extract(YEAR from match_date) AS Year, SUM(Total_runs) AS RUNS_SCORED_IN_EDEN_GARDEN
FROM deliveries_v03
WHERE venue = 'Eden Gardens'
GROUP BY Year
ORDER BY RUNS_SCORED_IN_EDEN_GARDEN DESC;



						
						