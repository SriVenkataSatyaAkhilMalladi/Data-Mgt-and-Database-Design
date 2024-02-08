/* 1.Write a query to retrieve all orders made after May 5, 2007 
   and had an total due value greater than $125,000. Include 
   the customer id, sales order id, order date and total due columns 
   in the returned data. 
 
   Use the CAST function in the SELECT clause to display the date 
   only for the order date. Use CAST to display the total due amount 
   as an integer. Use an alias to give a descriptive column heading  
   if a column heading is missing. Sort the returned data first by  
   the customer id, then order date. 
 
   Hint: (a) Use the Sales.SalesOrderHeader table. 
         (b) The syntax for CAST is CAST(expression AS data_type), 
             where expression is the column name we want to format and 
             we can use DATE and INT as the data_type for this question  
       to display a date and an integer.  
 */ 

Select SalesOrderID , CustomerID , cast(OrderDate as DATE) as OrderDate, cast(TotalDue as Integer) as Totaldue
from Sales.SalesOrderHeader 
WHERE TotalDue > 125000 AND OrderDate > CAST('2007-05-05' AS datetime) Order by CustomerID, OrderDate

/* 2.Write a query to retrieve the number of times a product has 
   been sold and the total sold quantity for each product.  
   Note it's the number of times a product has been contained  
   in an order and the total sold quantity of the product  
   for all orders. 
 
   Include only the products that have been sold more than  
   353 times. Use a column alias to make the report more  
   presentable. Sort the returned data by the number of times  
   a product has been sold in the descending order first, then  
   the product id in the ascending order.  
    
   Include the product ID, product name, number of times  
   a product has been sold, and total sold quantity columns  
   in the report. 
 
   Hint: Use the Sales.SalesOrderDetail and Production.Product tables. */ 
 
/* SELECT * FROM Sales.SalesOrderDetail;
 SELECT * FROM  Production.Product;
 */
 
SELECT p.ProductID , p.Name , COUNT(sod.ProductID) as NUM_TIMES_PROD_SOLD, SUM(sod.OrderQty) AS QUAN_OF_PROD_SOLD
FROM Sales.SalesOrderDetail sod
INNER JOIN Production.Product p
ON p.ProductID  = sod.ProductID
GROUP BY p.ProductID, p.Name
HAVING COUNT(sod.ProductID) > 353
ORDER BY NUM_TIMES_PROD_SOLD DESC, p.ProductID ASC ;

/* 3.Write a query to select the product id, name, and list price 
   of the product(s) that have a list price greater than the 
   the average list price of the products 911 and 915 plus 1000.  
   Display only the list price as an integer and make sure  
   all columns have a descriptive heading. Sort the returned data  
   by the list price in descending. 
 
   Hint: You’ll need to use a simple subquery to get the average  
         list price of the products 911 and 915 plus 1000. Then use  
   it in a WHERE clause. */ 

/*SELECT AVG(ListPrice) FROM  Production.Product WHERE ProductID IN (911,915);
*/

SELECT ProductID , Name , CAST(ListPrice AS INTEGER)  
FROM  Production.Product 
WHERE ListPrice > 1000+(SELECT AVG(ListPrice) FROM  Production.Product WHERE ProductID IN (911,915))
ORDER BY ListPrice DESC ;


/* 4.Write a query to generate a unique list of customers 
   who have made an order before but have not placed an order  
   after September 5, 2005. 
 
   Include the customer id, and the total purchase of the customer 
   in the returned data. Use TotalDue to calculate the total purchase. 
   Return the total purchase as an integer. Use an alias to make the 
   report look better. Sort the data by CustomerID in the descending  
   order. */ 

/* 
 * 
 * before but have not placed an order  
   after September 5, 2005. 
 * According to my understanding it should be not after that day
 * suggesting it could be on the day
 * that's the reason why I mentioned <= below leaving me with 40 rows
 * otherwise it would have been only 38 rows.
 * 
 */
SELECT DISTINCT CustomerID , CAST(SUM(TotalDue) AS INTEGER) AS TOTALPURCHASES
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (
  SELECT CustomerID
  FROM Sales.SalesOrderHeader
  WHERE OrderDate  <= '2005-09-05'
) 
AND CustomerID NOT IN (
  SELECT CustomerID
  FROM Sales.SalesOrderHeader
  WHERE OrderDate > '2005-09-05'
)
GROUP BY CustomerID
order by CustomerID DESC ;



/* 5.Write a query to return the total purchase of each customer.  
   Return only the customers who had more than 3 orders each with  
   a TotalDue amount greater than 100000. 
 
   Include the customer id, customer's last and first names, and total  
   purchase amount regardless of the order value for the qualified  
   customers in the returned data. 
 
   Format the total purchase amount as an integer. Sort the returned data 
   by the customer id. 
*/ 

/*
 * Below query is when I misunderstood the question 
 * pls Ignore
SELECT Customers_WITH_3_ORDERS_MORETHAN_100000.CustomerID, 
CUSTMER_NAMES.FirstName,
CUSTMER_NAMES.LastName,
Customers_WITH_3_ORDERS_MORETHAN_100000.TOTALDUE_FOR_CUSTOMER
FROM (SELECT  CustomerID , SUM(TotalDue) AS TOTALDUE_FOR_CUSTOMER
FROM Sales.SalesOrderHeader
WHERE CustomerID IN(SELECT  CustomerID FROM (select * from (
    select CustomerID, 
           TotalDue,
           row_number() over (partition by CustomerID order by TotalDue desc) as Customer_TotalDue_Rank 
    from Sales.SalesOrderHeader) ranks
where Customer_TotalDue_Rank <= 3) TOP_3_ORDERS_OF_Customers_WITH_MORETHAN_3_ORDERS
GROUP BY CustomerID
HAVING SUM(TotalDue) > 100000)
GROUP BY CustomerID) Customers_WITH_3_ORDERS_MORETHAN_100000 
INNER JOIN 
(SELECT C.CustomerID , P.FirstName , p.LastName  FROM Sales.Customer C INNER JOIN Person.Person P 
ON C.PersonID = P.BusinessEntityID) CUSTMER_NAMES
ON Customers_WITH_3_ORDERS_MORETHAN_100000.CustomerID  = CUSTMER_NAMES.CustomerID
 */


SELECT Customers_WITH_ATLEAST_3_ORDERS_MORETHAN_100000.CustomerID, 
CUSTMER_NAMES.FirstName,
CUSTMER_NAMES.LastName,
CAST(Customers_WITH_ATLEAST_3_ORDERS_MORETHAN_100000.TOTALDUE_FOR_CUSTOMER AS Integer) as Total_customer_purchase
FROM (SELECT  CustomerID, SUM(TotalDue) AS TOTALDUE_FOR_CUSTOMER FROM Sales.SalesOrderHeader
WHERE TotalDue > 100000
GROUP BY CustomerID
HAVING COUNT(CustomerID) >= 3) Customers_WITH_ATLEAST_3_ORDERS_MORETHAN_100000
INNER JOIN 
(SELECT C.CustomerID , P.FirstName , p.LastName  FROM Sales.Customer C INNER JOIN Person.Person P 
ON C.PersonID = P.BusinessEntityID) CUSTMER_NAMES
ON Customers_WITH_ATLEAST_3_ORDERS_MORETHAN_100000.CustomerID  = CUSTMER_NAMES.CustomerID





/* 6.Write a query to return the "total quantity sold" difference 
   between the sales of territory 1 and 2. Use the total of OrderQty 
   in SalesOrderDetail as the total quantity sold. 
*/ 

/*
 SELECT 
 SUM(CASE WHEN TerritoryID = 1 THEN OrderQty END) AS Territory1Sales,
 SUM(CASE WHEN TerritoryID = 2 THEN OrderQty END) AS Territory2Sales,
 (SUM(CASE WHEN TerritoryID = 1 THEN OrderQty END) -
 SUM(CASE WHEN TerritoryID = 2 THEN OrderQty END)) as Territory1_Leads_by
FROM Sales.SalesOrderDetail
JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
WHERE TerritoryID IN (1, 2);
*/


SELECT 
 (SUM(CASE WHEN TerritoryID = 1 THEN OrderQty END) -
 SUM(CASE WHEN TerritoryID = 2 THEN OrderQty END)) as Territory1_Leads_by
FROM Sales.SalesOrderDetail
JOIN Sales.SalesOrderHeader ON Sales.SalesOrderDetail.SalesOrderID = Sales.SalesOrderHeader.SalesOrderID
WHERE TerritoryID IN (1, 2);






