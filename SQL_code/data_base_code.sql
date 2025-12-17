USE [u_pmalkows];
GO

CREATE TABLE Components (
    ComponentID INT IDENTITY(1,1) PRIMARY KEY,
    ComponentName NVARCHAR(100) NOT NULL,
    ComponentPrice DECIMAL(10,2) NOT NULL,
    UnitsInStock INT DEFAULT 0
);

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(500)
);

CREATE TABLE Customers(
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerType NVARCHAR(20) NOT NULL CHECK (CustomerType IN ('Private', 'Company')),
    Address NVARCHAR(100),
    City NVARCHAR(50),
    PostCode VARCHAR(10),
    Email VARCHAR(100),
    Phone VARCHAR(20)
)

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    UnitPrice DECIMAL(10,2) NOT NULL,
    UnitsInStock INT DEFAULT 0,
    ProductionCapacity INT NOT NULL
);

CREATE TABLE ProductComposition (
    CompositionID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    ComponentID INT FOREIGN KEY REFERENCES Components(ComponentID),
    PartsCounter DECIMAL(10,2) NOT NULL
);


CREATE TABLE PrivateCustomers(
    CustomerID INT PRIMARY KEY FOREIGN KEY REFERENCES Customers(CustomerID),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
);

CREATE TABLE Companies (
    CustomerID INT PRIMARY KEY FOREIGN KEY REFERENCES Customers(CustomerID),
    CompanyName NVARCHAR(100) NOT NULL,
    NIP VARCHAR(15),
);

CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID), 
    OrderDate DATETIME DEFAULT GETDATE(),
    RequiredDate DATETIME,
    Status VARCHAR(20) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'In Production', 'Completed', 'Cancelled')),
);

CREATE TABLE Payments(
    OrderID INT PRIMARY KEY FOREIGN KEY REFERENCES Orders(OrderID),
    PaymentStatus VARCHAR(20) DEFAULT 'Unpaid' CHECK (PaymentStatus IN ('Pending', 'Paid', 'Unpaid')),
    PaymentMethod VARCHAR(50)
);

CREATE TABLE OrderDetails (
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL,
    Discount DECIMAL(5,2) DEFAULT 0.00 -- procenty
    PRIMARY KEY (OrderID, ProductID)
);

CREATE TABLE ProductionPlan (
    PlanID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    StartDate DATE,
    OutDate DATE, 
    BatchSize INT,
    Status VARCHAR(20) DEFAULT 'Planned' CHECK (Status IN ('Planned', 'In Production', 'Completed')),
    ActualProductionCost DECIMAL(10,2) NULL 
);

CREATE TABLE ProductionOrders (
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    PlanID INT FOREIGN KEY REFERENCES ProductionPlan(PlanID),
    ReservedQuantity INT NOT NULL CHECK (ReservedQuantity > 0),
    ReservationDate DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (OrderID, PlanID)
);