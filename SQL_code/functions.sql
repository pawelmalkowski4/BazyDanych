-- Function 1: CalculateProductionCost
-- Calculates total material cost for a single product unit
CREATE FUNCTION dbo.CalculateProductionCost (@ProductID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalCost DECIMAL(10,2);

    -- Sum: (Component Price * Quantity in recipe)
    SELECT @TotalCost = SUM(c.ComponentPrice * pc.PartsCounter)
    FROM ProductComposition pc
    JOIN Components c ON pc.ComponentID = c.ComponentID
    WHERE pc.ProductID = @ProductID;

    -- Return 0 if no components found or result is NULL
    RETURN ISNULL(@TotalCost, 0);
END;
GO

-- Function 2: EstimateProductionTime
-- Estimates hours needed to produce a specific quantity
CREATE FUNCTION dbo.EstimateProductionTime (@ProductID INT, @TargetQuantity INT)
RETURNS DECIMAL(10,1)
AS
BEGIN
    DECLARE @Capacity INT;
    DECLARE @EstimatedHours DECIMAL(10,1);

    -- Get production capacity (units per hour) from Products table
    SELECT @Capacity = ProductionCapacity 
    FROM Products 
    WHERE ProductID = @ProductID;

    -- Prevent division by zero
    IF @Capacity IS NULL OR @Capacity = 0
        SET @EstimatedHours = 0;
    ELSE
        -- Calculate time: Quantity / Capacity
        SET @EstimatedHours = CAST(@TargetQuantity AS DECIMAL) / CAST(@Capacity AS DECIMAL);

    RETURN @EstimatedHours;
END;
GO

-- Function 3: CalculateCustomerValue
-- Calculates total revenue from a specific customer (Completed orders only)
CREATE FUNCTION dbo.CalculateCustomerValue (@CustomerID INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @TotalSpend DECIMAL(12,2);

    -- Sum: (Quantity * UnitPrice) * (1 - Discount)
    SELECT @TotalSpend = SUM((od.Quantity * od.UnitPrice) * (1.00 - ISNULL(od.Discount, 0)))
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE o.CustomerID = @CustomerID 
      AND o.Status = 'Completed';

    RETURN ISNULL(@TotalSpend, 0);
END;
GO