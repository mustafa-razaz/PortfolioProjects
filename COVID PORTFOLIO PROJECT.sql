SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4;


SELECT location, date , total_cases,new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 ;


--Looking at total cases vs total death (Death Percentage)
--Shows likelihood of dying if you contract covid in your country

SELECT location, date , total_cases, total_deaths , (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states'
ORDER BY 1,2 ;

--Looking at Total cases vs Population 
--Show percentage of population got infected

SELECT location, date , total_cases,Population,(total_cases/population)*100 as PopulationPercentageInfection
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 ;

--Looking at countries with highest infection rate compared to poplation 

SELECT location,population, MAX(total_cases) as max_num_cases  , MAX(total_cases/population)*100 as Highest_infection_percentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Highest_infection_percentage DESC ;

--Looking at countries with highest death count compared to poplation 

SELECT location, MAX(cast(total_deaths as int)) as max_num_death  
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY max_num_death DESC ;
 

 --Lets break things down by continent
 --Showing continent with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as max_num_death  
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY max_num_death DESC ;


--Global Numbers

SELECT  date , SUM(new_cases) AS TOTAL_CASES, SUM(cast(new_deaths as int)) AS TOTAL_DEATHS , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY DATE
ORDER BY 1,2 ;

--Total number of new cases and new deaths

SELECT   SUM(new_cases) AS TOTAL_CASES, SUM(cast(new_deaths as int)) AS TOTAL_DEATHS , SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 ;

--View the vaccinations table

SELECT *
FROM PortfolioProject..CovidVaccinations

--JOIN TWO TABLES 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations  vac
   ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Looking at Total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations  vac
   ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

--USE CTE
WITH PopvsVac (Continent, Location, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations  vac
   ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PeopleVaccinatedPerDayPercentage
FROM PopvsVac



--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(250),
Location nvarchar(255),
Date datetime,
Population numeric ,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations  vac
   ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100 as PeopleVaccinatedPerDayPercentage
From #PercentPopulationVaccinated

--Creating View to store data for later Visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations  vac
   ON dea.location = vac.location 
   and dea.date = vac.date
WHERE dea.continent is not null

Select *
From PercentPopulationVaccinated