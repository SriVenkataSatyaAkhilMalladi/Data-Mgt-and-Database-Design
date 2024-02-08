

 
/* 3-1 
 * Modify the following query to add a column that identifies the 
   performance of salespersons and contains the following feedback 
   based on the number of orders processed by a salesperson: 
 
     'Do more!' for the order count range 1-120 
     'Fine!' for the order count range of 121-320 
     'Excellent!' for the order count greater than 320 
 
   Give the new column an alias to make the report more readable.  
*/ 
 
SELECT SalesPersonID, p.LastName, p.FirstName, 
       COUNT(o.SalesOrderid)  [Total Orders],
       CASE
       WHEN COUNT(o.SalesOrderid) >= 1 and COUNT(o.SalesOrderid) <= 120 THEN 'Do more!'
       WHEN COUNT(o.SalesOrderid)  > 120 and  COUNT(o.SalesOrderid) <= 320 THEN 'Fine!'
       ELSE 'Excellent!'
       END as Performance_Review
FROM Sales.SalesOrderHeader o 
JOIN Person.Person p 
   ON o.SalesPersonID = p.BusinessEntityID 
GROUP BY o.SalesPersonID, p.LastName, p.FirstName 
ORDER BY p.LastName, p.FirstName; 




 
/* 3-2 
 * Modify the following query to add a new column named rank. 
   The new column is based on ranking with gaps according to 
   the total orders in descending. Also partition by the territory.*/ 
 
SELECT o.TerritoryID, s.Name, o.SalesPersonID, 
COUNT(o.SalesOrderid) [Total Orders] ,
RANK() OVER (PARTITION BY o.TerritoryID ORDER BY COUNT(o.SalesOrderid) DESC) AS rank
FROM Sales.SalesOrderHeader o 
JOIN Sales.SalesTerritory s 
   ON o.TerritoryID = s.TerritoryID 
WHERE SalesPersonID IS NOT NULL 
GROUP BY o.TerritoryID, s.Name, o.SalesPersonID 
ORDER BY o.TerritoryID; 


 
/* 3-3 
 * Write a query to return the sales territory which had 
   the lowest total sales amount. Include only the sales territories 
   which never had an order worth more than $120000 for this query. 
   If there is a tie, the tie needs to be returned. 
  
   Include the territory id, territory name, highest order value, 
   and total sales amount for the territory in the returned data.  
   Use TotalDue of SalesOrderHeader as the order value. Format  
   the total sales as an integer. 
*/ 
SELECT SO.TerritoryID, ST.Name AS Territory_Name , SO.HIGHEST_ORDER_VALUE , SO.TOTAL_SALES_AMOUNT
FROM Sales.SalesTerritory ST
JOIN 
(SELECT  TOP 1 WITH TIES TerritoryID , MAX(TotalDue) AS HIGHEST_ORDER_VALUE, CAST(SUM(TotalDue) AS INTEGER) AS TOTAL_SALES_AMOUNT FROM Sales.SalesOrderHeader SO
GROUP BY SO.TerritoryID 
HAVING MAX(SO.TotalDue) <= 120000
ORDER BY SUM(SO.TotalDue) ASC) SO
ON ST.TerritoryID = SO.TerritoryID;

/* 3-4
 * Write a query to retrieve the top 3 salespersons who have also  
   sold products that were shipped to more than 10 states/provinces.  
   Exclude orders which don't have a salesperson specified for this  
   query. 
 
   Use TotalDue in SalesOrderHeader for calculating the total sales. 
   The top 3 salespersons have the 3 highest total sales amounts. 
   Use ShipToAddressID in SalesOrderHeader to determine what  
   state/province a product was shipped to. If there is a tie,  
   your solution must retrieve it. 
 
   Include SalespersonID, Salesperson's lastname and firstname, 
   total sales amount, and the number of unique states/provinces 
   the salesperson's sold products were shipped to in the returned  
   data. Sort the returned data by SalespersonID. */ 

SELECT SO.SalesPersonID , P.FirstName , P.LastName , SO.DISTINCT_PROVINCES_SHIPPED_TO_BY_SALESPERSON , SO.TOTAL_SALES_FOR_SALES_PERSON FROM Person.Person P 
INNER JOIN (SELECT TOP 3 WITH TIES SOH.SalesPersonID, SUM(SOH.TotalDue) AS TOTAL_SALES_FOR_SALES_PERSON, COUNT(DISTINCT ADDR.StateProvinceID) AS DISTINCT_PROVINCES_SHIPPED_TO_BY_SALESPERSON
FROM Sales.SalesOrderHeader SOH
INNER JOIN Person.Address ADDR
ON SOH.ShipToAddressID = ADDR.AddressID
WHERE SOH.SalesPersonID IS NOT NULL
GROUP BY SOH.SalesPersonID
HAVING COUNT(DISTINCT ADDR.StateProvinceID) > 10
ORDER BY SUM(SOH.TotalDue) DESC) SO
ON P.BusinessEntityID = SO.SalesPersonID
ORDER BY SO.SalesPersonID;


SELECT * FROM SALES.SalesPerson sp ;
SELECT * FROM Sales.SalesOrderHeadeR;

/* 3-5
 * Write a query to retrieve the product color which had 
   the largest total-quantity-sold increase from 
   October 2006 to November 2006. 
    
   Include the color and increase columns in the returned data. 
   If there is a tie, it must be picked up. 
   SELECT DISTINCT OrderDate  FROM SALES.SalesOrderHeader soh 

SELECT  PSOD.Color , SO.OrderDate, SUM(PSOD.OrderQty)  FROM 
(SELECT SOD.OrderQty , SOD.SalesOrderID , P.Color , P.ProductID FROM  Sales.SalesOrderDetail SOD
Inner join Production.Product P
ON SOD.ProductID = P.ProductID
WHERE P.Color IS NOT NULL) PSOD
INNER JOIN 
Sales.SalesOrderHeader SO
ON
PSOD.SalesOrderID = SO.SalesOrderID 
WHERE SO.OrderDate  IN ('2006-10-01','2006-11-01')
GROUP BY PSOD.Color , SO.OrderDate;
*/ 



SELECT TOP 1 WITH TIES 
    SOZ.Color , SUM(CASE WHEN MONTH(SOZ.OrderDate) = '11' THEN SOZ.ORDERED_QTY ELSE 0 END)
    - SUM(CASE WHEN MONTH(SOZ.OrderDate) = '10' THEN SOZ.ORDERED_QTY ELSE 0 END) as MAXIMUM_INCREASE
FROM (SELECT  PSOD.Color , SO.OrderDate, SUM(PSOD.OrderQty) AS ORDERED_QTY FROM 
(SELECT SOD.OrderQty , SOD.SalesOrderID , P.Color , P.ProductID FROM  Sales.SalesOrderDetail SOD
Inner join Production.Product P
ON SOD.ProductID = P.ProductID
WHERE P.Color IS NOT NULL) PSOD
INNER JOIN 
Sales.SalesOrderHeader SO
ON
PSOD.SalesOrderID = SO.SalesOrderID 
WHERE SO.OrderDate  Between '2006-10-01' AND '2006-11-30'
GROUP BY PSOD.Color , SO.OrderDate) SOZ
GROUP BY SOZ.Color
ORDER BY MAXIMUM_INCREASE DESC;

