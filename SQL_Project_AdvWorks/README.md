# Adventure Works report
SQL querying and connection to a data warehouse in SQL Server to Power BI

The report uses the open-source data warehouse AdventureWork, downloaded from the following address https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2022.bak. This was uploaded to SQL Server, and here the needed VIEWS were created, in order to gather the necessary data for the following analysis.

Once, the data was ready (SQLQuery_to_BI.sql), a connection to Power BI through the local server of SQL server was created and the data was uploaded. No heavy transformations were necessary for the power query. Finally, the analysis of data was created through the calculation of measures and the creation of pages of the report.
### NOTE
In order to be able to reproduce the analysis from the Power BI file, first the SQL code should be run on the local SQL server and create a different connection with the local SQL server and PowerBI.
