CREATE TABLE #E_Commerce 
(
    Visitor_id INT,
    Adv_Type VARCHAR(1),
    [Action] VARCHAR(10)
);

INSERT INTO #E_Commerce
VALUES
    (1, 'A', 'Left'), 
	(2, 'A', 'Order'), 
	(3, 'B', 'Left'), 
	(4, 'A', 'Order'), 
	(5, 'A', 'Review'), 
	(6, 'A', 'Left'), 
	(7, 'B', 'Left'), 
	(8, 'B', 'Order'),
	(9, 'B', 'Review'),
	(10, 'A', 'Review');


-- retrieve count of left, orders, and reviewss for each Adv_type:
 
WITH table1 AS 
(
SELECT Adv_Type, 
sum(CASE WHEN [Action] = 'Left' THEN 1 ELSE 0 END) AS Lefts, 
sum(CASE WHEN [Action] = 'Order' THEN 1 ELSE 0 END) AS Orders, 
sum(CASE WHEN [Action] = 'Review' THEN 1 ELSE 0 END) AS Reviews
FROM #E_Commerce
GROUP BY Adv_Type
)



-- Calculate Orders (Conversion) rates for each Advertisement Type by dividing by total count of actions casting as float by multiplying by 1.0.
SELECT [Adv_Type],  1.0 * Orders/(Lefts+Orders+Reviews) AS Conversion_Rate
FROM table1