USE u_szaflik;
GO

-- KATEGORIE
INSERT INTO Categories (CategoryName, Description) VALUES 
('Biurka', 'Biurka biurowe, gamingowe i regulowane'),
('Fotele', 'Fotele ergonomiczne i gamingowe'),
('Akcesoria', 'Uchwyty, podstawki i inne dodatki');

-- KOMPONENTY
INSERT INTO Components (ComponentName, ComponentPrice, UnitsInStock) VALUES 
('Blat dêbowy 160x80', 250.00, 100),
('Noga metalowa regulowana (sztuka)', 45.00, 400),
('Kó³ka gumowe (zestaw 5 szt)', 20.00, 200),
('Siedzisko ergonomiczne', 150.00, 50),
('Pod³okietnik 4D (sztuka)', 30.00, 100),
('Œruby monta¿owe (zestaw)', 5.00, 1000),
('Stela¿ biurka elektryczny', 600.00, 30);

-- PRODUKTY
INSERT INTO Products (ProductName, CategoryID, UnitPrice, UnitsInStock, ProductionCapacity) VALUES 
('Biurko Gamingowe PRO', 1, 1200.00, 10, 5),
('Fotel Prezesa', 2, 850.00, 5, 8),
('Biurko Elektryczne StandUp', 1, 1800.00, 2, 3),
('Uchwyt na monitor', 3, 150.00, 50, 20),
('Fotel Junior', 2, 450.00, 15, 10);

-- SK£AD PRODUKTU
-- Biurko Gamingowe (ID 1)
INSERT INTO ProductComposition (ProductID, ComponentID, PartsCounter) VALUES 
(1, 1, 1),    -- 1x Blat
(1, 2, 4),    -- 4x Noga
(1, 6, 1);    -- 1x Œruby

-- Fotel (ID 2)
INSERT INTO ProductComposition (ProductID, ComponentID, PartsCounter) VALUES 
(2, 4, 1),    -- 1x Siedzisko
(2, 3, 1),    -- 1x Zestaw kó³ek
(2, 6, 2);    -- 2x Œruby

-- KLIENCI I ZAMÓWIENIA 
DECLARE @i INT = 0;
DECLARE @MaxOrders INT = 110; -- Ile zamówieñ chcemy wygenerowaæ
DECLARE @NewCustID INT;
DECLARE @NewOrderID INT;
DECLARE @RandProduct INT;
DECLARE @RandQty INT;

WHILE @i < @MaxOrders
BEGIN
    INSERT INTO Customers (CustomerType, Address, City, PostCode, Email, Phone)
    VALUES (
        CASE WHEN @i % 3 = 0 THEN 'Company' ELSE 'Private' END, -- Co trzeci to firma
        'Ulica Losowa ' + CAST(@i as VARCHAR),
        CASE WHEN @i % 2 = 0 THEN 'Warszawa' ELSE 'Kraków' END,
        '00-' + CAST((100+@i) as VARCHAR),
        'klient' + CAST(@i as VARCHAR) + '@mail.com',
        '500-600-' + CAST((100+@i) as VARCHAR)
    );
    
    SET @NewCustID = SCOPE_IDENTITY(); 

    IF @i % 3 = 0 
    BEGIN
        INSERT INTO Companies (CustomerID, CompanyName, NIP)
        VALUES (@NewCustID, 'Firma ' + CAST(@i as VARCHAR) + ' Sp. z o.o.', '123456789' + CAST(@i%9 as VARCHAR));
    END
    ELSE
    BEGIN
        INSERT INTO PrivateCustomers (CustomerID, FirstName, LastName)
        VALUES (@NewCustID, 'Jan', 'Kowalski_' + CAST(@i as VARCHAR));
    END


    INSERT INTO Orders (CustomerID, RequiredDate, Status)
    VALUES (
        @NewCustID, 
        DATEADD(day, 7, GETDATE()), 
        CASE WHEN @i % 5 = 0 THEN 'Completed' ELSE 'Pending' END
    );

    SET @NewOrderID = SCOPE_IDENTITY();
    

    SET @RandProduct = (ABS(CHECKSUM(NEWID())) % 5) + 1; 
    SET @RandQty = (ABS(CHECKSUM(NEWID())) % 10) + 1;

    INSERT INTO OrderDetails (OrderID, ProductID, Quantity, UnitPrice, Discount)
    VALUES (
        @NewOrderID, 
        @RandProduct, 
        @RandQty, 
        (SELECT UnitPrice FROM Products WHERE ProductID = @RandProduct), -- Cena z tabeli Products
        0.00
    );


    INSERT INTO Payments (OrderID, PaymentStatus, PaymentMethod)
    VALUES (
        @NewOrderID,
        CASE WHEN @i % 5 = 0 THEN 'Paid' ELSE 'Pending' END,
        'BLIK'
    );


    IF @i % 10 = 0
    BEGIN
        INSERT INTO ProductionPlan (ProductID, StartDate, OutDate, BatchSize, Status)
        VALUES (@RandProduct, GETDATE(), DATEADD(day, 3, GETDATE()), @RandQty, 'Planned');
        
        DECLARE @NewPlanID INT = SCOPE_IDENTITY();

        INSERT INTO ProductionOrders (OrderID, PlanID, ReservedQuantity)
        VALUES (@NewOrderID, @NewPlanID, @RandQty);
    END

    SET @i = @i + 1;
END;

PRINT 'Baza danych zosta³a wype³niona przyk³adowymi danymi.';