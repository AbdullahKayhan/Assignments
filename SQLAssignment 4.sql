--Generate a report including product IDs and discount effects on whether
--the increase in the discount rate positively impacts the number of orders for the products.


--PART I
---------------------------------------------------------------------------------------------------------
select distinct product_id,discount,
	   count(order_id) over (partition by discount,product_id) order_count
from sale.order_item

--PART II
---------------------------------------------------------------------------------------------------------
with tbl1 as(
select distinct product_id,discount,
	   count(order_id) over (partition by discount,product_id) order_count
from sale.order_item
	  )
	  select product_id, discount, order_count,
	  lag(order_count) over(partition by product_id order by discount) pre_order_count,
	  			CASE
				WHEN order_count >  lag(order_count) over(partition by product_id order by discount) THEN  1
				WHEN order_count <  lag(order_count) over(partition by product_id order by discount) THEN -1
				WHEN order_count = 	lag(order_count) over(partition by product_id order by discount) THEN  0	
				ELSE null
				END Comparing
	  from tbl1


--PART III
---------------------------------------------------------------------------------------------------------
with tbl1 as(
select distinct product_id,discount,
	   count(order_id) over (partition by discount,product_id) order_count
from sale.order_item
	  ),
	  tbl2 as
	  (
	  select product_id, discount, order_count,
	  lag(order_count) over(partition by product_id order by discount) pre_order_count,
	  			CASE
				WHEN order_count >  lag(order_count) over(partition by product_id order by discount) THEN  1
				WHEN order_count <  lag(order_count) over(partition by product_id order by discount) THEN -1
				WHEN order_count = 	lag(order_count) over(partition by product_id order by discount) THEN  0	
				ELSE null
				END Comparing
	  from tbl1
	  )
	  select  product_id,Comparing, sum(Comparing) over(partition by product_id ) sum_of_compare,
	  	  		CASE
				WHEN sum(Comparing) over(partition by product_id )=0 THEN  'Neutral'
				WHEN sum(Comparing) over(partition by product_id )>0 THEN  'Positive'
				WHEN sum(Comparing) over(partition by product_id )<0 THEN  'Negative'
				ELSE null
				END Final_Comparing
	  from  tbl2

	  
--FINAL PART
with tbl1 as(
select distinct product_id,discount,
	   count(order_id) over (partition by discount,product_id) order_count
from sale.order_item
	  ),
	  tbl2 as
	  (
	  select product_id, discount, order_count,
	  lag(order_count) over(partition by product_id order by discount) pre_order_count,
	  			CASE
				WHEN order_count >  lag(order_count) over(partition by product_id order by discount) THEN  1
				WHEN order_count <  lag(order_count) over(partition by product_id order by discount) THEN -1
				WHEN order_count = 	lag(order_count) over(partition by product_id order by discount) THEN  0	
				ELSE null
				END Comparing
	  from tbl1
	  ),
	  tbl3 as
	  (
	  select  product_id,
	  	  		CASE
				WHEN sum(Comparing) over(partition by product_id )=0 THEN  'Neutral'
				WHEN sum(Comparing) over(partition by product_id )>0 THEN  'Positive'
				WHEN sum(Comparing) over(partition by product_id )<0 THEN  'Negative'
				ELSE null
				END Final_Comparing
	  from  tbl2
	  )
	  select distinct A.product_id, (ISNULL (CONVERT (VARCHAR(20), B.Final_Comparing), 'Insufficient data')) Discount_Effect
	  from 	  product.product A	  	  
	  LEFT JOIN tbl3 B on A.product_id=B.product_id
	  order by product_id