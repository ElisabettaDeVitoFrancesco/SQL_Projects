USE Portfolio_Project;

-- Data of covid deaths table - exploration
SELECT *
FROM covid_deaths
where location = 'Italy';

SELECT *
FROM covid_vaccinations;

-- Selection of needed data from covid deaths table

SELECT location
	, continent
	, date
	, total_cases
	, new_cases
	, total_deaths
	, new_deaths
	, population
FROM covid_deaths
WHERE continent is not null                     -- The attribute "location" also includes data for each continent,
                                                -- which leads to mistakes during calculations due to double counting the data for the continents
ORDER BY 1,2,3;

-------------------------------------------------------------------------------------------------------------------
-- NEW CASES vs NEW TESTS
-------------------------------------------------------------------------------------------------------------------
-- Running total of new cases per location
SELECT location
	, date
	, new_cases
	, SUM(new_cases) OVER (PARTITION BY location ORDER BY date) AS location_running_total_cases
FROM covid_deaths
WHERE continent is not null;

-- Total gloabal daily new cases
SELECT date
	, SUM(new_cases) AS tot_daily_new_cases
FROM covid_deaths
WHERE continent is not null
GROUP BY date
ORDER BY date;

-- Total cases per location
SELECT location
	, MAX(total_cases) AS country_total_cases
FROM covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC;

-- Total cases per continent
SELECT location
	, MAX(total_cases) AS continent_total_cases
FROM covid_deaths
WHERE continent is null AND total_cases is not null AND location IN ('Asia', 'Africa', 'Europe', 'North America', 'South America', 'Oceania')
GROUP BY location
ORDER BY 2 DESC;

-- Total deaths per country
SELECT location
	, MAX(total_deaths) AS country_total_deaths
FROM covid_deaths
WHERE continent is not null
GROUP BY location
ORDER BY 2 DESC;

-- Total deaths per continent
SELECT location AS continent
	, MAX(total_deaths) AS continent_total_deaths
FROM covid_deaths
WHERE continent is null AND total_cases is not null AND location IN ('Asia', 'Africa', 'Europe', 'North America', 'South America', 'Oceania')
GROUP BY location
ORDER BY 2 DESC;

-- Infections vs tests performed positive rate over the test performed as percentage of positive tests
SELECT cd.location
	, cd.date
	, cd.new_cases
	, cv.new_tests
	, ROUND(CAST(cd.new_cases AS FLOAT)/CAST(cv.new_tests AS FLOAT)*100, 2) AS positive_tests
FROM covid_deaths AS cd
JOIN covid_vaccinations AS cv
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null AND cv.new_tests is not null;


-- Running totals of new cases and new tests per location
WITH running_tot_cases_test_CTE (location, date, new_cases, running_total_cases, new_tests, running_total_tests) AS (
SELECT cd.location
	, cd.date
	, cd.new_cases
	, SUM(cd.new_cases) OVER (PARTITION BY cd.location ORDER BY cd.date) AS running_total_cases
	, cv.new_tests
	, SUM(cv.new_tests) OVER (PARTITION BY cv.location ORDER BY cv.date) AS running_total_tests
FROM covid_deaths AS cd
JOIN covid_vaccinations AS cv
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent is not null
)

SELECT location
	, date
	, running_total_cases
	, running_total_tests
	, ROUND(CAST(running_total_cases AS FLOAT)/CAST(running_total_tests AS FLOAT)*100, 2) AS running_tot_positive_tests
FROM running_tot_cases_test_CTE;


-- Running totals of new cases and new tests per continent
SELECT cd.continent
	, cd.date
	, cd.new_cases
	, SUM(CAST(cd.new_cases AS BIGINT)) OVER (PARTITION BY cd.continent ORDER BY cd.date) AS running_total_cont_cases
	, cv.new_tests
	, SUM(CAST(cv.new_tests AS BIGINT)) OVER (PARTITION BY cv.continent ORDER BY cv.date) AS running_total_cont_tests
FROM covid_deaths AS cd
JOIN covid_vaccinations AS cv
	ON cd.continent = cv.continent AND cd.date = cv.date
WHERE cd.continent is not null;

-- Total cases and test per continent
SELECT cont_tot_case.continent
	, cont_tot_case.continent_total_cases
	, cont_tot_test.continent_total_tests
FROM (
		SELECT continent
			, MAX(total_cases) AS continent_total_cases
		FROM covid_deaths
		WHERE continent is not null
		GROUP BY continent
		) AS cont_tot_case
JOIN (
		SELECT continent
			, MAX(total_tests) AS continent_total_tests
		FROM covid_vaccinations
		WHERE continent is not null
		GROUP BY continent
		) AS cont_tot_test
	ON cont_tot_case.continent = cont_tot_test.continent
ORDER BY 3 DESC;



---------------------------------------------------------------------------
-- CASES VS DEATHS
---------------------------------------------------------------------------
-- Total cases vs total deaths as daily % of people who died vs the infected ones

SELECT location
	, continent
	, date
	, total_cases, total_deaths
	, ROUND((CAST(total_deaths AS float)/CAST(total_cases AS float))*100, 2) AS daily_deaths_percentage -- Calculate the percetnage with total_cases and total_deaths because we need the rolling percenage, hence the percentage of deaths in total 
FROM covid_deaths
WHERE continent is not null AND total_cases is not null
ORDER BY 1,2,3;

-- Total cases vs total deaths as monthly by year % of people who died vs the infected ones

SELECT location
	, continent
	, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2)) AS date_year_month
	, ROUND((SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)))*100, 2) AS monthly_year_deaths_percentage -- Calculate the percetnage with total_cases and total_deaths because we need the rolling percenage, hence the percentage of deaths in total 
FROM covid_deaths
WHERE continent is not null AND total_cases is not null AND new_deaths < new_cases
GROUP BY location, continent, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2))
ORDER BY 1,2,3;

-- Totale cases vs Total deaths as monthly % of people who died vs the infected ones
SELECT location
	, continent
	, MONTH(date) AS date_month
	, ROUND(SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100, 2) AS monthly_deaths_percentage
FROM covid_deaths
WHERE continent is not null AND new_cases is not null AND new_deaths < new_cases
GROUP BY location, continent, MONTH(date)
ORDER BY 1,2,3;


-- Total cases vs Total deaths as yearly % of people who died vs the infected ones
SELECT location
	, continent
	, YEAR(date) AS date_year
	, ROUND(SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT)) *100, 2) AS yearly_deaths_percentage
FROM covid_deaths
WHERE continent is not null AND total_cases is not null AND new_deaths < new_cases
GROUP BY location, continent, YEAR(date)
ORDER BY 1,2,3;

-- Highest death rate
SELECT location
	, continent
	, MAX(ROUND((CAST(total_deaths AS float)/CAST(total_cases AS float))*100, 2)) AS deaths_percentage -- Calculate the percetnage with total_cases and total_deaths because we need the rolling percenage, hence the percentage of deaths in total 
FROM covid_deaths
WHERE continent is not null AND total_cases is not null
GROUP BY location, continent
ORDER BY 3 DESC;

-- The highest death rate seems to have been recorded in France, 103875. However, this looks like a mistake since it is not possible
-- to have a higher percentage of deaths than 100%.
-- As a matter of fact, if we filter where location is equal to France for example it is possible to see that this percentage is due
-- to a higher recording of nr of deaths compared to the recorded nr of cases, like for example during the month of May 2020 France recorded
-- daily for a few days 16620 deaths vs 16 total cases. 
SELECT location
	, continent
	, date
	, total_cases, total_deaths
	, ROUND((CAST(total_deaths AS float)/CAST(total_cases AS float))*100, 2) AS deaths_percentage -- Calculate the percetnage with total_cases and total_deaths because we need the rolling percenage, hence the percentage of deaths in total 
FROM covid_deaths
WHERE continent is not null AND total_cases is not null AND location = 'France'
ORDER BY 1,2,3;

-- One solution could be to exclude all the rows in which the recorded total deaths are greater than the recorded total cases.
-- Highest death rates per location, continent and on which date occured

SELECT covid_deaths.location
	, covid_deaths.continent
	, covid_deaths.date
	, ROUND(CAST(covid_deaths.total_deaths AS float)/CAST(covid_deaths.total_cases AS float)*100, 2) AS max_deaths_percentage
FROM covid_deaths
INNER JOIN (
	SELECT location
		, continent
		, MAX(ROUND(CAST(total_deaths AS float)/CAST(total_cases AS float)*100, 2)) AS max_deaths_percentage
	FROM covid_deaths
	WHERE continent is not null and total_cases is not null and total_deaths < total_cases
	GROUP BY location, continent
) AS grouped_deaths_perc
	ON covid_deaths.location = grouped_deaths_perc.location
		AND ROUND(CAST(covid_deaths.total_deaths AS float)/CAST(covid_deaths.total_cases AS float)*100, 2) = grouped_deaths_perc.max_deaths_percentage
WHERE covid_deaths.continent is not null 
	AND covid_deaths.total_cases is not null
	AND covid_deaths.total_deaths < covid_deaths.total_cases
ORDER BY 4 DESC;

-- Another approach could be to calculate the deaths rate based on the sum of the new cases and the sum of the new deaths.

SELECT location
	, continent
	, SUM(new_cases) AS total_sum_cases
	, SUM(new_deaths) AS total_sum_deaths
	, ROUND(SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100, 2) AS deaths_percentage
FROM covid_deaths
WHERE continent is not null and new_cases is not null and new_deaths is not null and new_cases <> 0
GROUP BY location, continent
ORDER BY 5 DESC;

-- To obtain the highest death rate using the SUM() of new_cases and new_deaths, in this case a subquery is needed.
SELECT location
		, continent
		, year_month_date
		, MAX(deaths_percentage) AS max_deaths_percentage 
FROM ( 
    SELECT location
		, continent
		, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2)) AS year_month_date
		, ROUND(SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100, 2) AS deaths_percentage 
    FROM covid_deaths
	WHERE continent is not null AND new_cases is not null AND new_deaths is not null AND new_cases <> 0
    GROUP BY location, continent, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2))
) AS subquery_max_death_rate
GROUP BY location, continent, year_month_date; 


---------------------------------------------------------------------------
-- CASES / DEATHS VS POPULAITON
---------------------------------------------------------------------------
-- Total cases vs population as daily % of infected people over the population

SELECT location
	, continent
	, date
	, total_cases
	, population
	, ROUND((CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100, 8) AS infection_rate
FROM covid_deaths
WHERE continent is not null and total_cases is not null
ORDER BY 1,2,3;

-- Total cases vs population as monthly by year % of infected people over the population
SELECT location
	, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2)) AS date_year_month
	, ROUND(SUM(CAST(new_cases AS FLOAT))/MAX(CAST(population AS FLOAT))*100, 8) AS monthly_year_infection_rate
FROM covid_deaths
WHERE continent is not null and new_cases is not null
GROUP BY location, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2))
ORDER BY CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2));


-- Total cases vs population as monthly % of infected people over the population
SELECT location
	, MONTH(date) AS date_month
	, ROUND(SUM(CAST(new_cases AS FLOAT))/MAX(CAST(population AS FLOAT))*100, 8) AS monthly_infection_rate
FROM covid_deaths
WHERE continent is not null and new_cases is not null
GROUP BY location, MONTH(date)
ORDER BY MONTH(date);

-- Highest infection rate overall
SELECT location
	, continent
	, MAX(ROUND(CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)*100, 2)) AS max_infection_rate
FROM covid_deaths
WHERE continent is not null AND total_cases is not null
GROUP BY location, continent
ORDER BY 3 DESC;

-- Monthly by year highest infection rate
SELECT location
	, continent
	, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2)) AS date_year_month
	, MAX(ROUND(CAST(total_cases AS FLOAT)/CAST(population AS FLOAT)*100, 2)) AS max_monthly_year_infection_rate
FROM covid_deaths
WHERE coNtinent is not null AND total_cases is not null
GROUP BY location, continent, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2))
ORDER BY 3,4 DESC;

-- Highest monthly by year infection rate with SUM() new_cases and population and subquery method
SELECT location
	, continent
	, MAX(monthly_infection_rate) AS max_monthly_infection_rate
FROM (
	SELECT location
		, continent
		, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2)) AS date_year_month
		, ROUND(SUM(CAST(new_cases AS FLOAT))/SUM(CAST(population AS FLOAT))*100, 8) AS monthly_infection_rate
	FROM covid_deaths
	WHERE continent is not null AND new_cases is not null AND new_cases <> 0
	GROUP BY location, continent, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2))
	) AS subquery_max_inf_rate
GROUP BY location, continent;


-- need of an inner join to be able to see on whcih month and year the max inf rate occured
SELECT covid_deaths.location
	, covid_deaths.continent
	, CAST(YEAR(covid_deaths.date) AS VARCHAR(4)) + '-' + CAST(MONTH(covid_deaths.date) AS VARCHAR(2)) AS date_year_month
	, (SELECT ROUND(SUM(CAST(covid_deaths.new_cases AS FLOAT))/SUM(CAST(covid_deaths.population AS FLOAT))*100, 8)
		FROM covid_deaths
		WHERE covid_deaths.continent is not null AND covid_deaths.new_cases is not null AND covid_deaths.new_cases <> 0
		GROUP BY location, continent
			 ) AS max_monthly_infection
FROM covid_deaths
INNER JOIN (
	-- Query for the monthly max infection rates
	SELECT location
		, continent
		, MAX(monthly_infection_rate) AS max_monthly_infection_rate
	FROM (
		SELECT location
			, continent
			, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2)) AS date_year_month
			, ROUND(SUM(CAST(new_cases AS FLOAT))/SUM(CAST(population AS FLOAT))*100, 8) AS monthly_infection_rate
		FROM covid_deaths
		WHERE continent is not null AND new_cases is not null AND new_cases <> 0
		GROUP BY location, continent, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2))
		) AS subquery_max_inf_rate
	GROUP BY location, continent
) AS grouped_max_month
	ON covid_deaths.location = grouped_max_month.location
		AND (-- SubQuery for the infection rate but daily I need it monthly to have a proper comparison
			SELECT ROUND(SUM(CAST(covid_deaths.new_cases AS FLOAT))/SUM(CAST(covid_deaths.population AS FLOAT))*100, 8)
			 FROM covid_deaths
			 WHERE covid_deaths.continent is not null AND covid_deaths.new_cases is not null AND covid_deaths.new_cases <> 0
			 GROUP BY location, continent
			 ) = grouped_max_month.max_monthly_infection_rate
WHERE covid_deaths.continent is not null AND covid_deaths.new_cases is not null AND covid_deaths.new_cases <> 0;
-- Empty result table so:
-- CTE method

WITH monthly_inf_rate_CTE (location, continent, date_year_month, monthly_infection_rate) AS(

SELECT location
	, continent
	, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2)) AS date_year_month
	, ROUND(SUM(CAST(new_cases AS FLOAT))/SUM(CAST(population AS FLOAT))*100, 8) AS monthly_infection_rate
FROM covid_deaths
WHERE continent is not null AND new_cases is not null AND new_cases <> 0
GROUP BY location, continent, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2))
)

, max_monthly_inf_rate_CTE (location, continent, max_monthly_infection_rate) AS (

SELECT location
	, continent
	, MAX(monthly_infection_rate) AS max_monthly_infection_rate
FROM monthly_inf_rate_CTE
GROUP BY location, continent
)

SELECT monthly_inf_rate_CTE.location
	, monthly_inf_rate_CTE.continent
	, monthly_inf_rate_CTE.date_year_month
	, max_monthly_inf_rate_CTE.max_monthly_infection_rate
FROM  monthly_inf_rate_CTE, max_monthly_inf_rate_CTE
WHERE monthly_inf_rate_CTE.monthly_infection_rate = max_monthly_inf_rate_CTE.max_monthly_infection_rate
ORDER BY 4 DESC;

-- Highest infection rate compared to highest infected cases and to population
SELECT location
	, continent
	, MAX(population) AS poopulation
	, MAX(total_cases) AS max_total_cases
	, MAX(CAST(total_cases AS FLOAT)/CAST(population AS FLOAT))*100 AS max_infected_people
FROM covid_deaths
WHERE continent is not null AND total_cases is not null
GROUP BY location, continent
ORDER BY 4 DESC;

-- BY CONTINENT
SELECT location
	, MAX(population) AS population
	, MAX(total_cases) AS max_total_cases
	, MAX(CAST(total_cases AS FLOAT)/population)*100 AS max_infected_people
FROM covid_deaths
WHERE continent is null AND total_cases is not null AND location IN ('Asia', 'Africa', 'Europe', 'North America', 'South America', 'Oceania')
GROUP BY location
ORDER BY 3 DESC;

-- Countries with highest death count per population
SELECT location
	, MAX(CAST(population AS INT)) AS population
	, MAX(CAST(total_deaths AS FLOAT)) AS max_total_deaths
	, MAX(CAST(total_deaths AS FLOAT)/ CAST(population AS INT)) AS max_death_rate
FROM covid_deaths
WHERE continent is not null AND total_cases is not null
GROUP BY location
ORDER BY 4 DESC;

 -- Continents with highest death count
SELECT location
	, MAX(CAST(population AS INT)) AS population
	, MAX(CAST(total_deaths AS FLOAT)) AS max_total_deaths
	, MAX(CAST(total_deaths AS FLOAT)/ CAST(population AS INT)) AS max_death_rate
FROM covid_deaths
WHERE continent is null AND total_cases is not null AND location IN ('Asia', 'Africa', 'Europe', 'North America', 'South America', 'Oceania')
GROUP BY location
ORDER BY 4 DESC; -- Asia population results NULL here when in excel is not


-- POPULATION OF EACH COUNTRY
SELECT DISTINCT(location)
	, continent
	, population
FROM covid_deaths
WHERE continent is not null;

-- POPULATION OF EACH CONTINENT
WITH population_CTE (location, continent, population) AS (
SELECT DISTINCT(location)
	, continent
	, population
FROM covid_deaths
WHERE continent is not null
)
SELECT continent
	, SUM(CAST(population AS BIGINT)) AS population
FROM population_CTE
GROUP BY continent;

---------------------------------------------------
-- GLOBAL NUMBERS

-- Daily cases
SELECT date
	, SUM(CAST(new_cases AS FLOAT)) AS total_cases
	, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths
	, ROUND(SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100, 2) AS total_death_rate
FROM covid_deaths
WHERE continent is not null AND new_cases is not null AND new_deaths < new_cases
GROUP BY date
ORDER BY date;

-- Total global cases deaths and death rate
SELECT SUM(CAST(new_cases AS FLOAT)) AS total_cases
	, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths
	, ROUND(SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100, 2) AS total_death_rate
FROM covid_deaths
WHERE continent is not null AND new_cases is not null AND new_deaths < new_cases;

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
-- VACCINATIONS
------------------------------------------------------------------------------------------------------------------------------
-- Total vaccinations per country
SELECT location
	, SUM(CAST(new_vaccinations AS BIGINT)) As total_vaccinations
FROM covid_vaccinations
WHERE continent is not null
GROUP BY location;

-- Total vaccinations per continent
SELECT continent
	, SUM(CAST(new_vaccinations AS BIGINT)) As total_vaccinations
FROM covid_vaccinations
WHERE continent is not null
GROUP BY continent;


-- Vacciantions vs population as daily vaccinations compared to poulation
SELECT location
	, continent
	, date
	, total_vaccinations
	, total_vaccinations/population*100 AS vaccination_rate
FROM covid_vaccinations
WHERE continent is not null
ORDER BY date, continent, location;


-- Vaccination vs population as monthly per year vaccinations compared to population
SELECT location
	, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2)) AS date_year_month
	, MAX(population) AS population
	, SUM(new_vaccinations) as vaccinations
	, ROUND(SUM(new_vaccinations)/MAX(population)*100, 2) AS vaccination_rate
FROM covid_vaccinations
WHERE continent is not null
GROUP BY location, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2))
ORDER BY date_year_month, location;

-- Vaccinations vs population as monthly vaccinations compared to population
SELECT location
	, MONTH(date) AS date_month
	, MAX(population) AS population
	, SUM(new_vaccinations) as vaccinations
	, ROUND(SUM(new_vaccinations)/MAX(population)*100, 2) AS vaccination_rate
FROM covid_vaccinations
WHERE continent is not null
GROUP BY location, MONTH(date)
ORDER BY date_month, location;

-- Vaccinations vs population as yearly vaccinations compared to population
SELECT location
	, YEAR(date) AS date_year
	, MAX(population) AS population
	, SUM(CAST(new_vaccinations AS BIGINT)) as vaccinations
	, ROUND(SUM(CAST(new_vaccinations AS BIGINT))/MAX(population)*100, 2) AS vaccination_rate
FROM covid_vaccinations
WHERE continent is not null
GROUP BY location, YEAR(date)
ORDER BY date_year, location;

-- Vaccinations vs population as running total daily sum
SELECT location
	, continent
	, date
	, new_vaccinations
	, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date, location) AS running_total_cases
FROM covid_vaccinations
WHERE continent is not null
ORDER BY location, date;

-- Vaccinations vs population as running total monthly yearly sum
WITH monthly_year_vacc_CTE (location, date_year_month, monthly_new_vacc) AS (
SELECT location
	, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2)) AS date_year_month
	, SUM(CAST(new_vaccinations AS BIGINT)) AS monthly_new_vacc
FROM covid_vaccinations
WHERE continent is not null
GROUP BY location, CAST(YEAR(date) AS VARCHAR(4)) + '-' + CAST(MONTH(date) AS VARCHAR(2))
)

SELECT location
	, date_year_month
	, monthly_new_vacc
	, SUM(CAST(monthly_new_vacc AS BIGINT)) OVER (PARTITION BY location ORDER BY date_year_month, location) AS total_running_month_vacc
FROM monthly_year_vacc_CTE
ORDER BY location, date_year_month;

-- Vaccinations vs population as running total monthly sum
WITH monthly_vacc_CTE (location, date_month, monthly_new_vacc) AS (
SELECT location
	, MONTH(date) AS date_month
	, SUM(CAST(new_vaccinations AS BIGINT)) AS monthly_new_vacc
FROM covid_vaccinations
WHERE continent is not null
GROUP BY location, MONTH(date)
)

SELECT location
	, date_month
	, monthly_new_vacc
	, SUM(CAST(monthly_new_vacc AS BIGINT)) OVER (PARTITION BY date_month ORDER BY location, date_month) AS running_total_monthly_vacc
FROM monthly_vacc_CTE
ORDER BY date_month;

-- Vaccinations vs population as running total yearly sum
WITH yearly_vacc_CTE (location, date_year, yearly_new_vacc) AS (
SELECT location
	, YEAR(date) AS date_year
	, SUM(CAST(new_vaccinations AS BIGINT)) AS yearly_new_vacc
FROM covid_vaccinations
WHERE continent is not null
GROUP BY location, YEAR(date)
)

SELECT location
	, date_year
	, yearly_new_vacc
	, SUM(CAST(yearly_new_vacc AS BIGINT)) OVER (PARTITION BY date_year ORDER BY location) AS running_total_yearly_vacc
FROM yearly_vacc_CTE
ORDER BY date_year;

-- Running total vaccination rate 
WITH population_vaccines_CTE (location, continent, date, population, new_vaccinations, running_total_cases) AS (
SELECT location
	, continent
	, date
	, population
	, new_vaccinations
	, SUM(CAST(new_vaccinations AS BIGINT)) OVER (PARTITION BY location ORDER BY date, location) AS running_total_cases
FROM covid_vaccinations
WHERE continent is not null
)

SELECT *, (running_total_cases/population)*100 AS running_total_infection_rate
FROM population_vaccines_CTE;

------------------------
-- TEMPORARY TABLE
------------------------

-- POPULATION OF EACH COUNTRY
CREATE TABLE location_population
(
location VARCHAR(255),
continent VARCHAR(255),
population INT
);


INSERT INTO location_population
SELECT DISTINCT(location)
	, continent
	, population
FROM covid_deaths
WHERE continent is not null;

SELECT location
	, continent
	, population
FROM location_population

-- POPULATION OF EACH CONTINENT
CREATE TABLE continent_population
(continent VARCHAR(255),
population BIGINT);

WITH population_CTE (continent, population) AS (
SELECT continent
	, population
FROM covid_deaths
WHERE continent is not null
)
INSERT INTO continent_population
SELECT continent
	, SUM(CAST(population AS BIGINT)) AS population
FROM population_CTE
GROUP BY continent;

SELECT *
FROM continent_population;