USE AdventureWorksDW2022;

-- SELECT DISTINCT(JobTitle) FROM HumanResources.Employee;
-- European Sales Manager
-- Pacific Sales Manager

SELECT * FROM DimCurrency; -- CurrencyKey CurrencyName

SELECT * FROM DimCustomer; -- CustomerKey CustomerAlternateKey GeographyKey CONCAT(FirtsName, ' ', MiddleName, ' ', 'LastName) BirthDate
-- Gender YearlyIncome NumberChildrenAtHome EnglishEducation EnglishOccupation HouseOwnerFlag

SELECT * FROM DimDate; -- DateKey FullDateAlternate DayNumberOfWeek EnglishDayNameOfWeek DayNumberOfMonth DayNumberOfYear
-- EnglishMonthName MonthNumberOfYear CalendarQuarter CalendarYear FiscalQuarter FiscalYear

SELECT * FROM DimEmployee; -- EmployeeKey CONCAT(FirstName, ' ', MiddleName, ' ', LastName) AS SalesPerson
-- Title SalesTerritoryKey Gender

SELECT * FROM DimGeography; -- GeographyKey City StateProvinceName EnglishCountryRegionName PostalCode SalesTerritoryKey
-- IpAddressLocator

SELECT * FROM DimProduct; -- ProductKey ProductSubcategoryKey EnglishProductName StandardCost FinishedGoodFlag Color
-- ListPrice Size Weight

SELECT * FROM DimProductCategory; -- ProductCategoryKey EnglishProductCategoryName

SELECT * FROM DimProductSubcategory; -- ProductSubcategoryKey EnglishProductSubcategoryName ProductCategoryKey

SELECT * FROM DimReseller; -- ResellerKey GeographyKey BusinessType ResellerName NumberEmployees ProductLine AnnualSales AnnualRevenue
SELECT BusinessType, COUNT(BusinessType) FROM DimReseller
GROUP BY BusinessType;

SELECT * FROM DimSalesReason; -- SalesReasonKey SalesReasonName SalesReasonReasonType

SELECT * FROM DimSalesTerritory; -- SalesTerritoryKey SalesTerritoryCountry SalesTerritoryGroup

SELECT * FROM FactCurrencyRate; -- CurrencyKey DateKey AverageRate

SELECT * FROM FactCallCenter; -- FactCallCenterID DateKey Orders

SELECT * FROM FactInternetSales; -- ProductKey OrderDateKey DueDateKey CustomerKey CurrencyKey SalesTerritoryKey
-- SalesOrderNumber SalesOrderLineNumber OrderQuantity UnitPrice ExtendedAmount TotalProductCost SalesAmount TaxAmt Freight OrderDate DueDate

SELECT * FROM FactInternetSalesReason; -- SalesOrderNumber SalesReasonKey

SELECT * FROM FactResellerSales; -- ProductKey OrderDateKey DueDateKey ResellerKey EmployeeKey CurrencyKey CustomerPONumber
-- SalesTerritoryKey SalesOrderNumber SalesOrderLineNumber OrderQuantity UnitPrice ExtendedAmount TotalProductCost SalesAmount TaxAmt Freight
-- OrderDate DueDate CustomerPONmber

SELECT * FROM FactSalesQuota; -- SalesQuotaKey EmployeeKey DateKey CalendarYear SalesAmountQuota

SELECT * FROM FactSurveyResponse;

SELECT * FROM FactProductInventory;

SELECT * FROM DimSalesReason;

SELECT * FROM ProspectiveBuyer;

----------------------------
-- Sales Person
----------------------------

DROP VIEW IF EXISTS dbo.SalesPerson;

CREATE VIEW SalesPerson AS(
	SELECT
		e.EmployeeKey
		, CONCAT(e.FirstName, ' ', e.MiddleName, ' ', e.LastName) AS SalesPerson
		, e.Title
		, e.SalesTerritoryKey
		, e.Gender
	FROM DimEmployee AS e
	WHERE e.SalesPersonFlag = 1);


SELECT * FROM SalesPerson;

----------------------------
-- Product
----------------------------
-- DimProduct: ProductKey ProductSubcategoryKey EnglishProductName StandardCost FinishedGoodFlag Color ListPrice Size
--             Weight ProductLine?
-- DimProductCategory: ProductCategoryKey EnglishProductCategoryName
-- DimProductSubcategory: ProductSubcategoryKey EnglishProductSubcategoryName ProductCategoryKey
DROP VIEW IF EXISTS Product;

CREATE VIEW Product AS(
SELECT
	p.ProductKey
	, p.EnglishProductName													AS ProductName
	, pc.ProductCategoryKey
	, ISNULL(pc.EnglishProductCategoryName, 'No Subcategory Name')			AS CategoryName
	, psc.ProductSubcategoryKey
	, ISNULL(psc.EnglishProductSubcategoryName, 'No Category Name')			AS SubCategoryName
	, p.ProductLine
	, p.StandardCost
	, p.ListPrice
	, p.Color
	, p.Size
	, p.Weight
FROM DimProduct					AS p
LEFT JOIN DimProductSubcategory AS psc
	ON p.ProductSubcategoryKey = psc.ProductSubcategoryKey
LEFT JOIN DimProductCategory	AS pc
	ON psc.ProductCategoryKey = pc.ProductCategoryKey
WHERE p.FinishedGoodsFlag = 1 );

SELECT * FROM Product;

---------------------------
-- Reseller
---------------------------
-- DimReseller: ResellerKey GeographyKey ResellerName NumberEmployees ProductLine AnnualSales AnnualRevenue
-- DimGeography: GeographyKey City StateProvinceName EnglishCountryRegionName PostalCode SalesTerritoryKey IpAddressLocator

DROP VIEW IF EXISTS Reseller;

CREATE VIEW Reseller AS(
	SELECT
		r.ResellerKey
		, r.GeographyKey
		, r.BusinessType
		, r.NumberEmployees
		, r.ProductLine
		, r.AnnualSales
		, r.AnnualRevenue
		, g.City						AS City
		, g.StateProvinceName			AS Province
		, g.EnglishCountryRegionName	AS Country
		, g.PostalCode
		, g.SalesTerritoryKey
		, g.IpAddressLocator
	FROM DimReseller					AS r
	LEFT JOIN DimGeography				AS g
		ON r.GeographyKey = g.GeographyKey);

SELECT COUNT(ResellerKey) FROM Reseller; -- 701

-----------------------
-- Customer
-----------------------
-- DimCustomer: CustomerKey GeographyKey CONCAT(FirtsName, ' ', MiddleName, ' ', 'LastName) BirthDate
--              Gender YearlyIncome NumberChildrenAtHome EnglishEducation EnglishOccupation HouseOwnerFlag
SELECT * FROM DimCustomer;
SELECT EnglishEducation, COUNT(EnglishEducation) AS 'Count' 
FROM DimCustomer
GROUP BY EnglishEducation;

DROP VIEW IF EXISTS Customer;

CREATE VIEW Customer AS (
	SELECT
		CustomerKey
		, GeographyKey
		, CONCAT(FirstName, ' ', MiddleName, ' ', LastName)	AS CustomerName
		, BirthDate
		, DATEDIFF(YEAR, BirthDate, GETDATE()) AS CustomerAge
		, Gender
		, YearlyIncome
		, CASE
			WHEN YearlyIncome < 50000 THEN 'Low'
			WHEN YearlyIncome >= 50000 AND YearlyIncome < 150000 THEN 'Medium'
			WHEN YearlyIncome >= 150000 THEN 'High'
		END IncomeGroup
		, NumberChildrenAtHome
		, EnglishEducation									AS Education
		, CASE
			WHEN EnglishEducation = 'High School' OR EnglishEducation = 'Partial High School' OR EnglishEducation = 'Partial College' THEN 'Base'
			WHEN EnglishEducation = 'Graduate Degree' OR EnglishEducation = 'Bachelors' THEN 'High'
		END EducationGroup
		, EnglishOccupation									AS Occupation
		, HouseOwnerFlag
	FROM DimCustomer);

SELECT * FROM Customer;
SELECT COUNT(CustomerKey) FROM Customer; -- 18484 counts

-----------------------
-- Customer + Reseller test
-----------------------
DROP VIEW IF EXISTS CustomerReseller;

CREATE VIEW CustomerReseller AS (
	SELECT
		c.CustomerKey
		, c.GeographyKey
		, CONCAT(c.FirstName, ' ', c.MiddleName, ' ', c.LastName)	AS CustomerName
		, c.BirthDate
		, c.Gender
		, c.YearlyIncome
		, c.NumberChildrenAtHome
		, c.EnglishEducation										AS Education
		, c.EnglishOccupation										AS Occupation
		, c.HouseOwnerFlag
		, r.ResellerKey
	FROM DimCustomer												AS c
	LEFT JOIN Reseller												AS r
		ON c.GeographyKey = r.GeographyKey);

SELECT * FROM CustomerReseller;

------------------------
-- Region
------------------------
-- DimSalesTerritory: SalesTerritoryKey SalesTerritoryCountry SalesTerritoryGroup

CREATE VIEW Region AS (
	SELECT
		SalesTerritoryKey
		, SalesTerritoryCountry		AS SalesCountry
		, SalesTerritoryGroup		AS SalesGroup
		, SalesTerritoryRegion		AS SalesRegion
	FROM DimSalesTerritory
	WHERE SalesTerritoryKey <> 11
);

SELECT * FROM Region;

------------------------
-- Sales
------------------------
-- FactInternetSales: ProductKey OrderDateKey DueDateKey CustomerKey CurrencyKey SalesTerritoryKey
--                    SalesOrderNumber OrderQuantity UnitPrice ExtendedAmount TotalProductCost SalesAmount TaxAmt
--                    Freight OrderDate DueDate
-- FactInternetSalesReason: SalesOrderNumber SalesReasonKey
-- DimSalesReason: SalesReasonKey SalesReasonName SalesReasonReasonType
-- FactResellerSales: ProductKey OrderDateKey DueDateKey ResellerKey EmployeeKey CustomerPONumber CurrencyKey
--                    SalesTerritoryKey SalesOrderNumber OrderQuantity UnitPrice ExtendedAmount TotalProductCost
--                    SalesAmount TaxAmt Freight OrderDate DueDate

DROP VIEW IF EXISTS Sales;

CREATE VIEW Sales AS(
	SELECT
		'1'																								AS SalesFlag
		, CONCAT('1', '-', RIGHT(rs.SalesOrderNumber, 5), '-', RIGHT(CONCAT('00', rs.SalesOrderLineNumber), 3)) AS SalesKey
		, rs.ProductKey
		, rs.ResellerKey
		, rs.EmployeeKey
		, null																					AS CustomerKey
		, r.BusinessType
		, rs.SalesTerritoryKey
		, rs.SalesOrderNumber
		, rs.SalesOrderLineNumber
		, rs.OrderQuantity
		, rs.UnitPrice
		, rs.ExtendedAmount
		, rs.SalesAmount
		, rs.TotalProductCost
		, rs.SalesAmount - rs.TotalProductCost													AS Profit
		, rs.OrderDateKey
		, rs.DueDateKey
		, rs.OrderDate
		, rs.DueDate
	FROM DimProduct																				AS p
	LEFT JOIN FactResellerSales																	AS rs
		ON p.ProductKey = rs.ProductKey
	LEFT JOIN DimReseller																		AS r
		ON rs.ResellerKey = r.ResellerKey
	
	UNION ALL

	SELECT
		'2'																								  AS SalesFlag
		, CONCAT('2', '-', RIGHT(fis.SalesOrderNumber, 5), '-', RIGHT(CONCAT('00', fis.SalesOrderLineNumber), 3)) AS SalesKey
		, fis.ProductKey
		, null
		, null
		, fis.CustomerKey
		, 'Internet'
		, fis.SalesTerritoryKey
		, fis.SalesOrderNumber
		, fis.SalesOrderLineNumber
		, fis.OrderQuantity
		, fis.UnitPrice
		, fis.ExtendedAmount
		, fis.SalesAmount
		, fis.TotalProductCost
		, fis.SalesAmount - fis.TotalProductCost													AS Profit
		, fis.OrderDateKey
		, fis.DueDateKey
		, fis.OrderDate
		, fis.DueDate
	FROM FactInternetSales																				AS fis
);

SELECT * FROM Sales;

-----------------------
-- Date
-----------------------
-- DimDate: DateKey FullDateAlternate DayNumberOfWeek EnglishDayNameOfWeek DayNumberOfMonth DayNumberOfYear
-- EnglishMonthName MonthNumberOfYear CalendarQuarter CalendarYear FiscalQuarter FiscalYear
CREATE VIEW SalesDate AS (
	SELECT
		DateKey
		, FullDateAlternateKey
		, DayNumberOfWeek
		, EnglishDayNameOfWeek			AS DayNameOfWeek
		, DayNumberOfMonth
		, DayNumberOfYear
		, EnglishMonthName				AS NameOfMonth
		, MonthNumberOfYear
		, CalendarQuarter
		, CalendarYear
		, FiscalQuarter
		, FiscalYear
	FROM DimDate
);