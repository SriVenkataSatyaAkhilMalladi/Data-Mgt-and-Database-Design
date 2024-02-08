CREATE DATABASE AKHIL_DMDD_TEST;
USE AKHIL_DMDD_TEST;

--Lab 5.1
/*
DROP FUNCTION dbo.totalsalesyearmonth;
CREATE FUNCTION dbo.totalsalesyearmonth
(@y INT, @m INT, @c VARCHAR(50))
RETURNS FLOAT
AS
BEGIN
	DECLARE @totalsum FLOAT;
	IF EXISTS (SELECT DISTINCT TotalDue
		FROM AdventureWorks2008R2.sales.salesOrderHeader soh
        JOIN AdventureWorks2008R2.Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
        JOIN AdventureWorks2008R2.Production.Product p ON sod.ProductID = p.ProductID
		WHERE YEAR(OrderDate) = @y AND MONTH(OrderDate) = @m AND p.Color = @c)
	SELECT @totalsum = sum(DISTINCT TotalDue)
		FROM AdventureWorks2008R2.sales.salesOrderHeader soh
        JOIN AdventureWorks2008R2.Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
        JOIN AdventureWorks2008R2.Production.Product p ON sod.ProductID = p.ProductID
		WHERE YEAR(OrderDate) = @y AND MONTH(OrderDate) = @m AND p.Color = @c;
	ELSE
		BEGIN
			SET @totalsum = 0;
		END
	RETURN @totalsum;
END;
SELECT dbo.totalsalesyearmonth(2007,12,'Blue'); 
SELECT dbo.totalsalesyearmonth(2006,10,'Blue'); 
SELECT DISTINCT soh.TotalDue, p.Color, soh.OrderDate
		FROM AdventureWorks2008R2.sales.salesOrderHeader soh
        JOIN AdventureWorks2008R2.Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
        JOIN AdventureWorks2008R2.Production.Product p ON sod.ProductID = p.ProductID
		WHERE YEAR(OrderDate) = 2006 AND MONTH(OrderDate) = 10 AND p.Color = 'Black'

*/		
		
		

DROP FUNCTION dbo.GetTotalSalesByColor;
CREATE FUNCTION dbo.GetTotalSalesByColor (
    @Year INT,
    @Month INT,
    @Color VARCHAR(50)
)
RETURNS FLOAT
AS
BEGIN
    DECLARE @TotalSales FLOAT

    SELECT @TotalSales = SUM(UnitPrice * OrderQty)
    FROM AdventureWorks2008R2.Sales.SalesOrderHeader AS soh
    JOIN AdventureWorks2008R2.Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN AdventureWorks2008R2.Production.Product AS p ON sod.ProductID = p.ProductID
    WHERE YEAR(soh.OrderDate) = @Year
    AND MONTH(soh.OrderDate) = @Month
    AND p.Color = @Color

    IF @TotalSales IS NULL
        SET @TotalSales = 0

    RETURN @TotalSales
END


SELECT dbo.GetTotalSalesByColor(2007,12,'Blue'); 
SELECT dbo.GetTotalSalesByColor(2006,10,'Blue');

SELECT * FROM  AdventureWorks2008R2.Sales.SalesOrderHeader AS soh
    JOIN AdventureWorks2008R2.Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN AdventureWorks2008R2.Production.Product AS p ON sod.ProductID = p.ProductID
    WHERE YEAR(soh.OrderDate) = 2006
    AND MONTH(soh.OrderDate) = 10 AND p.Color = 'Blue'	;	

/**************************************************************************************************************************/

--Lab 5.2

SELECT C.CustomerID , P.FirstName , p.LastName FROM AdventureWorks2008R2.Sales.Customer C INNER JOIN
AdventureWorks2008R2.Person.Person P
ON C.PersonID = P.BusinessEntityID

DROP FUNCTION dbo.CustomerName;
CREATE FUNCTION dbo.CustomerName
(@ID INT)
RETURNS VARCHAR(50)
AS
BEGIN
	DECLARE @FullName VARCHAR(50);
	IF EXISTS (SELECT C.CustomerID  FROM AdventureWorks2008R2.Sales.Customer C INNER JOIN
               AdventureWorks2008R2.Person.Person P
               ON C.PersonID = P.BusinessEntityID
               WHERE C.CustomerID = @ID)
	SELECT @FullName = CONCAT(P.FirstName+' ', p.LastName  )
	FROM AdventureWorks2008R2.Sales.Customer C INNER JOIN
    AdventureWorks2008R2.Person.Person P
    ON C.PersonID = P.BusinessEntityID
    WHERE C.CustomerID = @ID;
	ELSE
		BEGIN
			SET @FullName = NULL;
		END
	RETURN @FullName;
END;

SELECT dbo.CustomerName(21139);


/***********************************************************************************************************************/

--Lab 5.3

DROP TABLE SaleOrderDetail;
DROP TABLE SaleOrder;
DROP TABLE Customer;


CREATE TABLE Customer
(CustomerID INT PRIMARY KEY,
CustomerLName VARCHAR(30),
CustomerFName VARCHAR(30));

CREATE TABLE SaleOrder
(OrderID INT IDENTITY PRIMARY KEY,
CustomerID INT REFERENCES Customer(CustomerID),
OrderDate DATE,
LastModified datetime);

CREATE TABLE SaleOrderDetail
(OrderID INT REFERENCES SaleOrder(OrderID),
ProductID INT,
Quantity INT,
UnitPrice INT,
PRIMARY KEY (OrderID, ProductID));

CREATE TRIGGER UpdateSaleOrderLastModified
ON SaleOrderDetail
AFTER UPDATE,INSERT,DELETE
AS
BEGIN
    UPDATE SaleOrder
    SET LastModified = GETDATE()
    FROM SaleOrder INNER JOIN inserted ON SaleOrder.OrderID = inserted.OrderID
END;

/*
 Write a trigger to put the change date and time in the LastModified column
of the Order table whenever an order item in SaleOrderDetail is changed. 
	
INSERT INTO Customer (CustomerID, CustomerLName, CustomerFName)
VALUES
(1, 'Smith', 'John'),
(2, 'Doe', 'Jane'),
(3, 'Johnson', 'Robert'),
(4, 'Garcia', 'Maria'),
(5, 'Kim', 'David');

SELECT * FROM Customer;

INSERT INTO SaleOrder (CustomerID, OrderDate, LastModified)
VALUES
(1, '2022-01-01', '2022-01-01 10:30:00'),
(2, '2022-01-02', '2022-01-02 12:45:00'),
(3, '2022-01-03', '2022-01-03 14:20:00'),
(4, '2022-01-04', '2022-01-04 16:55:00'),
(5, '2022-01-05', '2022-01-05 18:10:00');

SELECT * FROM SaleOrder;

INSERT INTO SaleOrderDetail (OrderID, ProductID, Quantity, UnitPrice)
VALUES
(2, 103, 2, 30),
(3, 102, 1, 20),
(3, 103, 3, 30);

SELECT * FROM SaleOrderDetail;

UPDATE SaleOrderDetail
SET Quantity = 4, UnitPrice = 15
WHERE OrderID = 3 AND ProductID = 102;
*/

/*****************************************************************************************************************************/
--Lab 5.4

DROP TABLE BonusAudit;
DROP TABLE Bonus;
DROP TABLE Employee;


create table Employee
(EmployeeID int primary key,
EmpLastName varchar(50),
EmpFirstName varchar(50),
DepartmentID smallint);
create table Bonus
(BonusID int identity primary key,
BonusAmount int,
BonusDate date NOT NULL,
EmployeeID int NOT NULL);
create table BonusAudit -- Audit Table
(AuditID int identity primary key,
EnteredBy varchar(50) default original_login(),
EnterTime datetime default getdate(),
EnteredAmount int not null);


CREATE TRIGGER tr_BonusLimit
ON Bonus
AFTER INSERT, UPDATE AS
BEGIN
  DECLARE @EmployeeID int, @BonusAmount int, @BonusDate date, @BonusYear int, @BonusTotal int;

  -- Get the values of the inserted row
  SELECT @EmployeeID = EmployeeID, @BonusAmount = BonusAmount, @BonusDate = BonusDate
  FROM inserted;

  -- Get the year of the bonus date
  SELECT @BonusYear = YEAR(@BonusDate);

  -- Get the total bonus amount for the employee in the current year
  SELECT @BonusTotal = SUM(BonusAmount)
  FROM Bonus
  WHERE EmployeeID = @EmployeeID AND YEAR(BonusDate) = @BonusYear;

  -- If the total exceeds $100,000, log the attempt and prevent the bonus from being inserted
	IF (@BonusTotal + @BonusAmount) > 100000
	BEGIN 
	    ROLLBACK TRANSACTION;
	    RAISERROR('Bonus amount exceeds yearly limit for employee %d', 16, 1, @EmployeeID);
	    INSERT INTO BonusAudit (EnteredAmount)
	    VALUES (@BonusAmount); 
	END


END



INSERT INTO Employee (EmployeeID, EmpLastName, EmpFirstName, DepartmentID)
VALUES (2, 'Smith', 'John', 101);

INSERT INTO Bonus (BonusAmount, BonusDate, EmployeeID)
VALUES (10000, '2022-02-15', 2);



SELECT * FROM BonusAudit;
SELECT * FROM Bonus;



     
    

