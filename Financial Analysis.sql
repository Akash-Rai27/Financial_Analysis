CREATE DATABASE Economic_Data;
USE Economic_Data;

ALTER PROCEDURE values_all
AS
	SELECT e.*,[GDP_in_billion],[Agriculture],[Industry],[Services],[Technology] FROM [dbo].[Economy_Productivity_SD_India] e JOIN [dbo].[GDP_Sector_Income_2019_2023_30Cities] g ON e.City=g.City AND e.Year=g.Year;

EXEC values_all;

SELECT City,AVG([GDP_in_billion]) AS avg_GDP FROM [dbo].[GDP_Sector_Income_2019_2023_30Cities] GROUP BY City ORDER BY City;

SELECT e.City,e.Year,e.[R_D_Expenditure_of_GDP],g.[GDP_in_billion] FROM [dbo].[Economy_Productivity_SD_India] e JOIN [dbo].[GDP_Sector_Income_2019_2023_30Cities] g 
ON e.[City]=g.[City] AND e.Year=g.Year ORDER BY e.City,e.Year;

ALTER PROCEDURE R_D_Expense @Search_Year smallint, @City_name nvarchar(50)
AS
SELECT e.City,e.Year,e.[R_D_Expenditure_of_GDP],g.[GDP_in_billion] FROM [dbo].[Economy_Productivity_SD_India] e JOIN [dbo].[GDP_Sector_Income_2019_2023_30Cities] g 
ON e.[City]=g.[City] AND e.Year=g.Year WHERE e.Year=@Search_Year AND e.City=@City_name
 ORDER BY e.City,e.Year;

EXEC R_D_Expense @Search_Year=2019, @City_Name='Ahmedabad';

SELECT e.Year, e.City,([R_D_Expenditure_of_GDP]/[GDP_in_billion])*100 AS R_D_Ratio, SUM([Patents_per_100_000_Inhabitants]) AS Patents_per_100_000_Inhabitants FROM [dbo].[Economy_Productivity_SD_India] e JOIN
[dbo].[GDP_Sector_Income_2019_2023_30Cities] g ON e.Year=g.Year AND e.City=g.City GROUP BY e.Year,e.City,([R_D_Expenditure_of_GDP]/[GDP_in_billion])*100
ORDER BY Patents_per_100_000_Inhabitants DESC;





SELECT City,Year,Unemployment_Rate, CASE WHEN Unemployment_Rate>AVG(Unemployment_Rate) THEN 'High_Employment'
ELSE 'Low_Employment' END AS Employment_Bracket FROM [dbo].[Economy_Productivity_SD_India] GROUP BY City,Year,Unemployment_Rate;


SELECT [City],[Year],[GDP_in_billion], ROW_NUMBER() OVER(PARTITION BY [Year] ORDER BY [GDP_in_billion] DESC) AS gdp_ranking_by_year FROM [dbo].[GDP_Sector_Income_2019_2023_30Cities];


SELECT City,Year,[GDP_in_billion], LAG([GDP_in_billion]) OVER w AS previous_year_GDP, LEAD([GDP_in_billion]) OVER w AS next_year_GDP
FROM [dbo].[GDP_Sector_Income_2019_2023_30Cities] WINDOW w AS (PARTITION BY City ORDER BY Year);

SELECT AVG([Unemployment_Rate]) AS avg_unemployment FROM [dbo].[Economy_Productivity_SD_India];


CREATE PROCEDURE unemployment_data @Search_year smallint
AS
WITH cte (avg_unemployment) AS (SELECT AVG([Unemployment_Rate]) AS avg_unemployment FROM [dbo].[Economy_Productivity_SD_India])

SELECT e.City, SUM(CASE WHEN e.[Unemployment_Rate]<c.avg_unemployment THEN 1 ELSE 0 END) AS Total_unemployment 
FROM [dbo].Economy_Productivity_SD_India e CROSS JOIN cte c where e.Year=@Search_year GROUP BY e.City;

exec unemployment_data @Search_year=2023;