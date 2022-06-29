SELECT *
FROM PortfolioProject..CovidDeaths


--THE PERCENTAGE DEATH IN NIGERIA WILL SHOW US THE LIKELIHOOD OF DYING IF YOU CONTRACT THE DISEASE
-- SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT THE DISEASE


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS percentage_death
FROM  PortfolioProject..CovidDeaths
WHERE location= 'Nigeria'
AND total_deaths IS NOT NULL -- willshow from when deaths started to occur
ORDER BY 1, 2

-- LOOKONG AT THE PERCENTAGE OF PEOPLE INFECTED

SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentage_infected
FROM  PortfolioProject..CovidDeaths
WHERE location= 'Nigeria'
AND total_deaths IS NOT NULL
ORDER BY 1, 2


--Looking at countries with highest infection rate compared to population including date

SELECT location,date, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentPopulationInfected
FROM  PortfolioProject..CovidDeaths
--WHERE location= 'Nigeria'
--AND total_deaths IS NOT NULL
GROUP BY location, Population,date
ORDER BY PercentPopulationInfected DESC

-- SHOWING COUNTRIES WITH HIGHEST DEATH PERCENTAGE

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location= 'Nigeria'
--AND total_deaths IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--CREATING A VIEW

CREATE VIEW CountriesDeathPercentage AS
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location= 'Nigeria'
--AND total_deaths IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC


--OPENING THE VIEW
SELECT *
FROM CountriesDeathPercentage



BREAKING IT DOWN TO CONTINENT

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location= 'Nigeria'
--AND total_deaths IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT  SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_, SUM(cast(new_deaths as int))/sum(new_cases)*100 AS percentage_death
FROM PortfolioProject..CovidDeaths
--WHERE location= 'Nigeria'
WHERE continent IS NOT NULL
--AND total_deaths IS NOT NULL -- willshow from when deaths started to occur
--GROUP BY DATE
ORDER BY 1, 2

--CREATING VIEW FOR GLOBAAL NUMBERS
CREATE VIEW GlobalNumbers AS
SELECT  SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_, SUM(cast(new_deaths as int))/sum(new_cases)*100 AS percentage_death
FROM PortfolioProject..CovidDeaths
--WHERE location= 'Nigeria'
WHERE continent IS NOT NULL
--AND total_deaths IS NOT NULL -- willshow from when deaths started to occur
--GROUP BY DATE
ORDER BY 1, 2

--OPENING THE GLOBAL VIEW
SELECT *
FROM GlobalNumbers



--Combining ..CovidVaccinations with ..CovidDeath

SELECT * 
FROM PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
ON dea.location=vac.location
AND dea.date=vac.date
--WHERE continent IS NOT NULL
WHERE (vac.continent + dea.continent) IS NOT NULL


--Looking at Total population vs vaccinations
--THIS SECOND PART GIVES US OUR TOTAL VACCINATIONS BY LOCATION 

SELECT dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations
, SUM(CONVERT( bigint, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date )--ORDER BY dea.location, dea.date
AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100 -- CANT PERFORM CALCULATIONS ON A NEW COLUMN JUST CREATED
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--TO PERFORM CALCULATION ON THE NEW TABLE "RollingPeopleVaccinated"
-- I WILL BE USING TEMP TABLE

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Population numeric,
new_vaccination bigint,
RollingPeopleVaccinated bigint,
Date DATETIME,
)
insert into #PercentagePopulationVaccinated
SELECT  dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT( bigint, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date )
AS RollingPeopleVaccinated,dea.date
--(RollingPeopleVaccinated/population)*100 -- CANT PERFORM CALCULATIONS ON A NEW COLUMN JUST CREATED
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT DISTINCT continent location, new_vaccination, RollingPeopleVaccinated, Date,(RollingPeopleVaccinated/Population)*100 AS PercentagePopulationVaccinated
FROM #PercentagePopulationVaccinated
ORDER BY 2


--CREATING VIEWS TO STORE DATA FOR VISUALIZATION
CREATE VIEW PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT( bigint, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location, dea.date )
AS RollingPeopleVaccinated,dea.date
--(RollingPeopleVaccinated/population)*100 -- CANT PERFORM CALCULATIONS ON A NEW COLUMN JUST CREATED
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

--SINCE I CANT SEE MY "VIEWS" IN THE WINDOW TO MY LEFT, THIS HELPS ME DISPLAY THEM
SELECT 
OBJECT_SCHEMA_NAME(o.object_id) schema_name,o.name
FROM
sys.objects as o
WHERE
o.type = 'V';

SELECT *
FROM PercentagePopulationVaccinated


--COUNTRIES TO FIRST RECORD A CASE OF THE DISEASE
--select *
--from PortfolioProject..CovidDeaths


SELECT DISTINCT TOP 10 location, new_cases, date
FROM PortfolioProject..CovidDeaths
WHERE (new_cases IS NOT NULL) AND (new_cases != 0)
AND location != 'High income' AND location !='Lower middle income' AND location!= 'Asia' AND location!= 'Upper middle income' AND location!= 'World'
--AND LOCATION IS NOT (Upper middle income
ORDER BY DATE ASC


--CREATING A VIEW FOR LATER VISUALISATION
CREATE VIEW FirstTenCountriesToRecordDisease as
SELECT DISTINCT TOP 10 location, new_cases, date
FROM PortfolioProject..CovidDeaths
WHERE (new_cases IS NOT NULL) AND (new_cases != 0)
AND location != 'High income' AND location !='Lower middle income' AND location!= 'Asia' AND location!= 'Upper middle income' AND location!= 'World'
--AND LOCATION IS NOT (Upper middle income
ORDER BY DATE ASC

