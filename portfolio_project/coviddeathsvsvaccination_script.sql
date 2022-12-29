SELECT * FROM portfolio_project.`coviddeaths.xlsx - coviddeaths`;

SELECT location, date, total_cases, total_deaths, new_cases, population  
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths`;

SELECT location, date, total_cases, total_deaths, new_cases, population 
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
ORDER BY location, date;

#Total death vs total cases
SELECT CONVERT('2020-01-01', date), location, total_cases,    
       total_deaths, (total_deaths/total_cases) * 100 As death_rate_percent 
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
ORDER BY location, date;

# Countries with the highest infection count
SELECT continent, location,population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as pop_infected_percent 
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
WHERE continent != ""
GROUP BY population, location, continent
ORDER BY pop_infected_percent desc;

# Highest death count by location
SELECT continent, location, MAX(CAST(total_deaths as SIGNED)) as highestdeathcount 
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
WHERE continent != ""
GROUP BY continent, location
ORDER BY highestdeathcount desc;

#Highest death count by continent.
SELECT continent, MAX(CAST(total_deaths as SIGNED)) as highestdeathcount 
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
WHERE continent != ''
GROUP BY continent
ORDER BY highestdeathcount desc;

# Global numbers infected and death percentage
SELECT CONVERT('2020-01-01', date) as date, SUM(new_cases)as total_newcases, SUM(new_deaths) as total_newdeaths, 
	   SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercent
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
WHERE continent != ''
GROUP BY date
ORDER BY DeathPercent desc;

SELECT SUM(new_cases)as total_newcases, SUM(new_deaths) as total_newdeaths, 
	   SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercent
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
WHERE continent != ''
ORDER BY DeathPercent desc;

#JOIN COVIDDEATHS TO COVIDVACCINATIONS
SELECT *
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` dea
JOIN portfolio_project.`covidvaccinations.xlsx - covidvaccinations` vac
ON dea.location = vac.location
and dea.date = vac.date;

#total population vs total vaccinated
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS running_total_vaccinated
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` dea
JOIN portfolio_project.`covidvaccinations.xlsx - covidvaccinations` vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent != ''
ORDER BY dea.location, dea.date;


#USING CTE
WITH pop_vaccinated (Continent, Date, Location, Population, New_Vaccinations, Runningtotal_Vaccinated)
AS
(
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS running_total_vaccinated
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` dea
JOIN portfolio_project.`covidvaccinations.xlsx - covidvaccinations` vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent != ''
)
SELECT * , (Runningtotal_Vaccinated/population)*100 as runningtotal_percent
FROM pop_vaccinated;

## CREATING A TEMP TABLE
DROP TABLE if exists popvaccinated;
CREATE TABLE popvaccinated
(
continent varchar(255),
date text,
location varchar(255),
population numeric,
new_vaccinations text,
running_total_vaccinated numeric
);
INSERT INTO popvaccinated
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS running_total_vaccinated
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` dea
JOIN portfolio_project.`covidvaccinations.xlsx - covidvaccinations` vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent != '';

SELECT * , (running_total_vaccinated/population)*100 as runningtotal_percent
FROM popvaccinated;

## CREATING A VIEW(GLOBAL NUMBERS OF POP VACCINATED)
CREATE VIEW percentpopvaccinated as 
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS running_total_vaccinated
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` dea
JOIN portfolio_project.`covidvaccinations.xlsx - covidvaccinations` vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent != '';

# CREATING A VIEW Global numbers infected and death percentage
DROP VIEW if exists DeathPercent;
CREATE VIEW DeathPercent as 
SELECT CONVERT('2020-01-01', date) as date, SUM(new_cases)as total_newcases, SUM(new_deaths) as total_newdeaths, 
	   SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercent
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
WHERE continent != ''
ORDER BY DeathPercent desc;

# Creating a view of Highest death count by continent.
CREATE VIEW highestdeathcount as
SELECT continent, MAX(CAST(total_deaths as SIGNED)) as highestdeathcount 
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
WHERE continent != ''
GROUP BY continent
ORDER BY highestdeathcount desc;

