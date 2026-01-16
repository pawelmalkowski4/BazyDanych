CREATE VIEW v_FullSalesReport AS
SELECT 
    o.OrderID,
    o.OrderDate,
    c.CategoryName,
    p.ProductName,
    od.Quantity,
    od.UnitPrice,
    (od.Quantity * od.UnitPrice * (1 - od.Discount)) AS TotalRowValue,
    cust.CustomerType
FROM OrderDetails od
JOIN Orders o ON od.OrderID = o.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN Customers cust ON o.CustomerID = cust.CustomerID;


CREATE VIEW v_InventoryStatus AS
WITH Constants AS (
    SELECT 50 AS BatchSize
)
SELECT 
    p.ProductID,
    p.ProductName,
    c.CategoryName,
    p.UnitsInStock,
    p.ProductionCapacity,
    CASE 
        WHEN p.UnitsInStock = 0 THEN 'Out of Stock'
        WHEN p.UnitsInStock < 10 THEN 'Low Stock - Reorder'
        ELSE 'Available'
    END AS StockStatus,
    CAST(const.BatchSize/ NULLIF(p.ProductionCapacity, 0) AS DECIMAL(5,1)) AS DaysToProduceBatch
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
CROSS JOIN Constants const;
GO



CREATE VIEW v_ProductProductionCosts AS
SELECT 
    p.productID,
    p.ProductName,
    c.CategoryName,
    SUM(comp.ComponentPrice * pc.PartsCounter) AS TotalMaterialCost,
    p.UnitPrice AS SellingPrice,
    (p.UnitPrice - SUM(comp.ComponentPrice * pc.PartsCounter)) AS EstimatedMargin
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
JOIN ProductComposition pc ON p.ProductID = pc.ProductID
JOIN Components comp ON pc.ComponentID = comp.ComponentID
GROUP BY p.ProductID, p.ProductName, c.CategoryName, p.UnitPrice;
GO



CREATE VIEW v_CustomerOrderSummary AS
SELECT 
    c.CustomerID,
    CASE 
        WHEN c.CustomerType = 'Company' THEN comp.CompanyName
        ELSE pc.FirstName + ' ' + pc.LastName
    END AS CustomerName,
    COUNT(o.OrderID) AS OrderCount,
    MIN(o.OrderDate) AS FirstOrderDate,
    MAX(o.OrderDate) AS LastOrderDate,
    ISNULL(CAST(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS DECIMAL(10,2)), 0.00) AS TotalSpent,
    CAST(AVG(od.Discount * 100) AS DECIMAL(5,2)) AS AvgDiscountPct
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
LEFT JOIN Companies comp ON c.CustomerID = comp.CustomerID
LEFT JOIN PrivateCustomers pc ON c.CustomerID = pc.CustomerID
GROUP BY c.CustomerID, c.CustomerType, comp.CompanyName, pc.FirstName, pc.LastName;

CREATE VIEW v_MonthlySalesStats AS
SELECT 
    YEAR(o.OrderDate) AS SalesYear,
    MONTH(o.OrderDate) AS SalesMonth,
    DATENAME(MONTH, o.OrderDate) AS MonthName,
    COUNT(DISTINCT o.OrderID) AS TotalOrders, 
    SUM(od.Quantity) AS TotalProductsSold,   
    CAST(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS DECIMAL(10,2)) AS TotalRevenue
FROM Orders o
JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE o.Status != 'Cancelled'
GROUP BY 
    YEAR(o.OrderDate), 
    MONTH(o.OrderDate), 
    DATENAME(MONTH, o.OrderDate);
GO