COVID-19 SQL Data Analysis Project
This project uses real-world COVID-19 data to perform structured analysis using SQL. It helps you explore global pandemic trends, death rates, and vaccination progress across countries.

1)Dataset Used
Covid_deaths.csv

Columns: location, continent, date, total_cases, new_cases, total_deaths, population, etc.

Covid_vaccinations.csv

Columns: location, date, new_vaccinations, people_vaccinated, people_fully_vaccinated, etc.

2)Project Objectives
Analyze total cases, deaths, and vaccination data

Identify most affected countries by case rate and death rate

Understand vaccination trends globally and per country

Create views for better dashboard integration

Prepare data for Excel or Power BI dashboards

🛠3)SQL Environment Setup
Load the CSV files into a relational database such as MySQL, PostgreSQL, or SQLite.

Ensure correct datatypes:

date as DATE

new_cases, total_cases, new_deaths, total_deaths, population, etc., as numeric (INT or FLOAT)

Example Table Creation (MySQL-like syntax):

sql
Copy
Edit
CREATE TABLE covid_deaths (
  location VARCHAR(100),
  continent VARCHAR(100),
  date DATE,
  population BIGINT,
  total_cases FLOAT,
  new_cases FLOAT,
  total_deaths FLOAT,
  new_deaths FLOAT
);

CREATE TABLE covid_vaccinations (
  location VARCHAR(100),
  date DATE,
  new_vaccinations BIGINT,
  people_vaccinated BIGINT,
  people_fully_vaccinated BIGINT
);
4)Key SQL Queries
4.1)Total Cases vs Total Deaths (Mortality Rate)
sql
Copy
Edit
SELECT location, date, total_cases, total_deaths,
       (total_deaths / total_cases) * 100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL;
4.2)Total Cases vs Population (Infection Rate)
sql
Copy
Edit
SELECT location, population, MAX(total_cases) AS highest_cases,
       MAX((total_cases / population) * 100) AS infection_rate
FROM covid_deaths
GROUP BY location, population
ORDER BY infection_rate DESC
LIMIT 10;
4.3)Countries with Highest Death Count
sql
Copy
Edit
SELECT location, MAX(total_deaths) AS highest_deaths
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_deaths DESC
LIMIT 10;
4.4)Vaccination Progress with Rolling Sum
sql
Copy
Edit
SELECT d.location, d.date, d.population,
       v.new_vaccinations,
       SUM(CAST(v.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY d.location ORDER BY d.date) AS cumulative_vaccinations
FROM covid_deaths d
JOIN covid_vaccinations v
  ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;
5)Suggested Visualizations (in Power BI or Excel)
Bar Chart: Top 10 countries by infection rate

Line Graph: New cases/deaths over time

Area Chart: Cumulative vaccinations by country

Map Chart: Total deaths by continent

KPI Cards: Total Cases, Total Deaths, Total Vaccinations

6)Tools Used
SQL (MySQL / PostgreSQL / SQLite)

Excel or Power BI for dashboard creation

Python (optional for data processing or export)

Markdown for documentation

6)Final Notes
Clean and preprocess data to handle NULLs

Optimize with views or indexes for performance

Use exported tables for dashboard analysis

Ideal for capstone, college projects, or real-world analysis
