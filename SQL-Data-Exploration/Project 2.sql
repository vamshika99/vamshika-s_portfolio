-- to check if the data is uploaded correctly

select * from PortfolioProject..CovidDeaths

select * from PortfolioProject..CovidVaccinations;

-- to get the different country lists present in the dataset

select distinct location from PortfolioProject..CovidDeaths

-- to get a breakdown by continent 

select continent, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by population

-- to get basic cases and death rates by country

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where location like '%states'
order by 1, 2

--looking at total cases vs total deaths
-- likelihood of dying if we contract covid based on the country we live

select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states'
order by 1, 2

-- Looking at total cases vs population
-- Shows what percentage of population has got covid


select location, date, total_cases, population, (population/total_cases)*100 as CasesPercentage
from PortfolioProject..CovidDeaths
where location like '%states' and continent is not null
order by 1, 2

-- Looking at countries with the high infection rates

select location, max(total_cases) as HighestCount, population, max(population/total_cases)*100 as HighestPopulationAffected
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by HighestPopulationAffected desc

-- Showing countries with highest death count

select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by HighestDeathCount desc

-- showing continent with highest death count

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by HighestDeathCount desc

-- to cross verify the output

select continent, max(cast(total_deaths as int)) 
from PortfolioProject..CovidDeaths 
where continent = 'Oceania'
group by continent

-- new cases and deaths analysis

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int)) / sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by DeathPercentage desc

-- Looking at total population vs vaccinations

select cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location, cd.date) as RollingCountVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3


--with CTE to get the rolling count of vaccinations in each country by partioning the window function by location

with PopulationVaccinated(date, continent, location, population, new_vaccinations, RollingCountVaccinated)
as
(
select cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location, cd.date) as RollingCountVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
)
select *, (RollingCountVaccinated/population)*100 as VaccinatedPercentage from PopulationVaccinated

--temp table usage to get percentage of population vaccinated
--temp table we are creating here #PeopleVaccinated exists for the entire database and can be used whenever needed

DROP Table if exists #PeopleVaccinated
create table #PeopleVaccinated(
date datetime,
continent nvarchar(255),
location nvarchar(255),
population numeric,
new_vaccinations numeric,
RollingCountVaccinated numeric)

insert into #PeopleVaccinated
select cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location, cd.date) as RollingCountVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
--where cd.continent is not null
--order by 2,3

select *, (RollingCountVaccinated/population)*100 as VaccinatedPercentage from #PeopleVaccinated

--Creating a view to store the data(in this case number of people) for future visualizations

create view PeopleVaccinated as
select cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as int)) over(partition by cd.location order by cd.location, cd.date) as RollingCountVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

select * from PeopleVaccinated





