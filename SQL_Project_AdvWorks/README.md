# Adventure Works report
SQL querying and connection to a data warehouse in SQL Server to Power BI

The report uses the open-source data warehouse AdventureWork, downloaded from the following address https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2022.bak. This was uploaded to SQL Server, and here the needed VIEWS were created, in order to gather the necessary data for the following analysis.

Once, the data was ready (SQLQuery_to_BI.sql), a connection to Power BI through the local server of SQL server was created and the data was uploaded. No heavy transformations were necessary for the power query. Finally, the analysis of data was created through the calculation of measures and the creation of pages of the report.

### NOTE
In order to be able to reproduce the analysis from the Power BI file, first the SQL code should be run on the local SQL server and create a different connection with the local SQL server and PowerBI.


### SQL Server code examples

![AdvWorksSQL_SQLServer_example1](https://github.com/ElisabettaDeVitoFrancesco/PoewrBI_Projects/assets/26467328/e40489a8-4dc4-4b8a-9946-f1133e3fe77e)

![AdvWorksSQL_SQLServer_example2](https://github.com/ElisabettaDeVitoFrancesco/PoewrBI_Projects/assets/26467328/ae8efbca-7f1b-4b8b-a492-41881950e9d5)

### Power BI report

![AdvWorksSQL_Summary](https://github.com/ElisabettaDeVitoFrancesco/PoewrBI_Projects/assets/26467328/a3f67b8e-d4b1-431e-8840-e9f8af8a2f8f)

![AdvWorksSQL_Sales](https://github.com/ElisabettaDeVitoFrancesco/PoewrBI_Projects/assets/26467328/3d71ea1d-14f4-48f3-8db4-c062273b65f2)

![AdvWorksSQL_InternetSales](https://github.com/ElisabettaDeVitoFrancesco/PoewrBI_Projects/assets/26467328/e8a502ff-9295-43af-b469-d7be0ccc908f)

![AdvWorksSQL_Product](https://github.com/ElisabettaDeVitoFrancesco/PoewrBI_Projects/assets/26467328/c2ebd9b0-cf08-499a-a5ea-e3ca05792df8)

![AdvWorksSQL_CustomerDetials](https://github.com/ElisabettaDeVitoFrancesco/PoewrBI_Projects/assets/26467328/859f884e-20ff-4703-ae77-e65f31716b49)

![AdvWorksSQL_ResellerDetials](https://github.com/ElisabettaDeVitoFrancesco/PoewrBI_Projects/assets/26467328/87d73fe2-4670-4b9b-af6a-0fb9a96468fe)

![AdvWorksSQL_SalesPerson](https://github.com/ElisabettaDeVitoFrancesco/PoewrBI_Projects/assets/26467328/e683ff60-3c6a-4670-a1a8-adcb6f8e90ab)
