SELECT * FROM olympics_history;
SELECT * FROM olympics_history_noc_regions;

-- 1. How many olympics games have been held?
SELECT COUNT(distinct games)
  FROM olympics_history;
  
  
--  List down all Olympics games held so far.
SELECT DISTINCT year,season,city
  FROM olympics_history
  ORDER BY year ;
  
-- 3. Mention the total no of nations who participated in each olympics game?

WITH all_countries AS(
	SELECT games,n.region
  FROM olympics_history_noc_regions n 
 JOIN  olympics_history o
    ON n.noc = o.noc
	GROUP BY games,n.region
	)

SELECT games, count(region)
  FROM all_countries
  GROUP BY games
  ORDER BY games;
--- 4.Which year saw the highest and lowest no of countries participating in olympics


WITH a AS
(SELECT games,nr.region
   FROM olympics_history_noc_regions nr
   JOIN olympics_history oh
     ON nr.noc = oh.noc
 	GROUP BY games,nr.region )
	,
b AS 
	(
	SELECT games,COUNT(region) as num
	   FROM a 
	 GROUP BY games
	 
	)
SELECT DISTINCT 
concat(first_value(games) over (order by num),
	   ' - ',
	  first_value(num) over(order by num)) as lowest_numcountry,
concat(first_value(games) over (order by num desc),
	  ' - ',
	  first_value(num) over (order by num desc)) as highest_numbercountry
  FROM b;
  
  --- 5. Which nation has participated in all of the olympic games ?
  SELECT 
    FROM ol
	