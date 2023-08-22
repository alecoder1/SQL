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


Q13. List down total gold, silver, AND bronze medals won BY EACH country
SELECT ohnr.region AS country, medal, COUNT(1) AS total_medals 
FROM OLYMPICS_HISTORY oh 
JOIN OLYMPICS_HISTORY_NOC_REGIONS ohnr 
ON oh.noc = ohnr.noc
WHERE medal <> 'NA'
GROUP BY country
ORDER BY total_medals;

CREATE extension tablefunc;

SELECT country
, COALESCE (gold, 0) AS gold 
, COALESCE (silver, 0) AS silver 
, COALESCE (bronze, 0) AS bronze 
FROM crosstab ('SELECT ohnr.region AS country, medal, COUNT(1) AS total_medals 
                  FROM OLYMPICS_HISTORY oh 
                  JOIN OLYMPICS_HISTORY_NOC_REGIONS ohnr 
                  ON oh.noc = ohnr.noc
                  WHERE medal <> ''NA''
                  GROUP BY ohnr.region, medal
                  ORDER BY ohnr.region, medal',
                  'values (''Bronze''), (''Gold''), (''Silver'')')
         AS RESULT (country varchar, bronze int, gold bigint, silver bigint)
ORDER BY gold DESC, silver DESC, bronze DESC;

-- Q16. Identify which country won the most gold, silver and bronze medals in each olympic games.




    
    
    