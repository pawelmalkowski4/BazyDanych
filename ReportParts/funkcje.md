## Funkcje

### 1. Obliczanie kosztu materiałowego produktu
(`CalculateProductionCost`)

Funkcja oblicza sumaryczny koszt surowców potrzebnych do wytworzenia jednej sztuki produktu na podstawie jego receptury (tabela `ProductComposition`) oraz aktualnych cen komponentów w magazynie.

```sql
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
```

### 2. Szacowanie czasu produkcji
(`EstimateProductionTime`)

Funkcja służy do planowania mocy przerobowych. Szacuje czas (w godzinach) potrzebny na realizację zlecenia o zadanej wielkości (`@IloscSztuk`). Obliczenia bazują na parametrze wydajności (`ProductionCapacity`) zdefiniowanym dla każdego produktu. Funkcja posiada zabezpieczenie przed błędem dzielenia przez zero.

```sql
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
```

### 3. Całkowita wartość klienta (LTV)

(`CalculateCustomerValue`)

Funkcja oblicza całkowitą wartość przychodu wygenerowanego przez danego klienta. Sumuje ona wartość wszystkich pozycji z zamówień o statusie Completed, uwzględniając przy tym indywidualnie przyznane rabaty (Discount).


```sql
CREATE FUNCTION dbo.CalculateCustomerValue (@CustomerID INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @SumaWydatkow DECIMAL(12,2);

    -- Sumujemy: (Ilość * Cena) * (1 - Rabat)
    SELECT @SumaWydatkow = SUM((od.Quantity * od.UnitPrice) * (1.00 - ISNULL(od.Discount, 0)))
    FROM Orders o
    JOIN OrderDetails od ON o.OrderID = od.OrderID
    WHERE o.CustomerID = @CustomerID 
      AND o.Status = 'Completed';

    RETURN ISNULL(@SumaWydatkow, 0);
END;
```