


--E-Commerce Project Solution

SELECT * FROM [dbo].[cust_dimen];
SELECT * FROM [dbo].[market_fact];
SELECT * FROM [dbo].[orders_dimen];
SELECT * FROM [dbo].[prod_dimen];
SELECT * FROM [dbo].[prod_dimen];
update shipping_dimen
set Ship_id= REPLACE(Ship_id,'SHP_','')
SELECT * FROM [dbo].[shipping_dimen];

--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)
SELECT *
--INTO
--Combined_table
FROM
	(select M.Ord_id,M.Prod_id,M.Sales,M.Discount,M.Order_Quantity,M.Product_Base_Margin,
	C.Cust_id,C.Customer_Name,C.Province,C.Region,C.Customer_Segment,
	O.Order_Date,O.Order_Priority,
	P.Product_Category,P.Product_Sub_Category,
	S.Ship_Date,S.Ship_id,S.Ship_Mode
	from market_fact M
	inner join cust_dimen C on C.Cust_id=M.Cust_id
	inner join orders_dimen O on O.Ord_id = M.Ord_id 
	inner join prod_dimen P on P.Prod_id = M.Prod_id
	inner join shipping_dimen S on S.Ship_id = M.Ship_id
	) A;



--///////////////////////


--2. Find the top 3 customers who have the maximum count of orders.

select top (3) Cust_id,Count( distinct Ord_id)cnt_order
from Combined_table
group by cust_id
order by cnt_order desc;



--/////////////////////////////////



--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.

Alter table combined_table
add DaysTakenForDelivery INT;

select Order_date,Ship_Date, DATEDIFF(day,Order_date,Ship_date) 
from Combined_table


Update Combined_table
Set DaysTakenForDelivery= DATEDIFF(day, Order_Date,Ship_Date)

select*
from Combined_table


--////////////////////////////////////

--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"
select top (1)cust_id,Customer_Name,DaysTakenForDelivery,Order_Date,Ship_Date

from Combined_table
where DaysTakenForDelivery =(
							select max(DaysTakenForDelivery)
							from Combined_table
							);


select Cust_id,Customer_name,Order_date,Ship_date,DaysTakenForDelivery
from Combined_table 
Where DaysTakenForDelivery In (
								select max (DaysTakenForDelivery)
								from Combined_table
								);
						
--////////////////////////////////

--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
--You can use such date functions and subqueries

select Count(distinct cust_id) Total_customers
from combined_table
where Year(order_date)= 2011
and  Month(order_date)=1

--////////////////////////////////////////////
select distinct Month(order_date)[Month],Count(distinct cust_id)Month_Total_Customers
from Combined_table A
where 
	Exists
			(
			SELECT  Cust_id
			FROM	combined_table B
			where	YEAR(Order_Date) = 2011
			AND		MONTH (Order_Date) = 1
			AND		A.Cust_id = B.Cust_id
			)
AND	YEAR (Order_Date) = 2011
GROUP BY
MONTH(order_date)

--6. write a query to return for each user the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions

SELECT DISTINCT 
		cust_id,order_date,dense_number,FIRST_ORDER_DATE,
		DATEDIFF(day, FIRST_ORDER_DATE, order_date) Time_Elapsed
FROM	
		(
		SELECT	Cust_id, ord_id, order_DATE,
				MIN (Order_Date) OVER (PARTITION BY cust_id) FIRST_ORDER_DATE,
				DENSE_RANK () OVER (PARTITION BY cust_id ORDER BY Order_date) dense_number
		FROM	combined_table
		) A
WHERE	dense_number = 3
order by cust_id

--//////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by the customer.
--Use CASE Expression, CTE, CAST AND such Aggregate Functions
SELECT *
FROM combined_table

WITH T1 AS
(
SELECT	distinct Cust_id,
		SUM (CASE WHEN Prod_id = 'Prod_11' THEN Order_Quantity ELSE 0 END) P11,
		SUM (CASE WHEN Prod_id = 'Prod_14' THEN Order_Quantity ELSE 0 END) P14,
		SUM (Order_Quantity) TOTAL_PROD
FROM	combined_table
GROUP BY Cust_id
HAVING
		SUM (CASE WHEN Prod_id = 'Prod_11' THEN Order_Quantity ELSE 0 END) >= 1 AND
		SUM (CASE WHEN Prod_id = 'Prod_14' THEN Order_Quantity ELSE 0 END) >= 1
)
SELECT	Cust_id, P11, P14, TOTAL_PROD,
		CAST (1.0*P11/TOTAL_PROD AS NUMERIC (3,2)) AS RATIO_P11,
		CAST (1.0*P14/TOTAL_PROD AS NUMERIC (3,2)) AS RATIO_P14
FROM T1
order by TOTAL_PROD

--/////////////////

--CUSTOMER RETENTION ANALYSIS

--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.

CREATE VIEW customer_of_logs AS

SELECT	cust_id,
		YEAR (ORDER_DATE) [YEAR],
		MONTH (ORDER_DATE) [MONTH]
FROM	combined_table

ORDER BY 1,2,3 desc


--//////////////////////////////////


--2. Create a view that keeps the number of monthly visits by users. (Separately for all months from the business beginning)
--Don't forget to call up columns you might need later.

CREATE VIEW monthly_of_visits AS

SELECT	Cust_id, [YEAR], [MONTH], COUNT(*) NUM_OF_LOG
FROM	customer_logs
GROUP BY Cust_id, [YEAR], [MONTH]


--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can number the months with "DENSE_RANK" function.
--then create a new column for each month showing the next month using the numbering you have made. (use "LEAD" function.)
--Don't forget to call up columns you might need later.

CREATE VIEW NEXT_of_VISIT AS 
SELECT *,
		LEAD(CURRENT_MONTH ) OVER (PARTITION BY Cust_id ORDER BY CURRENT_MONTH) NEXT_VISIT_MONTH
FROM 
(
SELECT  *,
		DENSE_RANK () OVER (ORDER BY [YEAR] , [MONTH]) CURRENT_MONTH
		
FROM	monthly_of_visits
) A

--/////////////////////////////////

--4. Calculate the monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.

CREATE VIEW time_gaps AS

SELECT *,
		NEXT_VISIT_MONTH - CURRENT_MONTH time_gaps
FROM	NEXT_of_VISIT

--/////////////////////////////////////////
--5.Categorise customers using time gaps. Choose the most fitted labeling model for you.
--  For example: 
--	Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
--	Labeled as regular if the customer has made a purchase every month.
--  Etc.
SELECT * FROM time_gaps
where Cust_id = 'Cust_873'


SELECT cust_id, avg_time_gap,
		CASE WHEN avg_time_gap = 1 THEN 'retained' 
			WHEN avg_time_gap > 1 THEN 'irregular'
			WHEN avg_time_gap IS NULL THEN 'Churn'
			ELSE 'UNKNOWN DATA' END CUST_LABELS
FROM
		(
		SELECT Cust_id, AVG(time_gaps) avg_time_gap
		FROM	time_gaps
		GROUP BY Cust_id
		) A

--/////////////////////////////////////

--MONTH-WÝSE RETENTÝON RATE


--Find month-by-month customer retention rate  since the start of the business.


--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps

SELECT	DISTINCT cust_id, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		NEXT_VISIT_MONTH,
		time_gaps,
		COUNT (cust_id)	OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTITON_MONTH_WISE
FROM	time_gaps
where	time_gaps =1
ORDER BY cust_id, YEAR,MONTH

--//////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Total Number of Customers in The Previous Month / Number of Customers Retained in The Next Nonth

--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.

--You should pay attention to the join type and join columns between your views or tables.

CREATE VIEW CURRENT_NUM_OF_CUST AS

SELECT	DISTINCT cust_id, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		COUNT (cust_id)	OVER (PARTITION BY CURRENT_MONTH) CURR_CUST
FROM	time_gaps


SELECT *
FROM	CURRENT_NUM_OF_CUST

---
CREATE VIEW NEXT_NUM_OF_CUST AS

SELECT	DISTINCT cust_id, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		NEXT_VISIT_MONTH,
		COUNT (cust_id)	OVER (PARTITION BY Current_Month) NEXT_CUST
FROM	time_gaps
WHERE	time_gaps = 1
AND		CURRENT_MONTH > 1



SELECT DISTINCT
		B.[YEAR],
		B.[MONTH],
		B.CURRENT_MONTH,
		1.0 * B.NEXT_CUST / A.CURR_CUST RETENTION_RATE
FROM	CURRENT_NUM_OF_CUST A LEFT JOIN NEXT_NUM_OF_CUST B
ON		A.CURRENT_MONTH + 1 = B.NEXT_VISIT_MONTH



---///////////////////////////////////
--Teþekkür ederiz güzel bir çalýþmaydý. 