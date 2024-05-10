USE SQLPortfolioProject;
SELECT * from
SQLPortfolioProject..CovidDeaths;

--Looking at Total cases vs Population
SELECT location,date,total_cases,total_deaths,population from
SQLPortfolioProject..CovidDeaths;

--Percentage of population affected by covid
SELECT location,date,total_cases,population,((total_cases/cast(total_deaths as INT))*100) AS InfectedPopulation from
SQLPortfolioProject..CovidDeaths
ORDER BY 1,2;
--WHERE location like '%India%';

--Looking at total deaths vs total cases
--Likehood of death if contracted with Covid according to specific loacation

--Looking at countries with highest infection rate compared to population
SELECT location,population,MAX(total_cases) AS HighestInfectionCount, MAX((total_deaths/population))*100 AS InfectedPopulation from
SQLPortfolioProject..CovidDeaths
GROUP BY location,population
order by InfectedPopulation DESC
;

--Countries with highest death count per population
SELECT location,MAX(cast(total_deaths as INT)) AS HighestDeathCount from
SQLPortfolioProject..CovidDeaths
WHERE continent IS NULL
--WHERE continent IS NOT NULL
GROUP BY location
order by HighestDeathCount DESC
;

--
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as INT)) AS TotalDeaths (SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS TotalDeathPercentage From
SQLPortfolioProject..CovidDeaths
WHERE continent  IS NOT NULL
--GROUP BY date
ORDER BY 1,2;


SELECT SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(new_cases) AS TotalCases, (SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS TotalDeathPercentage from
SQLPortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
--GROUP BY continent
ORDER BY 1,2
;

--Toatl populations cs Vaccinations


SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLPortfolioProject..CovidDeaths dea 
JOIN SQLPortfolioProject..CovidVaccinations vac
ON  dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


--Using CTE
WITH PopvsVac (Continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLPortfolioProject..CovidDeaths dea 
JOIN SQLPortfolioProject..CovidVaccinations vac
ON  dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,(RollingPeopleVaccinated/population)* 100
FROM PopvsVac;

--Creating temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
date DateTime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLPortfolioProject..CovidDeaths dea 
JOIN SQLPortfolioProject..CovidVaccinations vac
ON  dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(RollingPeopleVaccinated/population)* 100
FROM #PercentPopulationVaccinated;

--Creating view to store data for visualization
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM SQLPortfolioProject..CovidDeaths dea 
JOIN SQLPortfolioProject..CovidVaccinations vac
ON  dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
