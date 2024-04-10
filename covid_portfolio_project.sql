select*
from CoronaVactinations;

SELECT *
from CoronaDeath;
where continent <> ''

-- select data which is used for the ananlysis

Select location, date, total_cases, new_cases, total_deaths, population
from CoronaDeath 
order by 1, 2

-- Focusing on total cases and total deaths
-- Shows likelihood of dying in the Netherlands
Select Location, date, total_cases, total_deaths, (total_deaths*100.0/total_cases) as DeathPercentage
from CoronaDeath 
where location = "Netherlands"
order by 1, 2
 -- 'total_deaths' and 'tatal_cases' are integer columns, dividing them becomes an ineteger division result.

-- Focusing on total cases and population
-- shows what percentage of population  got corona in Japan
Select Location, date, total_cases, population , (total_cases*100.0/population) as PercentagePopulationInfected
from CoronaDeath 
--where location = "Japan"
order by 1, 2

-- focusing on countries with highest infection rate compared to population
SELECT 
    location, 
    population, 
    date,
    MAX(total_cases) AS HighestInfectionRecord, 
    MAX(CASE WHEN population <> 0 THEN total_cases * 100.0 / population ELSE 0 END) AS PercentagePopulationInfected
FROM 
    CoronaDeath 
WHERE 
    total_cases IS NOT NULL AND total_cases <> ''
GROUP BY 
    location, 
    population,
    date
ORDER BY 
    PercentagePopulationInfected DESC;

--- some data of total_cases are empty, therefore I need to use where total_cases <> ''
   
-- show countries with highest death count per population
SELECT 
    location,  
    MAX(total_deaths) AS TotalDeathRecord 
FROM 
    CoronaDeath 
WHERE 
    total_deaths  IS NOT NULL AND total_deaths <> '' AND continent <> ''
GROUP BY 
    location
ORDER BY 
    TotalDeathRecord DESC;
   
-- focusing on the number per continents
SELECT 
    location,  
    MAX(total_deaths) AS TotalDeathRecord 
FROM 
    CoronaDeath 
WHERE 
    total_deaths  IS NOT NULL AND total_deaths <> '' AND continent = ''
GROUP BY 
    location  
ORDER BY 
    TotalDeathRecord DESC;
   
--- some of columns have empty ones instead of null
   
-- showing continents with the highest death record per population
SELECT 
    continent,  
    MAX(total_deaths) AS TotalDeathRecord 
FROM 
    CoronaDeath 
WHERE 
    total_deaths  IS NOT NULL AND total_deaths <> '' AND continent <> ''
GROUP BY 
    continent 
ORDER BY 
    TotalDeathRecord DESC;
   
 
 -- global numbers
SELECT  
	SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))*100.0/SUM(new_cases) as DeathPercentage
FROM 
	CoronaDeath 
WHERE 
	continent <> ''
--GROUP by date
ORDER by 1, 2

-- compare total population and vacctination 

SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION by cd.location ORDER by cd.location, cd.date) as UpdatePeopleVaccinated
	--(UpdatePeopleVaccinated/population)*100
FROM 
    CoronaDeath cd 
JOIN 
    CoronaVaccinations cv 
    ON cd.location = cv.location 
    AND cd.date = cv.date
WHERE 
	cd.continent <> ''
ORDER BY 2,3

-- USE CTE
WITH PopvsVac (continent, location, date, population,new_vaccinations, UpdatePeopleVaccinated)
as
(
SELECT 
	cd.continent, 
	cd.location, 
	cd.date, 
	cd.population, 
	cv.new_vaccinations, 
	SUM(cv.new_vaccinations) OVER (PARTITION by cd.location ORDER by cd.location, cd.date) as UpdatePeopleVaccinated
	--(UpdatePeopleVaccinated/population)*100
FROM 
    CoronaDeath cd 
JOIN 
    CoronaVaccinations cv 
    ON cd.location = cv.location 
    AND cd.date = cv.date
WHERE 
	cd.continent <> ''
--ORDER BY 2,3
)
SELECT *, (UpdatePeopleVaccinated/population)*100
FROM PopvsVac




-- tempTable
CREATE TABLE IF NOT Exists PercentagePopulationVaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    UpdatePeopleVaccinated NUMERIC
);

INSERT INTO PercentagePopulationVaccinated
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations, 
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS UpdatePeopleVaccinated
FROM 
    CoronaDeath cd 
JOIN 
    CoronaVaccinations cv 
    ON cd.location = cv.location 
    AND cd.date = cv.date;

SELECT *, (UpdatePeopleVaccinated * 100.0 / population) AS PercentagePopulationVaccinated
FROM PercentagePopulationVaccinated;




-- making view to store data for later visualizations

CREATE VIEW PercentePopulationVaccinated as
SELECT 
    cd.continent, 
    cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations, 
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS UpdatePeopleVaccinated
FROM 
    CoronaDeath cd 
JOIN 
    CoronaVaccinations cv 
    ON cd.location = cv.location 
    AND cd.date = cv.date
WHERE
	cd.continent <> '';



