# SQL Projects

## SQL Server Data Exploration of covid19
The open data of covdi19 collected during the years was downloaded from Our World in Data. Due to the large size of the file it can't be stored here, hence please follow this link to download the data https://ourworldindata.org/covid-deaths, from the chart named "Daily new confirmed COVID-19 deaths per million people".

Two tables were created using excel, containing location, continent, datew, daily data of infection cases, number deaths for each country and daily number of vaccinations and tests performed per each coutnry.

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
