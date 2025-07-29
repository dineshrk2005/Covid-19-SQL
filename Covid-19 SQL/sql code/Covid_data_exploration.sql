
/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

create schema covid;
use covid;

drop table if exists covid_deaths;
create table covid_deaths
(iso_code varchar(50),
continent varchar(50),
location varchar(50),
date date,
population bigint,
total_cases int,
new_cases int,
new_cases_smoothed float,
total_deaths int,
new_deaths int,
new_deaths_smoothed float,
total_cases_per_million float,
new_cases_per_million float,
new_cases_smoothed_per_million float,
total_deaths_per_million float,
new_deaths_per_million float,
new_deaths_smoothed_per_million float,
reproduction_rate float,
icu_patients int,
icu_patients_per_million float,
hosp_patients int,
hosp_patients_per_million float,
weekly_icu_admissions float,
weekly_icu_admissions_per_million float,
weekly_hosp_admissions float,
weekly_hosp_admissions_per_million float);

load data infile 'Covid_deaths.csv' into table covid_deaths
fields terminated by ','
ignore 1 lines;

select * from covid_deaths;

drop table if exists covid_vaccinations;
create table covid_vaccinations
(iso_code varchar(50),
continent varchar(50),
location varchar(50),
date date,
population bigint,
new_tests int,
total_tests int,
total_tests_per_thousand float,
new_tests_per_thousand float,
new_tests_smoothed int,
new_tests_smoothed_per_thousand float,
positive_rate float,
tests_per_case float,
tests_units varchar(50),
total_vaccinations int,
people_vaccinated int,
people_fully_vaccinated int,
new_vaccinations int,
new_vaccinations_smoothed int,
total_vaccinations_per_hundred float,
people_vaccinated_per_hundred float,
people_fully_vaccinated_per_hundred float,
new_vaccinations_smoothed_per_million int,
stringency_index float,
population_density float,
median_age float,
aged_65_older float,
aged_70_older float,
gdp_per_capita float,
extreme_poverty float,
cardiovasc_death_rate float,
diabetes_prevalence float,
female_smokers float,
male_smokers float,
handwashing_facilities float,
hospital_beds_per_thousand float,
life_expectancy float,
human_development_index float);

load data infile 'Covid_vaccinations.csv' into table covid_vaccinations
fields terminated by ','
ignore 1 lines;

select * from covid_vaccinations;

select * 
from covid_deaths
where continent <> 'null'
order by 3,4;

-- Selecting Data that we will be using

select location
, date
, total_cases
, new_cases
, total_deaths
, population
from covid_deaths
where continent <> 'null'
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location
, date
, total_cases
, total_deaths
, round((total_deaths / total_cases) * 100,1) as death_percentage
from covid_deaths
where continent <> 'null'
order by 2;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location
, date
, total_cases
, population
, round((total_cases / population) * 100, 1) as infection_rate
from covid_deaths
where continent <> 'null'
order by 2;

-- Countries with Highest Infection Rate compared to Population

select location
, population
, max(total_cases) as highest_infection_cnt
, round(max(total_cases / population) * 100, 1) as highest_infection_rate
from covid_deaths
where continent <> 'null'
group by 1
order by 4 desc;

-- Countries with Highest Death Count per Population

select location
, population
, max(total_deaths) as max_deaths
from covid_deaths
where continent <> 'null'
group by 1
order by 3 desc;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent
, max(total_deaths) as max_deaths
from covid_deaths
where continent <> 'null'
group by 1
order by 2 desc;


-- GLOBAL NUMBERS

-- global cases and deaths data

select date
, sum(new_cases)
, sum(new_deaths)
, round((sum(new_deaths) / sum(new_cases)) * 100, 1) as death_percentage
from covid_deaths
where continent <> 'null'
group by 1
order by 1, 2;

-- total global cases and deaths data

select sum(new_cases)
, sum(new_deaths)
, round((sum(new_deaths) / sum(new_cases)) * 100, 1) as death_percentage
from covid_deaths
where continent <> 'null';

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dead.continent
, dead.location
, dead.date
, dead.population
, vacc.new_vaccinations
, sum(vacc.new_vaccinations) over(partition by dead.location order by dead.location, dead.date) as rolling_people_vaccinated
from covid_deaths dead
join covid_vaccinations vacc
on dead.location = vacc.location
and dead.date = vacc.date
where dead.continent <> 'null'
order by 1.2;

-- Using CTE to perform Calculation on Partition By in previous query

with popvacc as (
select dead.continent
, dead.location
, dead.date
, dead.population
, vacc.new_vaccinations
, sum(vacc.new_vaccinations) over(partition by dead.location order by dead.location, dead.date) as rolling_people_vaccinated
from covid_deaths dead
join covid_vaccinations vacc
on dead.location = vacc.location
and dead.date = vacc.date
where dead.continent <> 'null'
order by 1.2)

select *
, (rolling_people_vaccinated/population) * 100 as rolling_percent_people_vaccinated
from popvacc;

-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists percent_pop_vacc;
create table percent_pop_vacc (
continent varchar(50),
location varchar(50),
date date,
population bigint,
new_vaccinations int,
rolling_people_vaccinated int );

insert into percent_pop_vacc
select dead.continent
, dead.location
, dead.date
, dead. population
, vacc.new_vaccinations
, sum(vacc.new_vaccinations) over(partition by dead.location order by dead.location, dead.date) as rolling_people_vaccinated
from covid_deaths dead
join covid_vaccinations vacc
on dead.location = vacc.location
and dead.date = vacc.date;
-- where dead.continent <> 'null'
-- order by 1.2;

select *
, (rolling_people_vaccinated/population) * 100 as rolling_percent_people_vaccinated
from percent_pop_vacc
where continent <> 'null';


-- Creating View to store data for later visualizations

create view percent_pop_vaccinated as
select dead.continent
, dead.location
, dead.date
, dead.population
, vacc.new_vaccinations
, sum(vacc.new_vaccinations) over(partition by dead.location order by dead.location, dead.date) as rolling_people_vaccinated
from covid_deaths dead
join covid_vaccinations vacc
on dead.location = vacc.location
and dead.date = vacc.date
where dead.continent <> 'null';

