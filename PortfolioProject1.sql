select *
From PortfolioProject..[covid-deaths]
order by 3,4

--select *
--From PortfolioProject..[covid-vaccinations]
--order by 3,4

-- Select Data to use

select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[covid-deaths]
order by 1,2

-- Total cases vs total deaths
-- Shows likelyhood of death in Country

select location, date, total_cases, total_deaths,  (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..[covid-deaths]
where location like '%state%'
order by 1,2

-- Case vs Population
-- Population that got Covid
select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
From PortfolioProject..[covid-deaths]
--where location like '%state%'
order by 1,2

-- Countries highest infection rate compared to Population
select location, population, Max(total_cases) as HighestInFectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..[covid-deaths]
--where location like '%state%'
Group By Location, population
order by PercentagePopulationInfected desc

--Countries Highest Death Count per Population
select location, Max(cast(total_deaths as int)) as TotaDeathCount
From PortfolioProject..[covid-deaths]
--where location like '%state%'
where continent is not null
Group By Location, population
order by TotaDeathCount desc

-- By Continent

select continent, Max(cast(total_deaths as int)) as TotaDeathCount
From PortfolioProject..[covid-deaths]
--where location like '%state%'
where continent is not null
Group By continent
order by TotaDeathCount desc

--Is null

select location, Max(cast(total_deaths as int)) as TotaDeathCount
From PortfolioProject..[covid-deaths]
--where location like '%state%'
where continent is null
Group By location
order by TotaDeathCount desc

--Global Numbers
select   SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage 
From PortfolioProject..[covid-deaths]
--where location like '%state%'
--where continent is not null
Group by date
order by 1,2


-- Total Pop vs Vacination

select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations )) OVER	(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..[covid-deaths] dea
join PortfolioProject..[covid-vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3
	

--Use CTE 

With PopvsVac (continent, Location, Date, Population, New_Vaccinatioins, RollingPeopleVaccinated) 
as
(
select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER	(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..[covid-deaths] dea
join PortfolioProject..[covid-vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *

From PopvsVac

--Temp Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER	(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..[covid-deaths] dea
join PortfolioProject..[covid-vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating view for Viz
Create View PercentPopulationVaccinated as
select dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER	(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..[covid-deaths] dea
join PortfolioProject..[covid-vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
FROM PercentPopulationVaccinated