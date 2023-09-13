Select * from ProjectPortfolio..CovidDeaths 
where continent is not null
ORDER BY 3,4;

--Select * from ProjectPortfolio..CovidVaccination ORDER BY 3,4;

-- Selecting data that we're going to be using

select location, date, total_cases, new_cases, total_deaths, population 
From ProjectPortfolio..CovidDeaths where continent is not null

-- Total cases vs Total Deaths

select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From ProjectPortfolio..CovidDeaths where location like '%states%' and continent is not null

-- Show what percentage of the population got covid

select location, date, total_cases,  total_deaths, (total_cases/population)*100 AS PercentPopulationInfected
From ProjectPortfolio..CovidDeaths where location like '%states%'

-- Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) AS PercentPopulationInfected
from ProjectPortfolio..CovidDeaths where continent is not null
group by location,population
order by PercentPopulationInfected desc 

-- Showing the countries with highest death count per population

select location, max(total_deaths) as TotalDeathCount
from ProjectPortfolio..CovidDeaths 
where continent is not null
group by location
order by TotalDeathCount desc 

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- showing the continents with highest death count per population

select CONTINENT, max(total_deaths) as TotalDeathCount
from ProjectPortfolio..CovidDeaths 
where continent is NOT null
group by CONTINENT
order by TotalDeathCount desc


-- Global Numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
From ProjectPortfolio..CovidDeaths --where location like '%states%' 
where continent is not null
--group by date
order by 1,2

-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast (vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

WITH popVSvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast (vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

) select *, (RollingPeopleVaccinated/population)*100
from popVSvac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast (vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualization

---- PercentPoluationVaccinated
create view PercentPoluationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast (vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from ProjectPortfolio..CovidDeaths dea
join ProjectPortfolio..CovidVaccination vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

---- Countries with highest death per population


create view CountryDeathPerPop as
select location, max(total_deaths) as TotalDeathCount
from ProjectPortfolio..CovidDeaths 
where continent is not null
group by location
--order by TotalDeathCount desc 
