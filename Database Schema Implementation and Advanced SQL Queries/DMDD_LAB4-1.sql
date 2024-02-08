/*
 * 
 * PART - A
 * I'm not specifying NOT NULL since PRIMARY KEY suggests that it shouldn't be null.
 * 
 * 
CREATE DATABASE "AKHIL_DMDD";
Use AKHIL_DMDD;
CREATE TABLE Patient (
  PatientID INT PRIMARY KEY,
  LastName VARCHAR(50),
  FirstName VARCHAR(50),
  DateOfBirth DATE
);

CREATE TABLE Test (
  TestID INT PRIMARY KEY,
  Name VARCHAR(50),
  Description VARCHAR(255)
);

CREATE TABLE Result (
  PatientID INT,
  TestID INT,
  Date DATE,
  PRIMARY KEY (PatientID, TestID, Date),
  FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
  FOREIGN KEY (TestID) REFERENCES Test(TestID)
);



*/

/***************************************************************************************************************************/

-- PART - B.1

WITH CTE AS (
    SELECT
        sod.SalesOrderID,
        sod.ProductID,
        sod.OrderQty,
        DENSE_RANK() OVER (PARTITION BY sod.SalesOrderID ORDER BY sod.OrderQty DESC) AS RANK_NUM
    FROM 
        Sales.SalesOrderDetail sod
)
SELECT DISTINCT
     CTE.SalesOrderID, 
    STUFF((
        SELECT TOP 3 WITH TIES 
            ', ' + CAST(CTE2.ProductID AS VARCHAR(10))
        FROM 
            CTE CTE2
        WHERE 
            CTE2.SalesOrderID = CTE.SalesOrderID
        ORDER BY 
            CTE2.OrderQty DESC
        FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS Products
FROM 
    CTE
ORDER BY 
    CTE.SalesOrderID;
   
   
/********************************************************************************************************************************/

-- PART - B.2

   
USE AdventureWorks2008R2;

WITH SalesData AS (
    SELECT 
        soh.SalesPersonID, 
        MAX(soh.TotalDue) AS HighestOrderValueInt,
        SUM(soh.TotalDue) AS TotalSalesAmountInt
    FROM Sales.SalesOrderHeader AS soh
    WHERE soh.SalesPersonID IS NOT NULL
    GROUP BY soh.SalesPersonID
    HAVING SUM(soh.TotalDue) > 10000000
)
SELECT 
    SalesPersonID, 
    CAST(HighestOrderValueInt AS INTEGER) AS HighestOrderValue,
    CAST(TotalSalesAmountInt AS INTEGER) AS TotalSalesAmount,
    STUFF((SELECT TOP 3 WITH TIES ', ' + CAST(soh.SalesOrderID AS VARCHAR(10))
           FROM Sales.SalesOrderHeader AS soh
           JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
           WHERE soh.SalesPersonID = sd.SalesPersonID
           GROUP BY soh.SalesOrderID, soh.TotalDue
           ORDER BY SUM(sod.OrderQty) DESC, soh.TotalDue DESC
           FOR XML PATH('')), 1, 2, '') AS Orders
FROM SalesData AS sd
ORDER BY SalesPersonID;
   

/*****************************************************************************************************************************/   
   
/*
 * 
 * PART - C
 * PLEASE RUN THE IF STATEMENT FIRST FOLLOWED BY REST EVERY TIME YOU RUN IT, THANKS
 */
IF EXISTS (SELECT * from #TempTable)
DROP TABLE #TempTable;

WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel) AS
(
 SELECT b.ProductAssemblyID, b.ComponentID, b.PerAssemblyQty,
 b.EndDate, 0 AS ComponentLevel
 FROM Production.BillOfMaterials AS b
 WHERE b.ProductAssemblyID = 992 AND b.EndDate IS NULL
 UNION ALL
 SELECT bom.ProductAssemblyID, bom.ComponentID, p.PerAssemblyQty,
 bom.EndDate, ComponentLevel + 1
 FROM Production.BillOfMaterials AS bom
 INNER JOIN Parts AS p
 ON bom.ProductAssemblyID = p.ComponentID AND bom.EndDate IS NULL
)
SELECT AssemblyID, ComponentID, ListPrice, PerAssemblyQty, ComponentLevel
INTO #TempTable 
FROM Parts AS p
    INNER JOIN Production.Product AS pr
    ON p.ComponentID = pr.ProductID
ORDER BY ComponentLevel, AssemblyID, ComponentID;

SELECT CAST((
(SELECT SUM(ListPrice)
FROM #TempTable
WHERE ComponentLevel = 0  AND  ComponentID IN (808,949))
-
(SELECT SUM(ListPrice)
FROM #TempTable
WHERE ComponentLevel = 1 and AssemblyID IN (808,949) )) AS DECIMAL(8,4)) AS TotalCost;














