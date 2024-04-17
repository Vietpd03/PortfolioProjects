select * from PortfolioProject..CovidDeaths$
order by 3,4

--select * from PortfolioProject..CovidVaccinations$
--order by 3,4

-- select data using

select Location, date, total_cases,new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2


--looking at total_cases, total_Deaths
--shows likelihood of dying if you contact covid in your country
select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2


--looking at total_cases, Population
-- show percentage of population got covid
select Location, date, Population, total_cases, (total_cases/Population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
order by 1,2

-- looking at countries with highest Infection rate campare to Population
select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths$
group by Location, Population
--where location like '%states%'
order by PercentagePopulationInfected DESC


--Showing countries with highest deaths count per Population 
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by Location
--where location like '%states%'
order by TotalDeathCount DESC


--Let's Breakthing out by content

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
--where location like '%states%'
order by TotalDeathCount DESC


--GLOBAL NUMBERS
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPercentage --total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at total Vaccinations and Population
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(numeric,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths$ dea join PortfolioProject..CovidVaccinations$ vac
on dea.Location=vac.Location and dea.date=vac.date
where dea.continent is not null
order by 2,3



--USE CTE
with PopvsVac (Continent,Location,Date , Population,New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(numeric,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths$ dea join PortfolioProject..CovidVaccinations$ vac
on dea.Location=vac.Location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/Population)*100 from PopvsVac



--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255),
Date datetime, 
Population Numeric, New_vaccinations Numeric, RollingPeopleVaccinated Numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(numeric,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths$ dea join PortfolioProject..CovidVaccinations$ vac
on dea.Location=vac.Location and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
select * ,(RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated



--creating view to store date for later visualizations 
create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(numeric,vac.new_vaccinations )) OVER (Partition by dea.Location Order by dea.Location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from PortfolioProject..CovidDeaths$ dea join PortfolioProject..CovidVaccinations$ vac
on dea.Location=vac.Location and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from PercentPopulationVaccinated


