-- Question 1.
SELECT i1.ingrName, i2.ingrName
FROM Ingredient i1, Ingredient i2;

-- Question 2.
CREATE VIEW "Review Stars" AS 
SELECT reviewDesc AS "Review", 
CASE reviewStar 
WHEN 5 THEN "⭐⭐⭐⭐⭐"
WHEN 4 THEN "⭐⭐⭐⭐"
WHEN 3 THEN "⭐⭐⭐"
WHEN 2 THEN "⭐⭐"
WHEN 1 THEN "⭐"
END AS "Stars"
FROM Review;


-- Question 3.
CREATE TRIGGER validateEmail 
BEFORE INSERT ON Customer
BEGIN 
    SELECT 
    CASE 
    WHEN NEW.email NOT LIKE '_%@_%._%' THEN 
    RAISE (ABORT,'Invalid email address') 
    END; 
END;

-- Question 4.
SELECT at.addressTypeDesc AS 'Address Type',
GROUP_CONCAT(c.firstName || ' ' || c.lastName || ' (' || a.suburb || ', ' || a.postalCode || ')', ', ') AS 'Customer'
FROM AddressType at 
JOIN Address a ON a.addressTypeID = at.addressTypeID
JOIN Customer c ON a.customerID = c.customerID
GROUP BY at.addressTypeDesc
ORDER BY at.addressTypeDesc;

-- Question 5.
SELECT e.empFirstName AS "Employee", '$'||SUM(ot.orderTotal) AS "Order Total ($)"
FROM (SELECT e.empID, co.orderNo, SUM(p.prodPrice*op.quantity) AS orderTotal
	  FROM Employee e, CustOrder co, Product p, OrderProduct op
	  WHERE e.empID = co.empID AND co.orderNo = op.orderNo AND p.prodNo = op.prodNo
      GROUP BY co.orderNo) ot, Employee e 
WHERE e.empID = ot.empID 
GROUP BY e.empID;

-- Question 6.
SELECT a.suburb AS "Suburb", "$" || (SUM(p.prodPrice * op.quantity)) AS "Total"
FROM OrderProduct op, Product p, CustOrder co, Address a 
ON op.prodNo = p.prodNo AND op.orderNo = co.orderNo AND co.customerID = a.customerID
GROUP BY a.suburb
ORDER BY (SUM(p.prodPrice) * op.quantity) DESC;

-- Question 7.
SELECT empFirstName AS 'Employee',
CASE
WHEN endDate > DATE('now') 
OR endDate IS NULL 
THEN 'Active'
ELSE 'Inactive'
END AS 'Status',
CASE 
WHEN endDate > DATE('now') 
OR endDate IS NULL 
THEN CAST((JULIANDAY('now') - JULIANDAY(startDate)) / 365.25 AS INT) || ' Year(s) ' || 
CAST(((JULIANDAY('now') - JULIANDAY(startDate)) % 365.25) / 30.44 AS INT) || ' Month(s)'
ELSE CAST((JULIANDAY(endDate) - JULIANDAY(startDate)) / 365.25 AS INT) || ' Year(s) ' || 
CAST(((JULIANDAY(endDate) - JULIANDAY(startDate)) % 365.25) / 30.44 AS INT) || ' Month(s)'
END AS 'Duration'
FROM Employee
ORDER BY Status, CASE
WHEN endDate > DATE('now') 
OR endDate IS NULL 
THEN JULIANDAY('now') - JULIANDAY(startDate)
ELSE JULIANDAY(endDate) - JULIANDAY(startDate)
END DESC;

-- Question 8.
SELECT p.prodNo, p.prodName, p.prodPrice, ps.discount, p.prodPrice*(1-ps.discount) AS DiscountedPrice, ps.endDateTime 
FROM Product p, ProductSpecial ps 
WHERE p.prodNo = ps.prodNo AND DATE('now')<ps.endDateTime;

-- Question 9.
SELECT co.orderNo, '$'||SUM(p.prodPrice*op.quantity) AS orderTotal 
FROM CustOrder co, Product p, OrderProduct op 
WHERE co.orderNo = op.orderNo AND p.prodNo = op.prodNo 
GROUP BY co.orderNo;

-- Question 10.
SELECT co.orderNo, '$'||SUM(p.prodPrice*op.quantity) AS orderTotal
FROM CustOrder co, Product p, OrderProduct op 
WHERE co.orderNo = op.orderNo AND p.prodNo = op.prodNo 
GROUP BY co.orderNo 
HAVING SUM(p.prodPrice*op.quantity) > 100;

-- Question 11.
SELECT prodNo, prodName, prodPrice, CASE WHEN prodDesc LIKE '%ham%' THEN prodPrice+2 WHEN prodDesc LIKE '%garlic%' THEN prodPrice-1 ELSE prodPrice END AS 'Revised price' 
FROM Product;
