-- practice sheet 
SELECT *
  FROM olympics_history;
SELECT * 
  FROM olympics_history_noc_regions;
  
-- Identify which country won the most gold, most silver and most bronze medals in each olympic games.

SELECT concat(games,'-',nr.region) AS game,medal,count(medal)
  FROM olympics_history oh 
  JOIN olympics_history_noc_regions nr 
    ON nr.NOC = oh.NOC
	WHERE medal <> 'NA'
	GROUP BY nr.region,games,medal
	ORDER BY game,medal
	
WITH t1 AS
(SELECT substring(game,1,position('-' in game) - 1) AS game
       , substring(game,position('-' in game) + 1) AS country 
	   ,coalesce(Gold, 0) AS Gold
	   ,coalesce(Silver, 0) AS Silver
	   ,coalesce(Bronze, 0) AS Bronze
  FROM crosstab(
  'SELECT concat(games,''-'',nr.region) AS game,medal,count(medal)
  FROM olympics_history oh 
  JOIN olympics_history_noc_regions nr 
    on nr.NOC = oh.NOC
	WHERE medal <>''NA''
	GROUP BY nr.region,games,medal
	ORDER BY game,medal',
  'values(''Bronze''),(''Silver''),(''Gold'')')
	
	AS result (game text,Bronze bigint,Silver bigint,Gold bigint))
	
SELECT distinct game --FIRST_VALUE ( scalar_expression )  OVER ([PARTITION BY partition_expression, ... ] ORDER BY sort_expression [ASC | DESC], ...)
, concat(first_value(country) over (partition by game order by gold desc),'-',first_value(gold) over (partition by game order by gold desc)) AS Max_gold
, concat(first_value(country) over (partition by game order by silver desc),'-',first_value(silver) over (partition by game order by silver desc)) AS Max_silver
, concat(first_value(country) over (partition by game order by bronze desc),'-',first_value(bronze) over (partition by game order by bronze desc)) AS Max_bronze
  FROM t1
  order by game;
  
  
  
with t2 AS
 (SELECT games,nr.region AS country,medal,count(medal) AS number_of_medal
    FROM olympics_history oh 
    JOIN olympics_history_noc_regions nr 
      ON oh.NOC = nr.NOC
  WHERE medal <>'NA'
    GROUP BY games,nr.region,medal
   ORDER BY games
  
),
 t3 AS (SELECT games,country,count(number_of_medal) AS number_of_medal
     FROM t2
   GROUP BY games,country)
   
 SELECT distinct games
   ,concat(first_value(country) over (partition by games order by number_of_medal DESC),'-', first_value(number_of_medal)over (partition by games order by number_of_medal DESC ))
     FROM t3 
	 ORDER BY games
	 
SELECT * 
 FROM olympics_history;
SELECT *
 FROM olympics_history_noc_regions;
 -- How many olympics games have been held?
 SELECT count(distinct games) AS number_of_games
   FROM olympics_history
   
   -- List down all Olympics games held so far
   SELECT distinct games
     FROM olympics_history
	 ORDER BY games;
	 
-- Mention the total no of nations who participated in each olympics game?
with t1 AS
(SELECT games, nr.region AS country,count(nr.region)
  FROM olympics_history oh 
  JOIN olympics_history_noc_regions nr
    ON nr.NOC = oh.noc
	GROUP BY games,nr.region
    ORDER BY games) 
SELECT games,count(country)
  FROM t1 
  GROUP BY games;
  
  
-- Which year saw the highest and lowest no of countries participating in olympics?

with t1 AS
(SELECT distinct games,count(distinct nr.region) AS num_country
  FROM olympics_history oh 
  JOIN olympics_history_noc_regions nr 
    ON nr.NOC = oh.NOC 
    GROUP BY games
	ORDER BY num_country)
	
SELECT distinct 
concat(first_value(games) over(order by num_country ),'-',first_value(num_country) over(order by num_country)) AS lowest_num 
,concat(first_value(games) over(order by num_country DESC ),'-',first_value(num_country) over(order by num_country DESC)) AS highest_num 
  FROM t1 
  order by 1
  
  -- Which nation has participated in all of the olympic games?
  with t1 AS
  (SELECT distinct  nr.region AS country, games 
    FROM olympics_history oh 
	JOIN olympics_history_noc_regions nr 
	  ON nr.NOC = oh.NOC ),
	t2 AS 
	(SELECT country,count(games) AS num_games
	   FROM t1
	 GROUP BY country),
	 
    t3 AS 
	(SELECT count(distinct games) AS numgame
	   FROM olympics_history
	  
	)
SELECT * 
  FROM t2
  JOIN t3 
    ON t3.numgame=t2.num_games;
	
	
--	Identify the sport which was played in all summer olympics

with t1 AS
(SELECT distinct sport,games
  FROM olympics_history
  WHERE games like '%Summer%'
  ORDER BY games),
 t2 AS 
 (SELECT sport,count(games) AS num_sport
    FROM t1
   GROUP BY sport
 ),
 t3 AS
 (SELECT count(distinct games) AS num_Sum
    FROM olympics_history
  WHERE season ='Summer'
 )
 
 SELECT sport
   FROM t2
   JOIN t3 
     ON t3.num_Sum = t2.num_sport
	
-- Which Sports were just played only once in the olympics
SELECT sport,games
  FROM  olympics_history
  
	
 