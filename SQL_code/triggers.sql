-- Triggers

CREATE TRIGGER trg_ProductionPlan_Start_ReduceComponents
ON ProductionPlan
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deleted d ON i.PlanID = d.PlanID
        WHERE i.Status = 'In Production'
          AND d.Status <> 'In Production'
    )
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM Components C
            JOIN ProductComposition PC ON C.ComponentID = PC.ComponentID
            JOIN inserted i ON PC.ProductID = i.ProductID
            JOIN deleted d ON i.PlanID = d.PlanID
            WHERE i.Status = 'In Production' 
              AND d.Status <> 'In Production'
              AND (C.UnitsInStock - (PC.PartsCounter * i.BatchSize)) < 0
        )
        BEGIN
            RAISERROR ('Błąd: Brak wystarczającej liczby komponentów w magazynie, aby rozpocząć produkcję.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE C
        SET C.UnitsInStock = C.UnitsInStock - (PC.PartsCounter * i.BatchSize)
        FROM Components C
        JOIN ProductComposition PC ON C.ComponentID = PC.ComponentID
        JOIN inserted i ON PC.ProductID = i.ProductID
        JOIN deleted d ON i.PlanID = d.PlanID
        WHERE i.Status = 'In Production' 
          AND d.Status <> 'In Production';
    END
END;
GO

CREATE TRIGGER trg_ReduceProductStock_OnOrder
ON OrderDetails
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE P
    SET P.UnitsInStock = P.UnitsInStock - i.Quantity
    FROM Products P
    JOIN inserted i ON P.ProductID = i.ProductID;
END;
GO