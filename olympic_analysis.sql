-- 1. How many olympics games have been held?
SELECT COUNT(distinct games) AS number_of_games
 FROM athlete_events;



--2. List down all Olympics games held so far. ( which year / kind of olympic /which city are held)
SELECT distinct year,season,city
  FROM athlete_events;


--3.Mention the total no of nations who participated in each olympics game?

  -- join 2 table to select the distinct region( country) 
  -- count number of region for each group games
with all_countries as 
(SELECT games,o.region
FROM athlete_events as a
JOIN olympics_history_noc_regions as o
on a.NOC=o.NOC
group by games,o.region)

SELECT games,count(games) as num_countries
FROM all_countries
GROUP BY games;



--4. Which year saw the highest and lowest no of countries participating in olympics
     -- fetch the table wwhich games and the number of countries take part in for each games
	 -- fetch from that table the lowest and higest number of countries
with all_countries as 
   (SELECT games,o.region
      FROM athlete_events as a
      JOIN olympics_history_noc_regions as o
        on a.NOC=o.NOC
  group by games,o.region),

     tot_countries as
   (SELECT games,count(games) as num_countries
      FROM all_countries
  GROUP BY games
    )

SELECT distinct 
       concat(first_value(games) over(order by num_countries),'-',first_value(num_countries) over(order by num_countries)) as lowest_num
        ,
       concat(first_value(games) over(order by num_countries desc),'-',first_value(num_countries) over( order by num_countries desc)) as highest_num
  FROM tot_countries;
;

--5. Which nation has participated in all of the olympic games ?
    --- create a table1 with country and the number of times each country took part in the olympic games
	--- creat a table2 count total number of olympic games were held 
	--- join 2 tables at the number games of table2 --> we have the country took part in all olympic game.
with all_countries as 
    (SELECT games,region
       FROM athlete_events as a
       JOIN olympics_history_noc_regions as o
         on a.NOC=o.NOC
   group by games,region),

    tot_attending as 
     (SELECT region,count(region) as num_attending
        FROM all_countries
    GROUP BY region),
	num_games as 
	( SELECT count(distinct games) as num_game
	    FROM athlete_events)

SELECT *
  FROM tot_attending as t
  JOIN num_games as n
  on t.num_attending=n.num_game;


-- 6.  Identify the sport which was played in all summer olympics.
 --- fetch the table1 include sport and the game which just in summer
 --- count the number of appearance of each sport in table1
 --- count total number of summer game in table3
 --- math  table2 and tabble3 at the number of summer game 
 with summer_sport as 
   (SELECT sport,games
      FROM athlete_events
  group by sport,games
    HAVING games like'%summer%'
    ),
     num_sport_summer as
      (SELECT sport,count(sport)as num_sport_summer
         FROM summer_sport
	 group by sport),
     num_summer_game as 
      (SELECT count(distinct games) as  num_summer_game
         FROM athlete_events
        WHERE games like '%summer%')

SELECT *
  FROM num_sport_summer as sp 
  JOIN num_summer_game  as gm
  on sp.num_sport_summer=gm.num_summer_game;


--7.Which Sports were just played only once in the olympics.
with sport_games as 
    (SELECT sport,games
       FROM athlete_events
   GROUP BY sport,games),
 sport_num as 
    (SELECT sport, count(sport) as num_sport 
     FROM sport_games
	 GROUP BY sport),
 one_attending as 
 (SELECT sport,first_value(num_sport) over(order by sport) as num_attending
  FROM sport_num)

SELECT a.sport,num_attending,games
  FROM athlete_events as a
  JOIN one_attending as one
  on a.sport = one.sport


-- 8. Fetch the total no of sports played in each olympic games.
SELECT  games,count(distinct sport) AS number_sport
  FROM athlete_events
  GROUP BY games;

--9. Fetch oldest athletes to win a gold medal
with gold_age as 
(SELECT age,name,medal
  FROM athlete_events
  WHERE medal like 'Gold'AND age is not NULL
  ),
rank as 
(SELECT *,rank() over(order by age desc) as rnk
  FROM gold_age) 

  SELECT *
    FROM rank
   WHERE rnk=1;



 