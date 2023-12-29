----------Q1. How many olympics games have been held?

select  distinct count(Games)
from olympic_history


--------Q2. List down all Olympics games held so far.
select distinct Games
from olympic_history
order by Games 

--********************************************Next******************************************

----------Q.3. Mention the total no of nations who participated in each olympics game?

select hr.year,hr.games,count( distinct hr.NOC) as total_countries
from olympic_history as hr join olympic_history_noc_regions as noc --left join on noc from both table to get count of total countries.
on hr.noc = noc.noc
group by hr.games,hr.year
order by total_countries

--******************************************NEXT*************************************************

---Q.4 Which year saw the highest and lowest no of countries participating in olympics?

with count_table as (
select hr.year,hr.games,count(distinct hr.NOC) as total_countries
from olympic_history as hr join olympic_history_noc_regions as noc --left join on noc from both table to get count of total countries.
on hr.noc = noc.noc
group by hr.games,hr.year) 
select distinct
concat( FIRST_VALUE(Games) over (order by total_countries),'-',    --concat 2 values:year & lowest count of countries
		first_value(total_countries) over(order by total_countries)) as lowest_countries,
concat(first_value(Games) over(order by total_countries),'-',
		FIRST_VALUE(total_countries) over(order by total_countries desc)) as highest_countries
from count_table

--******************************************Next***********************************************************

--Q5. Which nation has participated in all of the olympic games?

-- create CTE to find count of total games played by each country till now
with table1 as (
	select noc.region,count(distinct games) as total_games
	from olympic_history as hr join olympic_history_noc_regions as noc --left join on noc from both table to get count of total countries.
	on hr.noc = noc.noc
	group by noc.region),
table2 as (									 --create another CTE to find max count of total games played till now.its 51
	select count(distinct games) as total_games
	from olympic_history )											
select table1.region ,table1.total_games   --perform inner join on above 2 tables to find countries having count of total games = 51.
	from table1 inner join table2 
	on table1.total_games = table2.total_games

--*********************************************************************************************************************

--Q5A. create View for Leadership check output at Views folder @ object explorer.
create view OlympicMaxGamesView  as
with table1 as (
select noc.region,count(distinct games) as total_games
from olympic_history as hr join olympic_history_noc_regions as noc --left join on noc from both table to get count of total countries.
on hr.noc = noc.noc
group by noc.region),

--create another CTE to find max count of total games played till now.its 51.
 table2 as (
select count(distinct games) as total_games
from olympic_history )

--perform inner join on above 2 tables to find countries having count of total games = 51.
select table1.region ,table1.total_games from table1 inner join table2 
on table1.total_games = table2.total_games


--**********************************Next*************************************************

--Q6. Identify the sport which was played in all summer olympics.
--SQL query to fetch the list of all sports which have been part of every olympics.

with t1 as(
	select games,sport
	from olympic_history
	group by games,sport) ,
t2 as(
	select count(games)as count_games,sport
	from t1
	group by sport),
t3 as (
	select count(distinct games) as noOfGames
	from olympic_history
	where season= 'summer')
select sport,count_games
from t3 inner join t2 
on t2.count_games = t3.noOfGames

--//////////////////////////*********************************Next********************************\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--Q7. Which Sports were just played only once in the olympics.
--Problem Statement: Using SQL query, Identify the sport which were just played once in all of olympics.

select sport,count(distinct games) as count_of_sports
from olympic_history
group by sport
having Count(distinct games) = 1
order by Count_of_sports

--/////////////////////////***********************Next******************************************\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--Q8. Fetch the total no of sports played in each olympic games.
--Problem Statement: Write SQL query to fetch the total no of sports played in each olympics.

select games, count(distinct sport) as count_sports_played
from olympic_history
group by games
order by count_sports_played desc,games

--////////////////*************************************Next****************************************\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--Q.9. Fetch oldest athletes to win a gold medal
--Problem Statement: SQL Query to fetch the details of the oldest athletes to win a gold medal at the olympics.

with t1 as(
select name,age,medal,sex,team,games,sport
from olympic_history
where medal = 'Gold'),

t2 as(
SELECT MAX(CASE WHEN ISNUMERIC(age) = 1 THEN CAST(age AS INT) ELSE 0 END) AS max_age
FROM olympic_history
WHERE medal = 'Gold')

select *
from t1 inner join t2
on CASE WHEN ISNUMERIC(age) = 1 THEN CAST(age AS INT) ELSE 0 END = t2.max_age

--//////////////////////////****************Next*************\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--Q10. Find the Ratio of male and female athletes participated in all olympic games.
--Problem Statement: Write a SQL query to get the ratio of male and female participants


with t1 as(
select count(sex) as Male_count
FROM olympic_history
where sex = 'M'),

t2 as(select count(sex) female_count
FROM olympic_history
where sex = 'F')

select concat('1 : ',cast(t1.Male_count as float) / t2.female_count) as ratio
from t1,t2;

---////////////*************Next***********************\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--Q11. Fetch the top 5 athletes who have won the most gold medals.
--Problem Statement: SQL query to fetch the top 5 athletes who have won the most gold medals.

with goldWinner as(
select name,team,count(medal) as count_of_GoldMedals,dense_rank() over (order by count(medal) desc) as rank
FROM olympic_history
where medal ='gold'
group by name,team)

select name,team, count_of_GoldMedals,rank
from goldWinner
where rank<=5


--/////////////////////////********************************Next*****************************\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--Q12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
--Problem Statement: SQL Query to fetch the top 5 athletes who have won the most medals (Medals include gold, silver and bronze).


with most_medals as (select name,team,count(medal) as medal_count,dense_rank() over(order by count(medal) desc) as rank
FROM olympic_history
where medal != 'NA'
group by name,team)
select name,team,medal_count,rank
from most_medals
where rank <=5

--------------------------------------------*************** ANother approach *******************---------------------------------------

with gold as (select name,team,count(medal) as count_of_Gold_Medals --- create CTE for gold medal winners
FROM olympic_history
where medal ='gold' and medal !='NA'
group by name,team),

silver as(select name,team,count(medal) as count_of_silver_Medals --- create CTE for silver medal winners
FROM olympic_history
where medal ='silver' and medal !='NA'
group by name,team),

bronze as (select name,team,count(medal) as count_of_bronze_Medals ----- create CTE for bronze medal winners
FROM olympic_history
where medal ='bronze' and medal !='NA'
group by name,team),

--perform inner join on above 3 tables and add count of medals and create ranl window function
total as(select gold.name,gold.team,count_of_Gold_Medals + count_of_silver_Medals + count_of_bronze_Medals as total_count, dense_rank() over (order by (count_of_Gold_Medals + count_of_silver_Medals + count_of_bronze_Medals ) desc) as rank
from gold 
inner join silver on gold.name = silver.name 
inner join bronze on silver.name = bronze.name
 )

select name,team,total_count,rank -- select top 5 athelete with max count of medals
from total
where rank <=5


--///////////////////////***********************************Next******************************\\\\\\\\\\\\\\\\\\\\

--Q13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
--Problem Statement: Write a SQL query to fetch the top 5 most successful countries in olympics. (Success is defined by no of medals won).

with country as
	(select noc.region,hr.noc
	from olympic_history as hr join olympic_history_noc_regions as noc --left join on noc from both table to get region/country name.
	on hr.noc = noc.noc),
most_medals_country as  ---calculate medals won by each noc
		(select noc,count(medal) as medal_count
		FROM olympic_history
		where medal != 'NA' --- to eleiminate false counting of medals
		group by noc),
t1 as 
		(select country.region,medal_count ,dense_rank() over(order by medal_count desc) as rank ---using dense rank ranks are given to countries with highest medals
		from most_medals_country
		inner join country   ---perform inner join to get country /region name
		on most_medals_country.noc = country.noc
		group by country.region,medal_count)
select region,medal_count,rank  ---display top 5 countries
from t1
where rank <=5

----/////////////////////////////////***************************Next*******************************\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


--Q14. List down total gold, silver and bronze medals won by each country.
--Problem Statement: Write a SQL query to list down the  total gold, silver and bronze medals won by each country.
with gold as 
	(select noc,count(medal) as Gold_Medals --- create CTE for gold medal winners
	FROM olympic_history
	where medal ='gold' and medal !='NA'
	group by noc),
silver as
	(select noc,count(medal) as silver_Medals --- create CTE for silver medal winners
	FROM olympic_history
	where medal ='silver' and medal !='NA'
	group by noc),
bronze as 
	(select noc,count(medal) as bronze_Medals ----- create CTE for bronze medal winners
	FROM olympic_history
	where medal ='bronze' and medal !='NA'
	group by noc),
t1 as (
	select gold.noc,Gold_Medals,silver_Medals,bronze_Medals
	from gold 
	left join silver on gold.noc = silver.noc
	left join bronze on silver.noc = bronze.noc),
t2 as(
	select noc.region,hr.noc
	from olympic_history as hr join olympic_history_noc_regions as noc --left join on noc from both table to get region/country name.
	on hr.noc = noc.noc
	)
select t2.region,Gold_Medals,silver_Medals,bronze_Medals
from t1 inner join t2
on t1.noc = t2.noc
group by t2.region,Gold_Medals,silver_Medals,bronze_Medals
order by gold_medals desc

--------------
SELECT region,
COUNT(CASE WHEN medal = 'Gold' THEN medal END) AS Gold_medal,
COUNT(CASE WHEN medal = 'Silver' THEN medal END) AS Silver_medal,
COUNT(CASE WHEN medal = 'Bronze' THEN medal END) AS Bronze_medal
FROM olympic_history AS a
JOIN olympic_history_noc_regions AS n ON a.NOC = n.NOC
GROUP BY region
order by Gold_medal desc

--///////////////////////////////************************************Next*******************************\\\\\\\\\\\\\\\\\\\\\

 --Q.16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
 --Problem Statement: Write SQL query to display for each Olympic Games, which country won the highest gold, silver and bronze medals.

with t as
(select games, region,
COUNT(CASE WHEN medal = 'Gold' THEN medal END) AS Gold,
COUNT(CASE WHEN medal = 'Silver' THEN medal END) AS Silver,
COUNT(CASE WHEN medal = 'Bronze' THEN medal END) AS Bronze
FROM olympic_history AS a
JOIN olympic_history_noc_regions AS n ON a.NOC = n.NOC
group by games,region
)
select distinct games
, concat(first_value(region) over(partition by games order by gold desc)
, ' - '
, first_value(Gold) over(partition by games order by gold desc)) as Max_Gold
, concat(first_value(region) over(partition by games order by silver desc)
, ' - '
, first_value(Silver) over(partition by games order by silver desc)) as Max_Silver
, concat(first_value(region) over(partition by games order by bronze desc)
, ' - '
, first_value(Bronze) over(partition by games order by bronze desc)) as Max_Bronze
from t
order by games;

--///////////////////////////////************************************Next*******************************\\\\\\\\\\\\\\\\\\\\
--Q17. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
--Problem Statement: Similar to the previous query, identify during each Olympic Games, which country won the highest gold, silver and bronze medals. 
--Along with this, identify also the country with the most medals in each olympic games.


with t1 as (
		SELECT games, region,
		COUNT(CASE WHEN medal = 'Gold' THEN medal END) AS Gold_medal,
		COUNT(CASE WHEN medal = 'Silver' THEN medal END) AS Silver_medal,
		COUNT(CASE WHEN medal = 'Bronze' THEN medal END) AS Bronze_medal
		FROM olympic_history AS a
		JOIN olympic_history_noc_regions AS n ON a.NOC = n.NOC
		GROUP BY games,region),
t2 as (
		select games, region , Gold_medal,Silver_medal,Bronze_medal,(Gold_medal +  Silver_medal + Bronze_medal) as count_of_medals,
				ROW_NUMBER() over(partition by games order by Gold_medal +  Silver_medal + Bronze_medal desc) as row_num
		from t1)
		
select games,region,Gold_medal,Silver_medal,Bronze_medal,count_of_medals,row_num
from t2
where row_num = 1
-----------------------------------
with t as
(select games, region,
COUNT(CASE WHEN medal = 'Gold' THEN medal END) AS Gold,
COUNT(CASE WHEN medal = 'Silver' THEN medal END) AS Silver,
COUNT(CASE WHEN medal = 'Bronze' THEN medal END) AS Bronze
FROM olympic_history AS a
JOIN olympic_history_noc_regions AS n ON a.NOC = n.NOC
group by games,region
),
t2 as (select distinct games
, concat(first_value(region) over(partition by games order by gold desc)
, ' - '
, first_value(Gold) over(partition by games order by gold desc)) as Max_Gold
, concat(first_value(region) over(partition by games order by silver desc)
, ' - '
, first_value(Silver) over(partition by games order by silver desc)) as Max_Silver
, concat(first_value(region) over(partition by games order by bronze desc)
, ' - '
, first_value(Bronze) over(partition by games order by bronze desc)) as Max_Bronze,
(Gold +  Silver + Bronze) as count_of_medals,ROW_NUMBER() over(partition by games order by (Gold +  Silver + Bronze) desc) as row_num
from t)
select games,Max_Gold,Max_Silver,Max_Bronze,count_of_medals,row_num
from t2
where row_num = 1
order by Games
--///////////////////////////////************************************Next*******************************\\\\\\\\\\\\\\\\\\\\
--Q18.Which countries have never won gold medal but have won silver/bronze medals?
--Problem Statement: Write a SQL Query to fetch details of countries which have won silver or bronze medal but never won a gold medal.

with t1 as (select noc.region,count(CASE WHEN medal = 'Gold' THEN medal END) as gold,
			count(CASE WHEN medal = 'silver' THEN medal END) as silver,
			count(CASE WHEN medal = 'Bronze' THEN medal END) as bronze
from olympic_history as oly
left join olympic_history_noc_regions as noc
on oly.noc = noc.noc
group by medal,noc.region)
--order by gold desc
select region,sum(silver)as silver_medals,sum(bronze) as bronze_medal
from t1
where gold = 0 and silver >=1 or bronze >= 1
group by region
order by region