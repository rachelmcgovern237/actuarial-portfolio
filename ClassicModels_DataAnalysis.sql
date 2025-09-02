/*The following file showcases common data analysis exercises using the classic models
sales database and Excel. */

/* Overview of sales for 2004 broken down by product, country, and city
including sales value, cost of sales, and net profit. */

SELECT t1.orderDate, t1.orderNumber, quantityOrdered, priceEach, productName, productLine, buyPrice, city, country
FROM orders t1
INNER JOIN orderdetails t2
ON t1.orderNumber = t2.orderNumber
INNER JOIN products t3
ON t2.productCode = t3.productCode
INNER JOIN customers t4
ON t1.customerNumber = t4.customerNumber
WHERE year(orderDate) = 2004
;
-- Further analysis in Excel

/* Overview of products that are commonly purchased together and products that are 
rarely purchased together */
with prod_sales as
(
SELECT orderNumber, t1.productCode, productLine
FROM orderDetails t1
INNER JOIN products t2
ON t1.productCode = t2.productCode
)
 SELECT distinct t1.orderNumber, t1.productLine as product_one, t2.productLine as product_two
 FROM prod_sales t1
 LEFT JOIN prod_sales t2
 ON t1.orderNumber = t2.orderNumber and t1.productLine <> t2.productLine
;
-- Further analysis in Excel

/* Overview of sales including customer credit limit. Credit limit is grouped with a high level view 
to see if there are higher sales for customers with a higher credit limit */
WITH sales as
(
SELECT t1.orderNumber, t1.customerNumber, productCode, quantityOrdered, priceEach, priceEach * quantityOrdered as sales_value, creditLimit
FROM orders t1
INNER JOIN orderDetails t2
ON t1.orderNumber = t2.orderNumber
INNER JOIN customers t3
ON t1.customerNumber = t3.customerNumber
)
SELECT orderNumber, customerNumber, 
CASE WHEN creditLimit < 75000 then 'a: less than $75k'
WHEN creditLimit between 75000 and 100000 then 'b:$75k - $100K'
WHEN creditLimit between 100000 and 150000 then 'c:$100K - $150K'
WHEN creditLimit > 150000 then 'd:Over $150K'
else 'Other'
end as creditLimit_group,
sum(sales_value) as sales_value
FROM sales
GROUP BY orderNumber, customerNumber, creditLimit
;
-- Further analysis in Excel

/* Create a view showing customer sales with a column that shows the difference in value from the previous sale.
The purpose is to see if customers who make their first purchase are likely to spend more. */
WITH main_cte as
(
SELECT orderNumber, orderDate, customerNumber, sum(salesValue) as salesValue
FROM
(SELECT t1.orderNumber, orderDate, customerNumber, productCode, quantityOrdered*priceEach as salesValue
FROM orders t1
INNER JOIN orderDetails t2
ON t1.orderNumber = t2.orderNumber) main
GROUP BY orderNumber, orderDate, customerNumber
),

salesQuery as
(
SELECT t1.*, customerName, row_number() over (partition by customerName order by orderDate) as purchase_Number,
LAG(salesValue) over(partition by customerName order by orderDate) as prevSalesValue
FROM main_cte t1
INNER JOIN customers t2
ON t1.customerNumber = t2.customerNumber
)
SELECT*, salesValue - prevSalesValue as purchaseValueChange
FROM salesQuery
WHERE prevSalesValue is not NULL
;
-- Further analysis in Excel

/* Create a view showing where the customers of each office are located */
with main_cte as
(
SELECT t1.orderNumber, t2.productCode, t2.quantityOrdered, t2. priceEach, quantityOrdered * priceEach as salesValue,
t3.city as customerCity, t3.country as customerCountry,
t4.productLine, t6.city as officeCity, t6.country as officeCountry
FROM orders t1
INNER JOIN orderDetails t2
ON t1.orderNumber = t2.orderNumber
INNER JOIN customers t3
ON t1.customerNumber = t3.customerNumber
INNER JOIN products t4
ON t2.productCode = t4.productCode
INNER JOIN employees t5
ON t3.salesRepEmployeeNumber = t5.employeeNumber
INNER JOIN offices t6
ON t5.officeCode = t6.officeCode
)
SELECT orderNumber, customerCity, customerCountry, productLine, officeCity, officeCountry, sum(salesValue) as sales
FROM main_cte
GROUP BY orderNumber, customerCity
;

-- Further analysis in Excel

/* Provide a list of orders affected by shipping delays due to weather.
It is possible that they will take up to 3 days to arrive. */
SELECT *,
date_add(shippedDate, interval 3 day) as latestArrival,
CASE WHEN date_add(shippedDate, interval 3 day) > requiredDate THEN 1 ELSE 0 END AS lateFlag
FROM orders
WHERE (CASE WHEN date_add(shippedDate, interval 3 day) > requiredDate THEN 1 ELSE 0 END) = 1
;
-- No further work in Excel for this specific query

/* Create a breakdown of each customer and their sales including a money owed column
to show if any customers have gone over their credit limit. */
WITH cte_sales as
(
SELECT orderDate, t1.orderNumber, t1.customerNumber, customerName, productCode, creditLimit, quantityOrdered * priceEach as salesValue
FROM orders t1
INNER JOIN orderDetails t2
ON t1.orderNumber = t2.orderNumber
INNER JOIN customers t3
ON t1.customerNumber = t3.customerNumber
),

cte_running_total_sales as
(
SELECT *, LEAD(orderDate) OVER(partition by customerNumber order by orderDate) as nextOrderDate
FROM
(
SELECT orderDate, orderNumber, customerNumber,customerName, creditLimit, sum(salesValue) as salesValue
FROM cte_sales
GROUP BY orderDate, orderNumber, customerNumber,customerName, creditLimit
) as subquery
),

cte_payments as
(
SELECT *
FROM payments

),

main_cte AS
(
SELECT t1.*, sum(salesValue) over (partition by t1.customerNumber order by orderDate) as runningTotalSales,
sum(amount) over(partition by t1.customerNumber order by orderDate) as runningTotalPayments
FROM cte_running_total_sales t1
LEFT JOIN cte_payments t2
ON t1.customerNumber = t2.customerNumber and t2.paymentDate BETWEEN t1.orderDate AND CASE WHEN t1.nextOrderDate IS NULL THEN current_date ELSE nextOrderDate END

)

SELECT*, runningTotalSales - runningTotalPayments as moneyOwed, creditLimit - (runningTotalSales - runningTotalPayments) as difference
FROM main_cte
;
-- No further analysis in Excel
