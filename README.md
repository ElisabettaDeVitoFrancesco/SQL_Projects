# SQL Projects

### SQL Server Data Exploration of covid19

#### Scope
The covid19 data was explored and analysed:
- total cases, deaths, tests and vaccinations were analysed over time, and across countries and continents.
- infection and death rates over population were calculated and analysed over time, and across countries and continents.
- infection rate over number of tests were calculated and analysed over time, and across countries and continents.
- death rate over number of infections were calculated and analysed over time, and across countries and continents.

#### Procedure
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


#### Power BI
The data was imported through a SQL Server connection as Direct queries.

Power BI was mainly used as a data visualisation tool.

After a summary of the data, total, running totals and rates data over time and locations were displayed.


### Adventure Works report

SQL querying and connection to a data warehouse in SQL Server to Power BI

The report uses the open-source data warehouse AdventureWork, downloaded from the following address https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2022.bak. This was uploaded to SQL Server, and here the needed VIEWS were created, in order to gather the necessary data for the following analysis.

Once, the data was ready (SQLQuery_to_BI.sql), a connection to Power BI through the local server of SQL server was created and the data was uploaded. No heavy transformations were necessary for the power query. Finally, the analysis of data was created through the calculation of measures and the creation of pages of the report.

#### NOTE
In order to be able to reproduce the analysis from the Power BI file, first the SQL code should be run on the local SQL server and create a different connection with the local SQL server and PowerBI.
