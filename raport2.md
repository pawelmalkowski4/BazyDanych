<style>
    body {
        font-size: 10pt;
    }

    .markdown-body {
        padding: 5px;
        max-width: 100%;
    }


    pre, blockquote {
        page-break-inside: avoid; 
    }

    code, pre {
        font-size: 7pt;
        font-family: 'Consolas', 'Courier New', monospace;
    }

    h1 { font-size: 18pt; }
    h2 { font-size: 16pt; }
    h3 { font-size: 14pt; }
</style>

# Podstawy baz danych

pn 9:45\
nr zespołu: 21\
**Autorzy**: Iga Szaflik, Paweł Małkowski, Mikołaj Gaweł \
link

# 1. Wymagania i funkcje systemu

Zaimplementowana baza danych realizuje poniższe funkcje:

**Produkcja:**

- obliczanie kosztu produkcji danego towaru
- określenie czasu potrzebnego do produkcji (na podstawie wydajności)
- umożliwienie dokonywania preorderów (rezerwacja produkcji pod konkretne zamówienie)

**Sprzedaż:**

- obsługa klientów indywidualnych oraz firm (rozdzielenie struktur)
- obsługa statusów płatności
- możliwość udzielenia rabatu na konkretne pozycje zamówienia

**Analiza:**

- wprowadza funkcje służące analizie danych i kosztów produkcji

# 2. Baza danych

Nasza baza danych składa się z następujących tabel:

**Produkty/Magazyn**:

- Kategorie (`Categories`)
- Części do produkcji (`Components`)
- Produkty (`Products`)
- Skład produktu (`ProductComposition`)

**Sprzedaż i Klienci**:

- Klienci - tabela bazowa (`Customers`)
- Klienci Indywidualni (`PrivateCustomers`)
- Firmy (`Companies`)
- Zamówienia (`Orders`)
- Szczegóły zamówienia (`OrderDetails`)
- Płatności (`Payments`)

**Produkcja**:

- Plan Produkcji (`ProductionPlan`)
- Rezerwacje Produkcyjne (`ProductionOrders`)

### Implementacja struktur bazy danych (Kod DDL)

Poniżej znajduje się kod tworzący tabele z uwzględnieniem warunków integralności oraz relacji.

- Kategorie
```sql
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(500)
);
```

- Jest to tabela słownikowa służąca do definiowania kategorii produktów. Umożliwia logiczne uporządkowanie produktów w magazynie oraz ułatwia generowanie raportów sprzedaży w podziale na grupy

| Nazwa atrybutu | Typ | Opis/Uwagi |
| -------------- | --- | ---------- |
| CategoryID     | INT |     Klucz główny (PK). Pole z autoinkrementacją (IDENTITY) – unikalny numer nadawany automatycznie przez bazę danych.    |
| CategoryName  |  NVARCHAR(50)   |     Nazwa kategorii (np. "Biurka", "Fotele"). Pole wymagane (NOT NULL).     |
|Description| NVARCHAR(500) |Dodatkowy opis tekstowy wyjaśniający, co wchodzi w skład danej kategorii.|


- Części do produkcji
```sql

CREATE TABLE Components (
    ComponentID INT IDENTITY(1,1) PRIMARY KEY,
    ComponentName NVARCHAR(100) NOT NULL,
    ComponentPrice DECIMAL(10,2) NOT NULL,
    UnitsInStock INT DEFAULT 0
);
```
- Tabela ta pełni rolę magazynu surowców i półproduktów. Przechowuje szczegółowe informacje o wszystkich elementach składowych (np. blaty, nogi, śruby) niezbędnych do wytworzenia produktów. Służy również do inwentaryzacji (śledzenia stanu) oraz wyliczania kosztów produkcji.

| Nazwa atrybutu | Typ | Opis/Uwagi |
| -------------- | --- | ---------- |
|ComponentID |INT | Klucz główny (PK) z autoinkrementacją. Unikalny identyfikator danej części w systemie. |
|ComponentName | NVARCHAR(100) | Nazwa części (np. "Noga metalowa czarna"). Pole wymagane.|
|ComponentPrice | DECIMAL(10,2)|ednostkowy koszt zakupu lub wytworzenia danej części. Typ DECIMAL zapewnia precyzję dla wartości pieniężnych.|
|UnitsInStock | INT | Aktualna ilość sztuk dostępna w magazynie. Domyślnie ustawiona na 0 (DEFAULT 0). |


- Produkty
```sql

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID),
    UnitPrice DECIMAL(10,2) NOT NULL,
    UnitsInStock INT DEFAULT 0,
    ProductionCapacity INT NOT NULL
);
```
- Jest to centralna tabela systemu reprezentująca katalog wyrobów gotowych przeznaczonych do sprzedaży. Oprócz podstawowych danych handlowych i stanów magazynowych, przechowuje kluczowy parametr ProductionCapacity. Jest on niezbędny do algorytmów planowania produkcji, pozwalając oszacować czas potrzebny na realizację zamówienia.

| Nazwa atrybutu | Typ | Opis/Uwagi |
| -------------- | --- | ---------- |
|ProductID |INT |Klucz główny (PK) z autoinkrementacją. Unikalny identyfikator produktu.|
|ProductName |NVARCHAR(100) | Pełna nazwa handlowa produktu. Pole wymagane. |
|CategoryID |INT| Klucz obcy (FK) wiążący produkt z tabelą Categories.|
|UnitPrice | DECIMAL(10,2) | Bazowa cena sprzedaży produktu (netto/brutto).|
|UnitsInStock | INT | Aktualny stan magazynowy wyrobów gotowych. Domyślnie 0. |
|ProductionCapacity | INT | Zdolność produkcyjna (liczba sztuk na dzień). Parametr służący do harmonogramowania.|

- Skład produktu
```sql

CREATE TABLE ProductComposition (
    CompositionID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    ComponentID INT FOREIGN KEY REFERENCES Components(ComponentID),
    PartsCounter DECIMAL(10,2) NOT NULL
);
```
- Tabela ta realizuje funkcję listy materiałowej. Jest to tabela, która definiuje "przepis" na dany produkt. Określa relację wiele-do-wielu między produktami a komponentami, wskazując dokładnie, jakie części i w jakiej ilości są potrzebne do wyprodukowania jednej sztuki danego produktu.

| Nazwa atrybutu | Typ | Opis/Uwagi |
| -------------- | --- | ---------- |
|CompositionID |INT | Klucz główny (PK) z autoinkrementacją. Unikalny identyfikator wpisu w recepturze.|
|ProductID |INT |Klucz obcy (FK) wskazujący na produkt z tabeli Products, którego dotyczy ten składnik.|
|ComponentID | INT |Klucz obcy (FK) wskazujący na surowiec/część z tabeli Components. |
|PartsCounter | DECIMAL(10,2) | Ilość danej części niezbędna do wytworzenia jednej sztuki produktu końcowego (np. 4.00 dla nóg biurka). |

```sql

-- Klienci
CREATE TABLE Customers(
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerType NVARCHAR(20) NOT NULL CHECK (CustomerType IN ('Private', 'Company')),
    Address NVARCHAR(100),
    City NVARCHAR(50),
    PostCode VARCHAR(10),
    Email VARCHAR(100),
    Phone VARCHAR(20)
);

-- Klienci Indywidualni
CREATE TABLE PrivateCustomers(
    CustomerID INT PRIMARY KEY FOREIGN KEY REFERENCES Customers(CustomerID),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL
);

-- Firmy
CREATE TABLE Companies (
    CustomerID INT PRIMARY KEY FOREIGN KEY REFERENCES Customers(CustomerID),
    CompanyName NVARCHAR(100) NOT NULL,
    NIP VARCHAR(15)
);

-- Zamówienia
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID), 
    OrderDate DATETIME DEFAULT GETDATE(),
    RequiredDate DATETIME,
    Status VARCHAR(20) DEFAULT 'Pending' CHECK (Status IN ('Pending', 'In Production', 'Completed', 'Cancelled'))
);

-- Płatności
CREATE TABLE Payments(
    OrderID INT PRIMARY KEY FOREIGN KEY REFERENCES Orders(OrderID),
    PaymentStatus VARCHAR(20) DEFAULT 'Unpaid' CHECK (PaymentStatus IN ('Pending', 'Paid', 'Unpaid')),
    PaymentMethod VARCHAR(50)
);

-- Szczegóły zamówienia
CREATE TABLE OrderDetails (
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL,
    Discount DECIMAL(5,2) DEFAULT 0.00,
    PRIMARY KEY (OrderID, ProductID)
);

-- Plan Produkcji
CREATE TABLE ProductionPlan (
    PlanID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    StartDate DATE,
    OutDate DATE,
    BatchSize INT,
    Status VARCHAR(20) DEFAULT 'Planned' CHECK (Status IN ('Planned', 'In Production', 'Completed')),
    ActualProductionCost DECIMAL(10,2) NULL
);

-- Rezerwacje Produkcyjne
CREATE TABLE ProductionOrders (
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    PlanID INT FOREIGN KEY REFERENCES ProductionPlan(PlanID),
    ReservedQuantity INT NOT NULL CHECK (ReservedQuantity > 0),
    ReservationDate DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (OrderID, PlanID)
);
