SELECT *
FROM ['covid deaths'];

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM ['covid deaths']
ORDER BY 1,2;

--Looking at total cases vs total deaths

SELECT location,date,total_cases,new_cases,total_deaths,population,(total_deaths/total_cases)*100 AS 'death_percentage'
FROM ['covid deaths']
WHERE location='India'
ORDER BY 1,2;

--looking at total cases vs population
--shows what percentage of population tested positive for covid
SELECT location,date,total_cases,population,(total_cases/population)*100 AS 'positive_percentage'
FROM ['covid deaths']
--WHERE location='India'
ORDER BY 1,2;

--looking at the countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) AS 'Highestinfectioncount',MAX((total_cases/population)*100) AS 'percentagepopulationinfected'
FROM ['covid deaths']
--WHERE location='India'
GROUP BY location,population
ORDER BY percentagepopulationinfected DESC;

--showing countries with highest death count per population
SELECT location,MAX(CAST(total_deaths as int)) AS totaldeathcount
FROM ['covid deaths']
--WHERE location='India'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC;

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT location,MAX(CAST(total_deaths as int)) AS totaldeathcount
FROM ['covid deaths']
--WHERE location='India'
WHERE continent IS NULL
GROUP BY location
ORDER BY totaldeathcount DESC;

--GLOBAL NUMBERS
SELECT date,SUM(new_cases) AS 'totalcases',SUM(CAST(new_deaths AS int)) AS 'totaldeaths',SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
FROM ['covid deaths']
--WHERE location='India'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

--JOINING BOTH TABLES
--looking at total population vs total vaccination
SELECT deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations,
SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) as rollingpeoplevaccinated
FROM ['covid deaths'] deaths
JOIN ['covid vaccinations'] vaccinations
  ON deaths.location=vaccinations.location
  AND deaths.date=vaccinations.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3;

--USING CTE
With popvsvac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as(
SELECT deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations,
SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) as rollingpeoplevaccinated
FROM ['covid deaths'] deaths
JOIN ['covid vaccinations'] vaccinations
  ON deaths.location=vaccinations.location
  AND deaths.date=vaccinations.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2,3;
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac

--temp table
create table percentagepeoplevaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
insert into percentagepeoplevaccinated
SELECT deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations,
SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) as rollingpeoplevaccinated
FROM ['covid deaths'] deaths
JOIN ['covid vaccinations'] vaccinations
  ON deaths.location=vaccinations.location
  AND deaths.date=vaccinations.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2,3;
select *,(rollingpeoplevaccinated/population)*100
from percentagepeoplevaccinated

--creating view to store data for later visualizations
create view vaccinatedpopulation as 
SELECT deaths.continent,deaths.location,deaths.date,deaths.population,vaccinations.new_vaccinations,
SUM(CONVERT(int,vaccinations.new_vaccinations)) OVER (PARTITION BY deaths.location ORDER BY deaths.location,deaths.date) as rollingpeoplevaccinated
FROM ['covid deaths'] deaths
JOIN ['covid vaccinations'] vaccinations
  ON deaths.location=vaccinations.location
  AND deaths.date=vaccinations.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2,3;

select *
from vaccinatedpopulation;

