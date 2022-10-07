--17.Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

SELECT * 
  FROM olympics_history;
SELECT * 
  FROM olympics_history_noc_regions;

SELECT  games,nr.region,medal,count(medal)
  FROM olympics_history oh 
  JOIN olympics_history_noc_regions nr 
    ON nr.NOC = oh.NOC 
 WHERE medal <> 'NA'
 GROUP BY games,nr.region,medal
 ORDER BY games,nr.region
 
 SELECT games,nr.region, COUNT(medal)
   FROM olympics_history oh 
   JOIN olympics_history_noc_regions nr
     ON nr.NOC = oh.NOC 
  WHERE medal <>'NA'
  GROUP BY games,nr.region
  ORDER BY games,nr.region

 with t1 AS(
			SELECT substring(game,1,position('-' in game) -1) AS game
       ,substring(game,position('-' in game) +1) AS country 
	   ,coalesce(bronze,0) as bronze
	   ,coalesce(silver,0) as silver
	   ,coalesce(gold,0) AS gold 
   FROM CROSSTAB('SELECT concat(games,''-'',nr.region) as game,medal,count(medal)
  FROM olympics_history oh 
  JOIN olympics_history_noc_regions nr 
    ON nr.NOC = oh.NOC  
 WHERE medal <>''NA''
 GROUP BY games,nr.region,medal
 ORDER BY game,medal'
   ,'values (''Bronze''),(''Silver''),(''Gold'')')
   AS result (game text, Bronze bigint,silver bigint,gold bigint)),
   
 t2 AS 
 (SELECT games,nr.region, COUNT(medal) AS total
   FROM olympics_history oh 
   JOIN olympics_history_noc_regions nr
     ON nr.NOC = oh.NOC 
  WHERE medal <>'NA'
  GROUP BY games,nr.region
  ORDER BY games,nr.region
 )
   
 SELECT distinct t1.game
 ,concat(first_value(country) over (partition by t1.game order by gold desc),'-',first_value(gold) over (partition by t1.game order by gold desc)) AS Max_gold 
 ,concat(first_value(country) over (partition by t1.game order by silver desc),'-',first_value(silver) over (partition by t1.game order by silver desc)) AS Max_silver
 ,concat(first_value(country) over (partition by t1.game order by bronze desc),'-',first_value(bronze)over(partition by t1.game order by bronze desc)) AS Max_Bronze
 ,concat(first_value(country) over (partition by t2.games order by total desc),'-',first_value(total) over (partition by t2.games order by total desc)) AS Max_total 
   FROM t1
   JOIN t2
     ON t2.games = t1.game
   ORDER BY t1.game;
   
 --18.Which countries have never won gold medal but have won silver/bronze medals?
 SELECT nr.region,medal,count(medal)
   FROM olympics_history oh 
   JOIN olympics_history_noc_regions nr 
     ON nr.NOC = oh.NOC 
  WHERE medal <>'NA'
  GROUP BY nr.region,medal
  ORDER BY nr.region,medal
  
  SELECT region,
         coalesce(bronze,0) AS bronze 
		 ,coalesce(silver,0) AS silver 
		 ,coalesce(gold,0) AS gold 
    FROM CROSSTAB
	('SELECT nr.region,medal,count(medal)
   FROM olympics_history oh 
   JOIN olympics_history_noc_regions nr 
     ON nr.NOC = oh.NOC 
  WHERE medal <>''NA''
  GROUP BY nr.region,medal
  ORDER BY nr.region,medal',
	'values(''Bronze''),(''Silver''),(''Gold'')')
	AS result (region varchar,Bronze bigint,Silver bigint,Gold bigint)
	
	
with t1 AS 
(SELECT region,
         coalesce(bronze,0) AS bronze 
		 ,coalesce(silver,0) AS silver 
		 ,coalesce(gold,0) AS gold 
    FROM CROSSTAB
	('SELECT nr.region,medal,count(medal)
   FROM olympics_history oh 
   JOIN olympics_history_noc_regions nr 
     ON nr.NOC = oh.NOC 
  WHERE medal <>''NA''
  GROUP BY nr.region,medal
  ORDER BY nr.region,medal',
	'values(''Bronze''),(''Silver''),(''Gold'')')
	AS result (region varchar,Bronze bigint,Silver bigint,Gold bigint))
SELECT region,gold,silver,bronze
    FROM t1 
   WHERE (gold = '0'AND
   silver <> '0'AND bronze <>'0')
   ORDER BY bronze DESC,silver 
 
   
