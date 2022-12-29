SELECT SUM(new_cases)as total_newcases, SUM(new_deaths) as total_newdeaths, 
	   SUM(new_deaths)/SUM(new_cases) * 100 as DeathPercent
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
WHERE continent != ''
ORDER BY DeathPercent desc;

SELECT continent, SUM(new_deaths) as total_deaths
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
WHERE continent != '' and location not in ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY total_deaths desc;

SELECT location,population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as pop_infected_percent 
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
WHERE continent != ""
GROUP BY location, population
ORDER BY pop_infected_percent desc;

SELECT location,population,CONVERT('2020-01-01', date) as date, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population))*100 as pop_infected_percent 
FROM portfolio_project.`coviddeaths.xlsx - coviddeaths` 
WHERE continent != ""
GROUP BY location, population, date
ORDER BY pop_infected_percent desc;
