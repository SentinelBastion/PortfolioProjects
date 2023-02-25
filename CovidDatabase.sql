SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4
Where continent is not null
--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Likelihoog of dying if you contracted covid in my country
SELECT location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location='Colombia' AND continent is not null
ORDER BY 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of the population contracted covid

SELECT location, date,population, total_cases, (total_cases/population)*100 as PercentInfectedPopulation
FROM PortfolioProject.dbo.CovidDeaths
WHERE location='Colombia' AND continent is not null
ORDER BY 1,2

--Looking at Countries with highest infection rates compared to Population
SELECT location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentInfectedPopulation
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
GROUP BY location,population
ORDER BY PercentInfectedPopulation DESC

--Showing Countries with the Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--breaking it down per continent

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
Where continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC
----
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Showing the continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--GLOBALNUMBERS

SELECT date, SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int)))/(SUM(new_cases))*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null 
GROUP BY date
ORDER BY 1,2
--Death percentage worldwide
SELECT  SUM(new_cases)as total_cases,SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int)))/(SUM(new_cases))*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null 
GROUP BY date
ORDER BY 1,2

--Looking at Total Population vs Vaccination
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeaopleVaccinated

FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location=vac.location AND
	dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

with PopsvsVac(Continent, location, date,population, New_Vaccinations, RollingPeaopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeaopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location=vac.location AND
	dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *,(RollingPeaopleVaccinated/population)*100 as PercentVaccinated
FROM PopsvsVac


--TEMP TABLE

DROP TABLE  if exists #PercetPopulationVaccinated
CREATE TABLE #PercetPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(225),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeaopleVaccinated numeric
)

INSERT INTO #PercetPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeaopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location=vac.location AND
	dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *,(RollingPeaopleVaccinated/population)*100 as PercentVaccinated
FROM #PercetPopulationVaccinated

--Creating View to store data for later viz

CREATE VIEW PercetPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeaopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths dea
JOIN PortfolioProject.dbo.CovidVaccinations vac
	ON dea.location=vac.location AND
	dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercetPopulationVaccinated
