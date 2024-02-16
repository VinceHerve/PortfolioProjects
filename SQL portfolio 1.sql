--select *
--from Covidvaccinations
--order by 3,4

select *
from CovidDeaths
where continent is not null
order by 3,4


Select location, date, total_cases, new_cases, total_deaths,population
from CovidDeaths
order by 1,2

--Looking at the Total cases vs Total deaths

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
where location like '%cameroon%'
order by 1,2

--Looking at the total cases vs population

Select location, date, total_cases, population,(total_cases/population)*100 as Death_Percentage
from CovidDeaths
where location like '%cameroon%'
order by 1,2

--Looking at countries with the highest Infection Rate compared to Population

Select location, Population,MAX(total_cases) as Highest_Infection_Count,Max((total_cases/Population))*100 as Percentage_Population_infected
from CovidDeaths
group by location, population
order by Percentage_Population_infected desc


--Showing the contries with the highest death count per Population

Select location, MAX(cast(total_deaths as int))as Total_Death_Count
from CovidDeaths
where continent is not null
group by location
order by Total_Death_Count desc

--let's break things down by continent

Select  location, MAX(cast(total_deaths as int))as Total_Death_Count
from CovidDeaths
where continent is  null
group by location
order by Total_Death_Count desc

-- Global new cases

Select  date, SUM( new_cases) as Sum_of_new_cases
from CovidDeaths
where continent is not null
group by date
order by 1,2

select SUM ( new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int)) /SUM ( new_cases)*100 as Death_percentage
from coviddeaths 
where continent is not null
order by 1,2

-- join the two tables coviddeaths and covid vaccination

select*
from CovidDeaths join CovidVaccinations on
CovidDeaths.location =CovidVaccinations.location and CovidDeaths.date=CovidVaccinations.date

--  looking at Total Population vs Vaccinations

select CovidDeaths.location,  CovidDeaths.continent, CovidDeaths.population,CovidVaccinations.new_vaccinations
from CovidDeaths join CovidVaccinations on
CovidDeaths.location =CovidVaccinations.location and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null
--group by CovidDeaths.location
order by location asc


--looking at Total Population vs Vaccinations in Cameroon

select CovidDeaths.continent , CovidDeaths.location,coviddeaths.date,CovidDeaths.population,CovidVaccinations.new_vaccinations
,SUM(convert(int,CovidVaccinations.new_vaccinations)) over(partition by CovidDeaths.location order by coviddeaths.location,coviddeaths.date)
as sum_of_vaccinated
from CovidDeaths join CovidVaccinations on 
CovidDeaths.location =CovidVaccinations.location and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.location like '%cameroon%'
order by date asc

--looking at Total Population vs Vaccinations

select CovidDeaths.continent , CovidDeaths.location,coviddeaths.date,CovidDeaths.population,CovidVaccinations.new_vaccinations
,SUM(convert(int,CovidVaccinations.new_vaccinations)) over(partition by CovidDeaths.location order by coviddeaths.location,coviddeaths.date)
as sum_of_vaccinated
from CovidDeaths join CovidVaccinations on 
CovidDeaths.location =CovidVaccinations.location and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null
order by CovidDeaths.continent asc


--Use CTE
--number of colums in the cte should match that of the table
with PopvsVac (continent,location,date,population,new_vaccinations,sum_of_vaccinated)
as
(
select CovidDeaths.continent , CovidDeaths.location,coviddeaths.date,CovidDeaths.population,CovidVaccinations.new_vaccinations
,SUM(convert(int,CovidVaccinations.new_vaccinations)) over(partition by CovidDeaths.location )
as sum_of_vaccinated
from CovidDeaths join CovidVaccinations on 
CovidDeaths.location =CovidVaccinations.location and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null

)
select*,(sum_of_vaccinated/population)*100 as Percentage_of_pop_vacs
from PopvsVac

--Temp Table
drop table if exists Percentage_of_population
create table Percentage_of_population
(continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
new_vaccination numeric,
sum_of_vaccinated numeric)

insert into Percentage_of_population
select CovidDeaths.continent , CovidDeaths.location,coviddeaths.date,CovidDeaths.population,CovidVaccinations.new_vaccinations
,SUM(convert(int,CovidVaccinations.new_vaccinations)) over(partition by CovidDeaths.location order by coviddeaths.location,coviddeaths.date)
as sum_of_vaccinated
from CovidDeaths join CovidVaccinations on 
CovidDeaths.location =CovidVaccinations.location and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null
order by CovidDeaths.continent asc


select*,(sum_of_vaccinated/population)*100 as Percentage_of_pop_vacs
from Percentage_of_population

--creating view to store dat for later visualizations

create view Percentageofvaccinated as
select CovidDeaths.continent , CovidDeaths.location,coviddeaths.date,CovidDeaths.population,CovidVaccinations.new_vaccinations
,SUM(convert(int,CovidVaccinations.new_vaccinations)) over(partition by CovidDeaths.location order by coviddeaths.location,coviddeaths.date)
as sum_of_vaccinated
from CovidDeaths join CovidVaccinations on 
CovidDeaths.location =CovidVaccinations.location and CovidDeaths.date=CovidVaccinations.date
where CovidDeaths.continent is not null
--order by CovidDeaths.continent asc

select*
from Percentageofvaccinated