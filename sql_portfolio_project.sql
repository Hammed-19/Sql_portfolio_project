Use classicmodels;
Select * from products;
-- Find the product with the highest price. --

Select productName, MSRP as highest_price from products
order by highest_price
Desc limit 1 ;

-- Retrieve the names of all product lines from the ProductLines table  --

Select Distinct(productline) from products;

Select * from customers;

-- Retrieve all orders placed by a specific customer --

Select * from orders o where customerNumber = 131

-- List all products in a specific product line --

Select * from products where productLine ="Classic Cars";

-- Select customer name from customer. Sort by customer name--

Select customerName from customers order by customerName;

-- List each of the different status that an order may be in

Select Distinct(status) from orders;

-- List all the employee job titles

Select Distinct(jobTitle) from employees;

-- List all the territories where we have offices--

Select Distinct(territory)  from offices;

-- List all offices not in the USA 

Select officeCode from offices
where Country != "USA"

-- select customers who do not have a credit limit--

Select * from customers where CreditLimit=0.00;

-- List products that we need to reorder (quantityinstock < 1000)--

Select * from products
where quantityinstock < 1000;

-- List all orders that shipped after the required date--

Select * from orders
where shippedDate > requiredDate;
 
-- List all customers who have the word ‘Mini’ in their name

Select * from Customers
where customerName Like '%mini%';

-- List all products supplied by ‘Highway 66 Mini Classics' --

Select * from products 
where productVendor = "Highway 66 Mini Classics" ;

-- List all employees that don't have a manager--

Select * from Employees
where reportsTo is NUll;

-- Display every order along with the details of that order for order numbers 10270, 10272,10279--

Select o.*, od.*
from orders o 
Join orderdetails od on o.orderNumber=od.orderNumber
where o.orderNumber IN (10270, 10272,10279);

-- select customers that live in the same state as one of our offices --

Select c.customerNumber, c.customerName, c.state, o.state
from Customers c
Inner Join offices o ON c.state=o.state;

-- List products that didn't sell 

Select p.productname from products p
left Join orderdetails od ON od.productCode = p.productCode
where od.productcode is NULL;

-- Find the total of all payments made by each customer --

select CustomerNumber, Sum(Amount)
from payments
group by CustomerNumber;

-- Find the largest payment made by a customer 

select CustomerNumber, Sum(Amount) as largest_payment
from payments
group by CustomerNumber
order by largest_payment Desc
limit 1;

-- What is the total number of products per product line --

Select Count(productName), productline
from products
group by productline;

-- List the total number of products per product line where number of products > 3 

Select productLine, count(productName) as total_products
from products 
group by productline
having count(productName) >3;

-- List the products and the profit that we have made on them. 
-- The profit in each order for a given product is (priceEach –buyPrice) * quantityOrdered.
-- List the product’s name and code with the total profit that we have earned selling that product.

Select p.productCode, p.productName , Sum((od.priceEach - p.buyprice) * od.quantityOrdered) as profit
from products p
Join orderdetails od on p.productCode = od.productCode 
group by p.productCode
order by profit DESC;

-- List the average of the money spent on each product across all orders where that product appears when the customer
-- is based in Japan. Show these products in descending order by the average expenditure

Select productCode, Avg(priceEach) as Avg_Expenditure, c.country from orderdetails od
Join orders o on od.orderNumber = od.orderNumber
join customers c on c.customerNumber = o.customerNumber
where  c.country = 'Japan'
group by productCode
order by Avg_Expenditure DESC;

-- List all customers who didn't order in 2015

Select C.customerNumber, C.customerName, year(o.orderDate) from Customers c
LEFT Join Orders o on o.customerNumber = c.customerNumber
Where year(orderDate) <> '2015' ;

--  List the last name, first name, and employee number of all of the employees  
--  who do not have any customers. Order by last name first, then the first name.

Select LastName, firstName, employeeNumber from employees E
left Join Customers C on e.employeeNumber = C.salesRepEmployeeNumber
WHERE c.customerNumber IS NULL
ORDER BY e.lastName, e.firstName;

-- List the Product Code and Product name of every product that has never been in an order 
-- in which the customer asked for more than 48 of them. Order by the ProductName.

Select p.productcode, p.productname from products p
where p.productcode Not In
( Select od.productCode from
orderdetails od 
where quantityOrdered > 48)
order by p.productName;

-- List the first name and last name of any customer who ordered any products from either of the two product lines
 -- ‘Trains’ or ‘Trucks and Buses’. Do not use an “or”. Instead perform a union. Order by the customer’s name. 
 
SELECT c.contactfirstName as Firstname, c.contactlastName as lastName
FROM Customers c
WHERE c.customerNumber IN (
    SELECT DISTINCT o.customerNumber
    FROM Orders o
    JOIN OrderDetails od ON o.orderNumber = od.orderNumber
    JOIN Products p ON od.productCode = p.productCode
    JOIN ProductLines pl ON p.productLine = pl.productLine
    WHERE pl.productLine = 'Trains'
    UNION
    SELECT DISTINCT o.customerNumber
    FROM Orders o
    JOIN OrderDetails od ON o.orderNumber = od.orderNumber
    JOIN Products p ON od.productCode = p.productCode
    JOIN ProductLines pl ON p.productLine = pl.productLine
    WHERE pl.productLine = 'Trucks and Buses'
)
ORDER BY lastName, Firstname;

-- What product makes us the most money 

Select p.productCode, p.productName, ordercost from products p
Join 
  (Select productCode , Sum(quantityordered * priceeach) as ordercost from orderdetails od
group by productCode ) as subquery on p.productCode = subquery.productCode
order by ordercost
Desc limit 1 ;

-- List the product lines and vendors for product lines which are supported by < 5 vendors

Select productline, productvendor from products
where productline IN
 (Select productline from products 
 group by productLine
  having Count(Distinct productvendor) < 5);

-- Find the first name and last name of all customer contacts whose customer 
-- is located in the same state as the San Francisco office.

Select contactfirstname, contactlastname from customers
where state =
(Select state from offices
 where city = "San Francisco") 
 
 -- What is the name of the customer, the order number, and the total cost of the most expensive order?
 
 Select c.customername, o.ordernumber, totalcost
 from customers c
 Join orders o on c.customernumber = o.customernumber
 Join 
    ( Select od.ordernumber, Sum(od.quantityordered * od.priceeach) as totalcost 
      from orderdetails od 
      group by od.ordernumber
      Order by totalcost 
      Desc Limit 1) as a
      on o.ordernumber = a.ordernumber;
      
      SELECT c.customerName, o.orderNumber, SUM(od.priceEach * od.quantityOrdered) AS TotalCost
FROM Customers c
JOIN Orders o ON c.customerNumber = o.customerNumber
JOIN OrderDetails od ON o.orderNumber = od.orderNumber
GROUP BY c.customerName, o.orderNumber
ORDER BY TotalCost DESC
LIMIT 1;

-- Calculate the total revenue for each product line

with totalrevenue as
( Select p.productline, sum(od.quantityordered * od.priceeach) as totalcost
  from products p
  Join orderdetails od On p.productCode = od.productCode
  GROUP BY p.productLine)
Select productline, totalcost from totalrevenue
order by totalcost DESC;

-- Calculate the average payment amount per customer 

With Averagepayment as
( Select Customernumber, avg(amount) as avg_payment
  from payments
  group by Customernumber
  )
Select Customernumber, avg_payment from Averagepayment
order by avg_payment DESC;

-- Determine the top 3 customers with the highest total payments

SELECT Customernumber, SUM(amount) AS TotalPayments,
		RANK() OVER (ORDER BY SUM(amount) DESC) AS PaymentRank
FROM payments 
GROUP BY customerNumber
Limit 3;


