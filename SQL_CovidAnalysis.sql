SELECT *
FROM PorfolioProject.dbo.CovidDeaths

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract COVID in New Zealand
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PorfolioProject.dbo.CovidDeaths
WHERE location LIKE '%new zealand%'
ORDER BY location, date

--Looking at Total Cases vs Population
--Shows what percentage of population got COVID in New Zealand
SELECT location, date, total_cases, population, (total_cases/population)*100 AS CovidPercentage
FROM PorfolioProject.dbo.CovidDeaths
WHERE location LIKE '%new zealand%' 
ORDER BY location, date

--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Looking at countries with highest infection rate compared to population by day
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC


--Looking at countries with highest death count per population
SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC		

--Looking at continents with highest death count per population
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC	

--Looking at Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM PorfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL

--Joining Death & Vaccination tables
SELECT *
FROM PorfolioProject.dbo.CovidDeaths dea
JOIN PorfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Looking at Total Population vs Vaccinations with CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, Accumulating_vaccinations)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Accumulating_vaccinations
FROM PorfolioProject.dbo.CovidDeaths dea	
JOIN PorfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (Accumulating_vaccinations/Population) * 100 AS Percentage_pop_vaccinated
FROM PopvsVac

--Creating View to store data for later visualizations
Create View PercentagePopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Accumulating_vaccinations
FROM PorfolioProject.dbo.CovidDeaths dea	
JOIN PorfolioProject.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


