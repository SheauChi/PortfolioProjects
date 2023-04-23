select *
from CovidDeaths$
order by 3,4

--select *
--from CovidVaccinations$
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeaths$
where location like 'malay%'
order by 1,2

select location, date, total_cases, population, (total_cases/population)*100 as case_percentage
from CovidDeaths$
where location like 'malay%'
order by 1,2

--looking at country that has highest infection rate compared to population

select location, population, max(total_cases) highestinfectioncount, max((total_cases/population)*100) highestinfectionrate
from CovidDeaths$
group by location, population
order by highestinfectionrate desc

--showing country with highest death count per population
select location, population, max(cast(total_deaths as int)) highestdeathcount, max((total_deaths/population)*100) highestdeathrate
from CovidDeaths$
where continent is not null
group by location, population
order by highestdeathcount desc

--breaks thing down by continent
--showing continent with highest death

select continent, max(cast(total_deaths as int)) totaldeathcount
from CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc
 
 --Global Numbers
 select date, sum(new_cases) dailytotalcases, sum(cast (new_deaths as int)) dailytotaldeath, sum(cast (new_deaths as int))/sum(new_cases)*100 deathpercent
from CovidDeaths$
where continent is not null
group by date
order by 1

 select sum(new_cases) dailytotalcases, sum(cast (new_deaths as int)) dailytotaldeath, sum(cast (new_deaths as int))/sum(new_cases)*100 deathpercent
from CovidDeaths$
where continent is not null
--group by date

--covid vaccination

select *
from CovidVaccinations$

--looking at total vaccination vs population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.date) totalvaccination
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
where dea.continent is not null
order by 2,3

--use CTE

with CTE_PopvsVac as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.date) rollingpplvaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (rollingpplvaccinated/population)*100 rollingpplvaccinatedpercent
from CTE_PopvsVac

--use temp table
Drop table if exists #PercentPplVaccinated
create table #PercentPplVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPplVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.date) rollingpplvaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100 
from #PercentPplVaccinated 

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.date) rollingpplvaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null