# SQL Server Data Exploration of covid19
The covid19 data was explored and analysed:
- total cases, deaths, tests and vaccinations were analysed over time, and across countries and continents.
- infection and death rates over population were calculated and analysed over time, and across countries and continents.
- infection rate over number of tests were calculated and analysed over time, and across countries and continents.
- death rate over number of infections were calculated and analysed over time, and across countries and continents.

The open data of covid19 collected during the years was downloaded from Our World in Data.

Two tables were created using excel, containing daily data of infection cases, number deaths for each country and daily number of vaccinations and tests performed per each coutnry.

## SQL script
These were imported into SQL Server and explored using SQL.

To perform this the following main commands were used:
- DML SELECT
- DML JOIN
- Common Table Expression CTE
- Window function
- DDL CREATE TABLE
- DDL CREATE VIEW
  - Views created to connect to Power BI


## Power BI
The data was imported through a SQL Server connection as Direct queries.

Power BI was mainly used as a data visualisation tool.

After a summary of the data, total, running totals and rates data over time and locations were displayed.
