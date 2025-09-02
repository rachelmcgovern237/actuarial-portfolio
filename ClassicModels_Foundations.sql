/* The purpose of this SQL file is to showcase fundamental Data Definition Language,
Data Manipulation Language, and Data Control Language */

-- This code creates a basic database table
CREATE TABLE Customers(CustomerID int, CustomerFirstName char, CustomerLastName char);

-- This code removes the table
DROP TABLE Customers;


-- This code shows the basics of adding values to a database as well as removing objects, tables, and schema
SELECT * FROM learning.Customers;

INSERT INTO learning.Customers
VALUES
(101, 'John', 'Doe'),
(102, 'Sarah', 'Jones'),
(103, 'Richard','Smith')
;

DROP TABLE learning.Customers;
DROP SCHEMA learning;

-- This section showcases some of the fundamental commands of SQL (SELECT, FROM, WHERE, & AND)
SELECT * 
FROM customers
WHERE contactLastName <> 'Young';

SELECT customerName, contactFirstName, contactLastName, phone, city, country
FROM customers
WHERE country = 'USA' AND contactFirstName = 'Julie';

SELECT contactFirstName, contactLastName
FROM customers
WHERE country = 'Norway' 
or country = 'Sweden';

SELECT contactFirstName, contactLastName
FROM customers
WHERE (country = 'USA' or country = 'UK' )
AND contactLastName = 'Brown';

SELECT email
FROM employees
WHERE jobTitle = 'Sales Rep';

-- The following lines showcase how to use the upper() command
SELECT *, upper(firstName) as uppercasename
FROM employees;

-- The following lines showcase how to use the In & Not In operators
SELECT *
FROM employees
WHERE upper(email) in
('PMARSH@CLASSICMODELCARS.COM',
'GBONDUR@CLASSICMODELCARS.COM',
'ABOW@CLASSICMODELCARS.COM');

SELECT *
FROM employees
WHERE upper(email) not in
('PMARSH@CLASSICMODELCARS.COM',
'GBONDUR@CLASSICMODELCARS.COM',
'ABOW@CLASSICMODELCARS.COM');

-- The following lines showcase and example of using the distinct operator
SELECT distinct country
FROM customers;

-- The following lines showcase how to use the LIKE and % operators
SELECT *
FROM customers
WHERE city LIKE '%New%';

-- The following lines showcase how to use the ORDER BY operator
SELECT *
FROM employees
ORDER BY lastName desc, firstName desc;

-- The following lines showcase how to use the INNER, LEFT, & RIGHT JOIN operators
SELECT *
FROM orders T1
INNER JOIN customers T2
on T1.customerNumber = T2.customerNumber;

SELECT *
FROM orders
WHERE orderNumber = 10100;

SELECT *
FROM customers
WHERE customerNumber = 363;

SELECT firstName, lastName, customerName
FROM classicmodels.employees T1
LEFT JOIN classicmodels.customers T2
ON t1.employeeNumber = t2.salesRepEmployeeNumber;

SELECT *
FROM classicmodels.employees T1
LEFT JOIN classicmodels.customers T2
ON t1.employeeNumber = t2.salesRepEmployeeNumber
WHERE t2.customerNumber is null and jobTitle = 'Sales Rep';

SELECT firstName, lastName, customerName
FROM classicmodels.customers T1
RIGHT JOIN classicmodels.employees T2
ON t1.salesRepEmployeeNumber = t2.employeeNumber;

SELECT A.customerName, B.amount, B.paymentDate
FROM classicmodels.customers A
INNER JOIN classimodels.payments B
ON A.customerNumber = B.customerNumber;

-- The following lines showcase use of UNION and UNION ALL
SELECT *
FROM customers;

SELECT *
FROM employees;

SELECT 'customer' as type, contactFirstName, contactLastName as lastname
FROM customers

UNION

SELECT 'employee' as type, firstName, lastName
FROM employees
;

-- Sum, Round, Group By, & Having practice
SELECT paymentDate, round(sum(amount),1) as payment
FROM payments
GROUP BY paymentDate
HAVING payment > 50000
ORDER BY paymentDate;

-- COUNT, MIN, MAX, & AVG
SELECT count(distinct orderNumber)
FROM orderdetails;

SELECT productCode, count(distinct orderNumber) as orders
FROM orderdetails
GROUP BY productCode;

SELECT paymentDate, max(amount), min(amount)
FROM payments
GROUP BY paymentDate
HAVING paymentDate = '2003-12-09'
;

SELECT avg(amount) as average
FROM payments
;

-- Show the customer name of the company which has made the most amount of orders.
SELECT customerName, count(orderNumber) as Highest
FROM orders a
INNER JOIN customers b
ON a.customerNumber = b.customerNumber
GROUP BY customerName
ORDER BY Highest desc
LIMIT 1
;

-- Display each customer's first and last order date.
SELECT customerName, min(orderDate) as First, max(orderDate) as Last
FROM orders a
INNER JOIN customers b
ON a.customerNumber = b.customerNumber
GROUP BY customerName
;

-- The following lines showcase use of Subquery and Common Table Expressions (CTE)

-- Use a subquery to calculate the average amount of orders
SELECT avg(orders)
FROM
(SELECT orderDate, count(orderNumber) as orders
FROM orders
GROUP BY orderDate) t1
;

-- Use a CTE to calculate the average amount of orders
WITH cte_orders as 
(
SELECT orderDate, count(orderNumber) as orders
FROM orders
GROUP BY orderDate
)
SELECT avg(orders)
FROM cte_orders
;

-- The following lines showcase use of a Case Statement (note: aka 'if else' in other languages)

-- Show the number of customers within each credit limit range using a case statement
SELECT
CASE WHEN creditLimit < 75000 THEN 'a: Less than $75k'
WHEN creditLimit BETWEEN 75000 AND 100000 THEN 'b: $75k -
$100k'
WHEN creditLimit BETWEEN 100000 AND 150000 THEN 'c: $100k
- $150k'
WHEN creditLimit > 150000 THEN 'd: Over $150k'
ELSE 'Other' END AS credit_limit_grp,
count(distinct c.customernumber) AS customers
FROM classicmodels.customers c
GROUP BY credit_limit_grp
;

-- Use a case statement to create a flag which displays 1 when an order of motorcycles is more than 40.
SELECT t1.ordernumber, orderdate, quantityordered, productname, productline,
CASE When quantityordered > 40 AND productline = 'Motorcycles' THEN 1 ELSE 0 END AS ordered_over_40_motorcycles
FROM classicmodels.orders t1
JOIN classicmodels.orderdetails t2 ON t1.ordernumber = t2.ordernumber
JOIN classicmodels.products t3 ON t2.productcode = t3.productcode
;


-- Use a CTE to show the order dates and displays the number of orders that had over 40 motorcycles that day.
WITH main_cte as
(
SELECT t1.ordernumber, orderdate, quantityordered, productname, productline,
CASE When quantityordered > 40 AND productline = 'Motorcycles' THEN 1 ELSE 0 END AS ordered_over_40_motorcycles
FROM classicmodels.orders t1
JOIN classicmodels.orderdetails t2 ON t1.ordernumber = t2.ordernumber
JOIN classicmodels.products t3 ON t2.productcode = t3.productcode
)

SELECT orderDate, sum(ordered_over_40_motorcycles) as ordered_over_40_motorcycles
FROM main_cte
GROUP BY orderDate
;

-- Use a case statement to flag any order number from orders that contains the word "negotiate" in the comments
SELECT *, CASE WHEN comments LIKE '%negotiate%' THEN 1 ELSE 0 END AS negotiated
FROM classicmodels.orders
;

-- Use a case statement to give a string output instead of 1 or 0.
SELECT *, CASE WHEN comments LIKE '%dispute%' THEN 1 ELSE 0 END AS disputed,
CASE WHEN comments LIKE '%negotiate%' THEN 'Negotiated Order'
WHEN comments LIKE '%dispute%' THEN 'Disputed Order'
ELSE 'No Dispute' END AS status_1
FROM classicmodels.orders
;

-- The following lines showcase use of a partition
-- Use a partition to show each customer's second purchase date
WITH main_cte AS
(
SELECT DISTINCT 
t3.customername, 
t1.customernumber, 
t1.ordernumber, 
orderdate, 
row_number() OVER (PARTITION BY t3.customernumber ORDER BY orderdate) AS purchase_number

FROM classicmodels.orders t1
JOIN classicmodels.customers t3 ON t1.customernumber = t3.customernumber
ORDER BY t3.customername)
SELECT *
FROM main_cte
WHERE purchase_number = 2
;

-- The following lines showcase use of LEAD & LAG

-- Use LEAD to show each customer's next payment.
SELECT customernumber, paymentdate, amount,
LEAD(amount) OVER (PARTITION BY customernumber ORDER BY paymentdate) AS next_payment
FROM classicmodels.payments
;

-- Use LAG to show each customer's previous payment.
SELECT customernumber, paymentdate, amount,
LAG(amount) OVER (PARTITION BY customernumber ORDER BY paymentdate) AS previous_payment
FROM classicmodels.payments
;

-- Use LAG and a CTE to show the difference between each customer's payments over time.
WITH cte_main AS
(
SELECT customernumber, paymentdate, amount,
LAG(amount) OVER (PARTITION BY customernumber ORDER BY paymentdate) AS previous_payment
FROM classicmodels.payments
)
SELECT *, amount - previous_payment as difference
FROM cte_main
;

-- Show order date, order number, and sales rep employee number for each sales rep's second order.
WITH cte_main as
(
SELECT orderDate, t1.orderNumber, salesRepEmployeeNumber,
row_number() OVER(PARTITION BY salesRepEmployeeNumber ORDER BY orderDate) as RepOrderNumber

FROM orders t1
INNER JOIN customers t2
ON t1.customerNumber = t2.customerNumber
JOIN employees t3
ON t2.salesRepEmployeeNumber = t3.employeeNumber
)
SELECT *
FROM cte_main
WHERE RepOrderNumber = 2
;

-- The following lines showcase use of date functions
-- Show today's date
SELECT now()
;

-- Show the order date, required date, and how many days until the order is required.
SELECT a.orderNumber, requiredDate, orderDate,
dateDiff(requiredDate, orderDate) as days_until_required
FROM classicmodels.orders a
;

-- Add one year to the required date
SELECT a.orderNumber, orderDate, date_add(requiredDate, INTERVAL 1 year) as one_year_from_required
FROM classicmodels.orders a
;

-- Add 1 year from the order date and subtract 2 months from the order date
SELECT *, date_add(orderDate, INTERVAL 1 year) as one_year_after,
date_sub(orderDate, INTERVAL 2 year) as 2_months_ago
FROM orders
;

-- The following lines showcase use of strings
SELECT *, CAST(paymentDate as DATETIME) as Payment_Time
FROM payments
;

SELECT customerNumber, PaymentDate, substring(paymentDate, 6,5) as Month_Day
FROM classicmodels.payments
;

SELECT *, substring(country, 1,2) as code
FROM customers
;

SELECT employeeNumber, lastName, firstName, concat(firstName,' ',lastName) as Full_Name
FROM classicmodels.employees
;

SELECT customerName, concat(city,', ',country) as city_country
FROM customers
;
