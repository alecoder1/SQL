USE portfolioprojects;
SELECT * FROM OLYMPICS_HISTORY oh;
SELECT * FROM OLYMPICS_HISTORY_NOC_REGIONS ohnr ;

SELECT COUNT(*)
FROM OLYMPICS_HISTORY oh ;

SELECT COUNT(*)
FROM OLYMPICS_HISTORY_NOC_REGIONS ohnr ;

-- Q1. iDENTIFY THE SPORT WHICH WAS PLAYED IN ALL SUMMER OLYMPICS
-- columns  sport,games(summer olympics)

1. Find total NO OF summer olympic games
2. Find FOR EACH sport, how many games were played IN.
3. Compare 1 & 2

WITH t1 AS
        (SELECT  count(DISTINCT games) AS total_summer_games
        FROM OLYMPICS_HISTORY oh 
        WHERE season = 'Summer'), -- NO OF distinct games during summer
    t2 AS 
        (SELECT DISTINCT sport, games , year-- fetches the data from sports AND games COLUMN 
        FROM OLYMPICS_HISTORY oh
        WHERE season = 'Summer'),
    t3 AS 
        (SELECT sport, count(games) AS no_of_games , year
        FROM t2
        GROUP BY sport
        ORDER BY YEAR DESC)
        
SELECT  * 
FROM t3
JOIN t1 ON t1.total_summer_games = t3.no_of_games;

SELECT * FROM OLYMPICS_HISTORY oh; -- noc
SELECT * FROM OLYMPICS_HISTORY_NOC_REGIONS ohnr ; -- noc


--Q11. Fetch the top 5 athletes who won the most gold medals
-- colums= name, medals + top 5 by ranking

WITH t1 AS 
      (SELECT name, team, games, YEAR, medal, COUNT(1) AS total_medals
      FROM OLYMPICS_HISTORY oh
      WHERE medal = 'Gold'
      GROUP BY name),
     t2 AS 
     ( SELECT *, RANK() OVER (ORDER BY total_medals desc) AS rnk
     FROM t1)
     
SELECT *
FROM t2 
WHERE rnk <= 5;


-- Q13. List down total gold, silver, AND bronze medals won BY EACH country

SELECT ohnr.region AS country, medal, COUNT(1) AS total_medals 
FROM OLYMPICS_HISTORY oh 
JOIN OLYMPICS_HISTORY_NOC_REGIONS ohnr 
ON oh.noc = ohnr.noc
WHERE medal <> 'NA'
GROUP BY country
ORDER BY total_medals;

CREATE extension tablefunc;



   -- SELECT country
   -- , COALESCE (gold, 0) AS gold 
   -- , COALESCE (silver, 0) AS silver 
   -- , COALESCE (bronze, 0) AS bronze 
   -- FROM crosstab ab  ('SELECT ohnr.region AS country, medal, COUNT(1) AS total_medals 
   --                FROM OLYMPICS_HISTORY oh 
   --                JOIN OLYMPICS_HISTORY_NOC_REGIONS ohnr 
   --                ON oh.noc = ohnr.noc
   --                WHERE medal <> ''NA''
   --                GROUP BY ohnr.region, medal
   --                ORDER BY ohnr.region, medal',
   --                'values (''Bronze''), (''Gold''), (''Silver'')')
   --       AS RESULT (country varchar, bronze int, gold bigint, silver bigint)
   -- ORDER BY gold DESC, silver DESC, bronze DESC;


-- "19/08/2023" The error you're encountering is because the crosstab function you're trying to use is not a standard SQL function and is not supported in SQLite. Instead, you can achieve the same result using standard SQL with conditional aggregation.

SELECT ohnr.region AS country,
       COALESCE(SUM(CASE WHEN oh.medal = 'Gold' THEN 1 ELSE 0 END), 0) AS gold,
       COALESCE(SUM(CASE WHEN oh.medal = 'Silver' THEN 1 ELSE 0 END), 0) AS silver,
       COALESCE(SUM(CASE WHEN oh.medal = 'Bronze' THEN 1 ELSE 0 END), 0) AS bronze
FROM OLYMPICS_HISTORY oh
JOIN OLYMPICS_HISTORY_NOC_REGIONS ohnr ON oh.noc = ohnr.noc
WHERE oh.medal <> 'NA'
GROUP BY ohnr.region
ORDER BY gold DESC, silver DESC, bronze DESC;






-- Q16. Identify which country won the most gold, silver and bronze medals in each olympic games.

-- Search for corresponding functions for substrings and their position.

-- select position(' - ' in '1896 Summer - Australia')

SELECT SUBSTRING('1896 Summer - Australia', 15); 
-- '1896 Summer - Australia'


WITH TEMP AS
(      SELECT substring (games_country, 1, POSITION(' - ' IN games_sountry) - 1)
      AS games
      , substring (games_country, 1, POSITION(' - ' IN games_sountry) + 3)
      AS games      
      
      , COALESCE (gold, 0) AS gold 
      , COALESCE (silver, 0) AS silver 
      , COALESCE (bronze, 0) AS bronze 
      FROM crosstab ('SELECT CONCAT(games, '' - '', ohnr.region) AS games_country, medal, COUNT(1) AS total_medals 
                  FROM OLYMPICS_HISTORY oh 
                  JOIN OLYMPICS_HISTORY_NOC_REGIONS ohnr 
                  ON oh.noc = ohnr.noc
                  WHERE medal <> ''NA''
                  GROUP BY games, ohnr.region, medal
                  ORDER BY games, ohnr.region, medal',
                  'values (''Bronze''), (''Gold''), (''Silver'')')
               AS RESULT (games_country varchar, bronze int, gold bigint, silver bigint) 
      ORDER BY games_country)
SELECT DISTINCT games
-- for gold 
, concat (first_value (country) OVER (PARTITION BY games ORDER BY gold DESC)
         , ' - '
         , first_value (gold) OVER (PARTITION BY games ORDER BY gold DESC) AS gold)
-- for silver 
, concat (first_value (country) OVER (PARTITION BY games ORDER BY silver DESC)
         , ' - '
         , first_value (silver) OVER (PARTITION BY games ORDER BY silver DESC) AS silver)
-- for bronze 
, concat (first_value (country) OVER (PARTITION BY games ORDER BY bronze DESC)
         , ' - '
         , first_value (bronze) OVER (PARTITION BY games ORDER BY bronze DESC) AS bronze)
FROM TEMP 
ORDER BY games;




-- SQLite does not support some advanced SQL features like the crosstab function or window functions used in your query.

-- To achieve the result you want in SQLite, you will need to use a different approach, such as subqueries and common table expressions (CTEs) without the use of advanced functions.

-- In this query:
-- 1. We first calculate medal counts for each country in each set of games.
-- 2. Then, we use common table expressions (CTEs) to rank the countries based on gold, silver, and bronze medals within each set of games using window functions.
-- 3. Finally, we select the top-ranked countries for each set of games based on their gold, silver, or bronze medal counts.

WITH MedalCounts AS (
    SELECT
        ohnr.region AS country,
        oh.games AS games,
        SUM(CASE WHEN oh.medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
        SUM(CASE WHEN oh.medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
        SUM(CASE WHEN oh.medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
    FROM
        OLYMPICS_HISTORY oh
    JOIN
        OLYMPICS_HISTORY_NOC_REGIONS ohnr ON oh.noc = ohnr.noc
    WHERE
        oh.medal <> 'NA'
    GROUP BY
        ohnr.region, oh.games
),
Rankings AS (
    SELECT
        games,
        country || ' - ' || gold AS gold,
        country || ' - ' || silver AS silver,
        country || ' - ' || bronze AS bronze,
        ROW_NUMBER() OVER (PARTITION BY games ORDER BY gold DESC, silver DESC, bronze DESC) AS gold_rank,
        ROW_NUMBER() OVER (PARTITION BY games ORDER BY silver DESC, gold DESC, bronze DESC) AS silver_rank,
        ROW_NUMBER() OVER (PARTITION BY games ORDER BY bronze DESC, gold DESC, silver DESC) AS bronze_rank
    FROM
        MedalCounts
)
SELECT
    games,
    gold AS gold,
    silver AS silver,
    bronze AS bronze
FROM
    Rankings
WHERE
    gold_rank = 1 OR silver_rank = 1 OR bronze_rank = 1
ORDER BY
    games DESC ;






