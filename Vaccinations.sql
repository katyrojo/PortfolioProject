SELECT * 
	FROM PortfolioProject..CovidDeaths$
	where continent is not null 
	order by 3,4

--SELECT * 
--	FROM PortfolioProject..CovidVaccinations$
--	order by 3,4

-- Select data that we'll use

SELECT Location, date, total_cases, new_cases, total_deaths, population 
	FROM PortfolioProject..CovidDeaths$
	where continent is not null 
	order by 1,2


-- looking at total cases vs total death
-- shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	FROM PortfolioProject..CovidDeaths$
	where location like '%states'
	where continent is not null 
	order by 1,2


-- looking at total cases vs population
-- shows what percentage of population got covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
	FROM PortfolioProject..CovidDeaths$
	where location like '%states'
	order by 1,2

-- Looking at countries with highest infection rate compared to population
SELECT Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
	FROM PortfolioProject..CovidDeaths$
	--where location like '%states'
	group by location, population
	order by PercentPopulationInfected desc


SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths$
	--where location like '%states'
	where continent is not null 
	group by location
	order by TotalDeathCount desc


-- LETS BREAK THINGS DOWN BY CONTINENT

-- this makes more sense and it includes every place
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths$
	--where location like '%states'
	where continent is null 
	group by location
	order by TotalDeathCount desc


-- this shows north america as usa
-- Showing continents with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
	FROM PortfolioProject..CovidDeaths$
	--where location like '%states'
	where continent is not null 
	group by continent
	order by TotalDeathCount desc

-- Global numbers
SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
	FROM PortfolioProject..CovidDeaths$
	--where location like '%states'
	where continent is not null 
	--group by date
	order by 1,2

-- USING NEW TABLE

-- looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeorpleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
order by 2,3


-- use cte

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeorpleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
-- order by 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- temp table

DROP table if exists #PercentPopulationVaccinate -- always keep in case we want to revisit this table or change something
CREATE TABLE #PercentPopulationVaccinate
(continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeorpleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinate
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeorpleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
-- order by 2,3

Select *, (RollingPeorpleVaccinated/Population)*100
From #PercentPopulationVaccinate


-- create view to store data for later visualizations

CREATE view PercentPopulationVaccinate as 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeorpleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac. date
where dea.continent is not null
-- order by 2,3


select * from PercentPopulationVaccinate