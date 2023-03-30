select * from
CovidDeaths
where continent is not null
order by 3,4

--select * from
--CovidVaccinations
--order by 3,4

-- Selecting the Data that I would be using

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date,total_cases, total_deaths, (total_deaths/ total_cases)* 100 as death_percentage
from CovidDeaths
where continent is not null
order by 1,2

select location, date,total_cases, total_deaths, (total_deaths/ total_cases)* 100 as death_percentage
from CovidDeaths
where location like '%nigeria%'
and continent is not null
order by 1,2

-- Looking at the Total Cases vs Population
-- shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/ population)* 100 as populationinfected_percent
from CovidDeaths
where continent is not null
order by 1,2

select location, date, population, total_cases, (total_cases/ population)* 100 as populationinfected_percent
from CovidDeaths
where location like '%nigeria%'
and continent is not null
order by 1,2


-- Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) highestnumberofcases, max((total_cases/ population))* 100
as populationinfected_percent
from CovidDeaths
where continent is not null
group by location, population
order by 4 desc

-- Countries with the highest death count per population
select location, max(cast(total_deaths as int)) totaldeathcount, max((cast(total_deaths as int)/population)) totaldeathcountpercnetage
from CovidDeaths
where continent is not null
group by location
order by 2 desc

-- Breaking things down by continent

-- showing contitnents with the highest death count per population

select continent, max(cast(total_deaths as int)) totaldeathcount, max((cast(total_deaths as int)/population)) totaldeathcountpercnetage
from CovidDeaths
where continent is not null
group by continent
order by 2 desc


select location, max(cast(total_deaths as int)) totaldeathcount, max((cast(total_deaths as int)/population)) totaldeathcountpercnetage
from CovidDeaths
where continent is null
group by location
order by 2 desc


-- Global Numbers

select date, sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/ sum(new_cases) *100
as deathpercentage
from CovidDeaths
where continent is not null
group by date
order by 1, 2


select sum(new_cases) total_cases, sum(cast(new_deaths as int)) total_deaths, sum(cast(new_deaths as int))/ sum(new_cases) *100
as deathpercentage
from CovidDeaths
where continent is not null


-- Total Population vs Vaccinations
-- Shows the percentage of Population that has recieved at least one Covid Vaccine

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(cast(cv.new_vaccinations as int)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3


-- Use CTE

with popvsvac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from popvsvac


select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 1,2,3

-- Use Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

select *, (RollingPeopleVaccinated/population)*100 as RollingPeopleVaccinatedPercentage
from #PercentPopulationVaccinated


-- Creating view to store data for later visualization

create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null









