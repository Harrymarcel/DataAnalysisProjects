--This file contains the SQL queries I used in the exploration of Covid deaths data obtained from 2020 to 2021 from around the world.
--Skills shown include the use of the following functions: ORDER BY, GROUP BY, SUM, SUBQUERY, CAST AS, CASE, LAG window function, ROUND, AVG, SUB

--To get a glance of all entries in the tables
SELECT *
FROM CovidDeaths


--To calculate the total number of Covid cases per continent
SELECT continent, sum(new_cases) as [Cases per continent]
FROM CovidDeaths
WHERE continent is not NULL --There seems to be a little error in the data entry that's why this clause is important
GROUP BY continent
ORDER BY [Cases per continent] desc
--From the query, it was deduced that the highest number of covid cases were found in the continent of Europe and the lowest number was in Oceania.



--To determine the location that had the highest number of cases
SELECT location, sum(new_cases) as Cases_per_location
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY Cases_per_location DESC
--From the query, United states had the highest number of cases while Micronecia had the lowest number



--To determine the number of countries and continents that recorded no single Covid case at all
SELECT location, continent, cases_per_location
FROM 
(SELECT location, continent, sum(new_cases) as Cases_per_location
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location, continent)
as Subquery
WHERE Cases_per_location is NULL 
ORDER BY continent 
--From the query, I deduced that only 20 countries recorded no case at all. North America had the highest number of countries that never recorded a single case (8)


--To determine the countries with the highest and lowest number of Covid deaths
SELECT location, sum(cast(new_deaths AS int)) AS total_deaths_per_location
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY total_deaths_per_location DESC
--United states had the highest number of deaths while Grenada had the lowest

--To determine the number of locations that recorded no death case
SELECT location, total_deaths_per_location
FROM
(
SELECT location, sum(cast(new_deaths AS int)) AS total_deaths_per_location
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location) as subquery
WHERE total_deaths_per_location is NULL;
--28 countries did not record any covid death



--This calculates the average growth rate of new cases over time for each continent. 
--It does so by first calculating the total cases per continent and date, 
--and then using window functions (LAG) to calculate the growth rate for each row. 
--Finally, it selects the continent, rounds the average growth rate, and groups the results by continent.

WITH weekly_cases AS ( --This is a CTE for determing the total number of new cases per dsy for each continent
  SELECT continent, date, SUM(new_cases) AS total_cases
  FROM CovidDeaths
  WHERE continent IS NOT NULL
  GROUP BY continent, date
),
growth_rates AS (
  SELECT continent, date, (total_cases - LAG(total_cases) OVER (PARTITION BY continent ORDER BY date)) / NULLIF(CAST(LAG(total_cases) OVER (PARTITION BY continent ORDER BY date) AS FLOAT), 0) * 100 AS growth_rate
  FROM weekly_cases
)
SELECT continent, ROUND(AVG(growth_rate), 2) AS average_growth_rate
FROM growth_rates
GROUP BY continent
ORDER BY average_growth_rate;


--This query analyzes the covid cases and checks for days where there was a significant increase of patients up to 5 times from previous day
--If there is a 5x increase, it retuns the piority level as high else it returns it as low
--This query can also be tweaked to show even a 100x increase
WITH daily_cases AS
(
SELECT location, date, new_cases, LAG(new_cases) OVER (PARTITION BY location ORDER BY date ) AS previous_day_cases
FROM CovidDeaths
WHERE continent is not NULL
)
SELECT date, location, new_cases,
CASE
WHEN
new_cases >  5*previous_day_cases THEN 'High' else 'Low'
END AS Piority_level
FROM daily_cases
ORDER by Piority_level, new_cases DESC, date --You would see that France recorded the highest new cases in a day with 117900 patients.


--This calculates the total number of Covid survivors from all of the countries and then creates a column for the data
SELECT continent, location, [Total deaths], [Total cases], ([Total cases] - [Total deaths]) as [Total survivors]
FROM (
SELECT continent, location, sum(cast(new_deaths as int)) as [Total deaths], sum(new_cases) as [Total cases]
FROM CovidDeaths
WHERE continent is not NULL 
GROUP BY continent, location
) AS subquery
ORDER BY continent, location, [Total survivors]

