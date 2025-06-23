
-- TASK 2: CREAZIONE TABELLE
CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50)
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    CategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

CREATE TABLE Region (
    RegionID INT PRIMARY KEY,
    RegionName VARCHAR(50)
);

CREATE TABLE State (
    StateID INT PRIMARY KEY,
    StateName VARCHAR(50),
    RegionID INT,
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);

CREATE TABLE Sales (
    SalesID INT PRIMARY KEY,
    ProductID INT,
    StateID INT,
    SalesDate DATE,
    Quantity INT,
    Price DECIMAL(10,2),
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (StateID) REFERENCES State(StateID)
);

-- TASK 3: POPOLAMENTO TABELLE
INSERT INTO Category VALUES (1, 'Bikes'), (2, 'Clothing');

INSERT INTO Product VALUES 
(101, 'Bike-100', 1),
(102, 'Bike-200', 1),
(201, 'Bike Gloves M', 2),
(202, 'Bike Gloves L', 2);

INSERT INTO Region VALUES (1, 'WestEurope'), (2, 'SouthEurope');

INSERT INTO State VALUES 
(1, 'France', 1),
(2, 'Germany', 1),
(3, 'Italy', 2),
(4, 'Greece', 2);

INSERT INTO Sales VALUES 
(1, 101, 1, '2024-01-15', 10, 299.99),
(2, 102, 2, '2024-06-10', 5, 399.99),
(3, 201, 3, '2023-10-10', 20, 19.99),
(4, 201, 3, '2024-11-11', 15, 19.99);

-- TASK 4: QUERY

-- Verifica Unicità PK
SELECT ProductID, COUNT(*) FROM Product GROUP BY ProductID HAVING COUNT(*) > 1;

-- Elenco transazioni con booleano >180 giorni
SELECT 
  s.SalesID,
  s.SalesDate,
  p.ProductName,
  c.CategoryName,
  st.StateName,
  r.RegionName,
  CASE 
    WHEN DATEDIFF(CURDATE(), s.SalesDate) > 180 THEN TRUE
    ELSE FALSE
  END AS Over180Days
FROM Sales s
JOIN Product p ON s.ProductID = p.ProductID
JOIN Category c ON p.CategoryID = c.CategoryID
JOIN State st ON s.StateID = st.StateID
JOIN Region r ON st.RegionID = r.RegionID;

-- Prodotti sopra la media dell'ultimo anno
SELECT ProductID, SUM(Quantity) AS TotalSold
FROM Sales
WHERE SalesDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY ProductID
HAVING SUM(Quantity) > (
    SELECT AVG(q) FROM (
        SELECT SUM(Quantity) AS q
        FROM Sales
        WHERE SalesDate >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
        GROUP BY ProductID
    ) AS avg_table
);

-- Fatturato per prodotto per anno
SELECT 
  ProductID,
  YEAR(SalesDate) AS Year,
  SUM(Quantity * Price) AS Revenue
FROM Sales
GROUP BY ProductID, YEAR(SalesDate);

-- Fatturato totale per stato per anno
SELECT 
  st.StateName,
  YEAR(s.SalesDate) AS Year,
  SUM(s.Quantity * s.Price) AS Revenue
FROM Sales s
JOIN State st ON s.StateID = st.StateID
GROUP BY st.StateName, YEAR(s.SalesDate)
ORDER BY Year, Revenue DESC;

-- Categoria più richiesta
SELECT 
  c.CategoryName,
  SUM(s.Quantity) AS TotalQuantity
FROM Sales s
JOIN Product p ON s.ProductID = p.ProductID
JOIN Category c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY TotalQuantity DESC
LIMIT 1;

-- Prodotti invenduti - LEFT JOIN
SELECT p.ProductID, p.ProductName
FROM Product p
LEFT JOIN Sales s ON p.ProductID = s.ProductID
WHERE s.SalesID IS NULL;

-- Prodotti invenduti - NOT IN
SELECT ProductID, ProductName
FROM Product
WHERE ProductID NOT IN (SELECT DISTINCT ProductID FROM Sales);

-- Vista prodotti denormalizzati
CREATE VIEW View_ProductInfo AS
SELECT 
  p.ProductID,
  p.ProductName,
  c.CategoryName
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID;

-- Vista informazioni geografiche
CREATE VIEW View_Geography AS
SELECT 
  st.StateID,
  st.StateName,
  r.RegionName
FROM State st
JOIN Region r ON st.RegionID = r.RegionID;
