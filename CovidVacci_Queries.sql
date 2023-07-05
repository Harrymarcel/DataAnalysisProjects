--This file conatins SQL queries that were used to derive insights from the Covid vaccination data.
--Skills shown include the use of the following functions: SUM, CAST, GROUP BY, DATE RANGE, MAXSUBQUERY, MINSUBQUERY, OFFSET, FETCH NEXT, ROWS


--To determine the country with the highest number of tests and vaccinations between January 2021 to January 2022
SELECT location, sum(CAST(new_tests AS INT)) as total_number_of_tests, sum(CAST(new_vaccinations AS INT)) as total_no_of_vaccinations
FROM CovidVaccinations
WHERE continent is not null and new_tests is not null and new_vaccinations is not null AND Date BETWEEN '2021-01-01' AND '2022-01-01'
GROUP BY location
ORDER BY total_number_of_tests DESC


--To determine the continent with the highest number of Covid tests taken and the highest number of vaccinations  done, 
--between January 2021 and July 2021
SELECT continent, sum(CAST(new_tests AS INT)) as total_number_of_tests, sum(CAST(new_vaccinations AS INT)) as total_no_of_vaccinations
FROM CovidVaccinations
WHERE continent is not null and new_tests is not null and new_vaccinations is not null AND Date BETWEEN '2021-01-01' AND '2022-06-01'
GROUP BY continent
ORDER by total_number_of_tests DESC


--This query retrieves the countries with the highest and lowest rate of tests per a thousand people
SELECT location, total_tests_per_thousand
FROM (
    SELECT location, SUM(CAST(new_tests_per_thousand AS FLOAT)) as total_tests_per_thousand
    FROM CovidVaccinations
    WHERE continent IS NOT NULL AND new_tests IS NOT NULL AND new_vaccinations IS NOT NULL AND total_tests_per_thousand IS NOT NULL
    GROUP BY location
) AS Subquery
WHERE total_tests_per_thousand = (
    SELECT MAX(total_tests_per_thousand) FROM (
        SELECT SUM(CAST(new_tests_per_thousand AS FLOAT)) as total_tests_per_thousand
        FROM CovidVaccinations
        WHERE continent IS NOT NULL AND new_tests IS NOT NULL AND new_vaccinations IS NOT NULL AND total_tests_per_thousand IS NOT NULL
        GROUP BY location
    ) AS MaxSubquery
)
OR total_tests_per_thousand = (
    SELECT MIN(total_tests_per_thousand) FROM (
        SELECT SUM(CAST(new_tests_per_thousand AS FLOAT)) as total_tests_per_thousand
        FROM CovidVaccinations
        WHERE continent IS NOT NULL AND new_tests IS NOT NULL AND new_vaccinations IS NOT NULL AND total_tests_per_thousand IS NOT NULL
        GROUP BY location
    ) AS MinSubquery
);

--To determine the total number of tests done in any country
SELECT location, continent, sum(cast(new_tests as int)) AS total_tests_done
FROM covidvaccinations
WHERE continent is not NULL AND new_tests is not NULL and totaL_tests IS not NULL and continent = 'Europe' and location ='finland'
GROUP BY location, continent


--To join the two tables together in order to get the population of each country and their corresponding number of people fully vaccinated
SELECT covidvaccinations.location, covidvaccinations.continent, covidvaccinations.people_fully_vaccinated, population
FROM covidvaccinations
JOIN CovidDeaths
ON CovidVaccinations.location = CovidDeaths.location
WHERE coviddeaths.CONTINENT is not null and covidvaccinations.people_fully_vaccinated is NOT NULL



--To determine the country with the highest total vaccinatioms per hundred people 
SELECT location, total_vaccinations_per_hundred
FROM CovidVaccinations
WHERE continent is not NULL AND new_vaccinations is not NULL and total_vaccinations IS not NULL
ORDER BY total_vaccinations_per_hundred DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY

--To determine the country with the LOWEST total vaccinatioms per hundred people 
SELECT location, total_vaccinations_per_hundred
FROM CovidVaccinations
WHERE continent is not NULL AND new_vaccinations is not NULL and total_vaccinations IS not NULL
ORDER BY total_vaccinations_per_hundred ASC
OFFSET 0 ROWS FETCH NEXT 40 ROWS ONLY

