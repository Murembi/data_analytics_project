/*filters the data to only show the time period for 2020*/
SELECT DISTINCT
	Country_name,
    Time_period,
    Pct_managed_drinking_water_services
FROM 
	united_nations.access_to_basic_services
WHERE
Time_period = 2020

SELECT
	Country_name,
	Time_period,
	Pct_managed_drinking_water_services,
	Pct_managed_sanitation_services,
	Est_population_in_millions,
	Est_gdp_in_billions
FROM 
	united_nations.access_to_basic_services
WHERE
	(country_name = 'Nigeria'
OR country_name = 'Ethopia'
OR country_name = 'Congo'
OR country_name = 'Egypt'
OR country_name = 'Tanzania'
OR country_name = 'Kenya'
OR country_name = 'South Africa'
)
AND Time_period BETWEEN 2019 AND 2020

SELECT
	Country_name,
	Time_period,
	Pct_managed_drinking_water_services,
	Pct_managed_sanitation_services,
	Est_population_in_millions,
	Est_gdp_in_billions
FROM 
	united_nations.access_to_basic_services
WHERE
	Time_period = 2020 
AND Pct_managed_drinking_water_services <= 50
AND Pct_managed_sanitation_services <= 50;

/*basic water sanitation service in Iran and Republic of Korea over the data time period*/
SELECT
	Country_name,
	Time_period,
	Pct_managed_sanitation_services
FROM 
	united_nations.access_to_basic_services
WHERE 
	country_name LIKE 'Iran%'
OR
	country_name LIKE '%_Republic of korea'
