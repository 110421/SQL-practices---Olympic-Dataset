 -- 10.Find the Ratio of male and female athletes participated in all olympic games.
 -- step 1 . find the number of male and femal participated in all olympic 
 -- step 2 . fetch the number of mal and female
 -- step 3 . create the ration
WITH t1 AS
(SELECT sex,count(sex) AS cnt
  FROM olympics_history
  GROUP BY sex),
 t2 AS 
 (SELECT  *,ROW_NUMBER () OVER(order by cnt) AS rn
    FROM t1
 ),
 min_cnt AS
 (
 SELECT cnt
   FROM t2
  WHERE rn = '1'),
  max_cnt AS
  (
  SELECT cnt
    FROM t2
   WHERE rn='2')
 SELECT concat('1: ',round(max_cnt.cnt :: decimal /min_cnt.cnt,2)) AS ratio
   FROM max_cnt,min_cnt;

 --  11. Fetch the top 5 athletes who have won the most gold medals.
 -- step 1 : filer the atheletes get GOld medals
 -- step 2 : count the number of gold medals each athaletes have 
 -- step 3 : fetch first 5 atheletes ( use dense_rank )
 SELECT *
   FROM olympics_history;
 WITH t1 AS
 (SELECT name,medal
   FROM olympics_history
   WHERE medal ='Gold'),
     t2 AS 
	 (SELECT name,COUNT(name) as num
	    FROM t1
	  GROUP BY name
	  Order by num DESC
	 ),
	 t3 AS 
	 (SELECT *, dense_rank() OVER(order by num desc) as rnk
	    FROM t2 
	 )
	 SELECT name,num,rnk
	   FROM t3
	   WHERE rnk <=5
	  ;
    
  -- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
  -- step 1 : fetch table with name of athelets,team and the number of medal the had,  
  -- step 2 : rank 5 most medal and fetch them 
  with t1 AS
  (SELECT name,medal,
   FROM olympics_history oh 
   JOIN olmpic
  WHERE medal IN ('Gold','Silver','Bronze')),
  t2 AS 
  (SELECT name, COUNT(medal) AS num_of_medals
     FROM t1
    GROUP BY name
  ORDER BY num_of_medals DESC ),
  t3 AS 
  (SELECT name, num_of_medals,dense_rank () over(order by num_of_medals DESC ) AS rnk
     FROM t2 
  )
  SELECT * 
    FROM t3 
	WHERE rnk <=5;
  SELECT name,medal
   FROM olympics_history;
   
   with t1 AS 
   (SELECT name,team, COUNT(name) AS num_of_medals
	  FROM olympics_history
	 WHERE medal IN ('Gold','Silver','Bronze' )
	GROUP BY name,team
	ORDER BY num_of_medals DESC
   ),
   t2 AS 
   ( SELECT name,team,num_of_medals,dense_rank () over (order by num_of_medals DESC ) AS rnk
	  FROM t1 
   )
   SELECT *
     FROM t2 
	 where rnk <=5;
	 
	 
-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
  -- step 1 : make a table  with team and total medals each team had 
  -- step 2 : rank 5 highest team 
  
  with t1 AS
  (SELECT team, COUNT(team) AS num_medals
     FROM olympics_history
   WHERE medal IN ('Gold','Silver','Bronze')
   GROUP BY team
   ORDER BY num_medals DESC
  ),
  t2 AS 
  (SELECT team,num_medals, dense_rank () over(order by num_medals DESC ) AS rnk 
     FROM t1 
  )
  SELECT *
    FROM t2
	WHERE rnk <=5;
	
	
-- 14. List down total gold, silver and bronze medals won by each country.
-- step 1: fetch a table with region and have all medals
-- step 2: join the region and contry table by NOC


SELECT country
,coalesce(bronze, 0) AS bronze
,coalesce(silver, 0) AS silver
,coalesce(gold, 0) AS gold
  FROM crosstab('SELECT nr.region AS country, 
          medal,COUNT(medal)
    FROM olympics_history oh 
	JOIN olympics_history_noc_regions nr 
	  ON nr.NOC = oh.NOC 
	WHERE medal<> ''NA''
	GROUP BY country,medal
	ORDER BY country,medal',
	'values (''Bronze''),(''Gold''),(''Silver'')'
  )
  
  AS result ( country varchar, Bronze bigint,Gold bigint,Silver bigint )
  order by gold desc,silver desc, bronze desc;
  
  
  -- 15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
  
	

				SELECT *
	  FROM olympics_history
	  
	  

  
  SELECT substring(game,1,position('-' in game) - 1) as game
  ,substring(game,position('-' in game) + 2) as country
  ,coalesce (gold,0) as gold
  ,coalesce (bronze,0) as bronze
  ,coalesce (silver,0) as silver
    
FROM crosstab('SELECT concat(games,'' - '',nr.region) as game,medal,count(medal)
  FROM olympics_history oh 
  JOIN olympics_history_noc_regions nr 
    ON nr.NOC = oh.NOC 
  WHERE medal <>''NA''
  GROUP BY game,medal
  ORDER BY game,medal',
	 'values (''Bronze''),(''Silver''),(''Gold'') '
	)
	AS result (game text,Bronze bigint,Silver bigint,Gold bigint)
	
	-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
	
-- lesson : first_value()over(partition by ... order by ...)

			WITH t1 AS(
				SELECT substring(game,1,position('-' in game) - 1) as game
                      ,substring(game,1,position('-' in game) + 2) as country
                      ,coalesce (gold,0) as gold
                      ,coalesce (bronze,0) as bronze
                      ,coalesce (silver,0) as silver
    
FROM crosstab('SELECT concat(games,'' - '',nr.region) as game,medal,count(medal)
  FROM olympics_history oh 
  JOIN olympics_history_noc_regions nr 
    ON nr.NOC = oh.NOC 
  WHERE medal <>''NA''
  GROUP BY game,medal
  ORDER BY game,medal',
	 'values (''Bronze''),(''Silver''),(''Gold'') '
	)
	AS result (game text,Bronze bigint,Silver bigint,Gold bigint))
	
	SELECT distinct game,
	concat(first_value(country) over(partition by game order by gold desc)
    			, ' - '
    			, first_value(gold) over(partition by game order by gold desc)) as Max_Gold
	,concat(first_value(country) over(partition by game order by silver desc)
    			, ' - '
    			, first_value(silver) over(partition by game order by silver desc)) as Max_Silver
	,concat(first_value(country) over(partition by game order by Bronze desc)
    			, ' - '
    			, first_value(Bronze) over(partition by game order by Bronze desc)) as Max_Bronze
	 			
	FROM t1 
	  ;
	
	  
	  

 SELECT substring(game,1,position('-' in game) -1) AS game, -- substring syntax SELECT SUBSTRING('SQL Tutorial', 1, 3) AS ExtractString;
        substring(game,position('-'in game) +2) AS country ,
		coalesce (gold,0) as gold , -- coalesce syntax to eliminate the null values
		coalesce (silver,0) as silver,
		coalesce ( bronze,0) as bronze
		
   FROM CROSSTAB('SELECT concat(games, '' - '',nr.region) as game,medal,count(medal)
 FROM olympics_history oh 
 JOIN olympics_history_noc_regions nr 
   ON nr.NOC = oh.NOC 
 WHERE medal <> ''NA''
 GROUP BY nr.region,games,medal
 ORDER BY nr.region,games',
'values (''Gold''),(''Silver''),(''Bronze'')') -- values means that we need the correct value into correct colum
 
 AS result (game text,Gold bigint,Silver bigint,Bronze bigint)
	  
	  
	     