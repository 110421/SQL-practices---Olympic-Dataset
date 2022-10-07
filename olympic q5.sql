--- 5. Which nation has participated in all of the olympic games
  
with tot_games AS
(SELECT COUNT(distinct games) AS total_games
   FROM olympics_history), -- 1. find out total games of olympic 
     countries AS 
	 (SELECT games,nr.region as country
	    FROM olympics_history oh
	    JOIN olympics_history_noc_regions nr 
	      ON oh.noc = nr.noc 
	   GROUP BY games,nr.region), --2. join to connect noc from 2 tables 
	 participate_country AS
	 (SELECT country,COUNT(1) AS participate_country_total
	    FROM countries
	  GROUP BY country
	  
	 )
	 SELECT pc.* --- step 3 : match the number of olympic games and the numbers participation of nations
	   FROM participate_country pc 
	   JOIN tot_games tg
	     ON pc.participate_country_total = tg.total_games
		 order by 1;
	  

--6. Identify the sport which was played in all summer olympics.
  --step 1. find the total summer games 
  -- step 2. find for each sport , how many games they play in 
  -- step 3 . compare 1&2
  WITH t1 AS
   (SELECT COUNT(distinct games) AS num_games
  FROM olympics_history
   WHERE season = 'Summer'),
   t2 AS
   (SELECT sport,COUNT(distinct games) AS num_sport
  FROM olympics_history
  WHERE season = 'Summer'
   GROUP BY sport)
   
SELECT *
  FROM t2
  JOIN t1 
    ON t2.num_sport = t1.num_games
	;
-- 7. Which Sports were just played only once in the olympics?
 -- step 1. find how many games a sport play in 
 -- compare with number 1
 
WITH t1 AS 
(
	SELECT  sport,COUNT(distinct games) AS numofgame
   FROM olympics_history
   GROUP BY sport
)
  SELECT t1.*,oh.games
   FROM t1 
   LEFT JOIN olympics_history oh
     ON t1.sport = oh.sport
   WHERE numofgame ='1'
   ;
 -- 8. Fetch the total no of sports played in each olympic games.
 --step 1. 

SELECT distinct games, COUNT(distinct sport) AS nu_of_sport
   FROM olympics_history
   GROUP BY games 
   ORDER BY nu_of_sport DESC;
  
-- 9. Fetch oldest athletes to win a gold medal
SELECT name,sex,cast(case when age = 'NA' then '0' else age end as int) as age
              ,team,games,city,sport, event, medal
  FROM olympics_history
  WHERE medal ='Gold' 
  ORDER BY age DESC;
  

  SELECT * 
     FROM olympics_history;