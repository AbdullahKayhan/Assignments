SELECT Top(10) A.product_name, A.product_id --Product-product A,sale.order_item B,sale.orders C,sale.customer D oldu. Product_id no'larý bulduk.
FROM     product.product A INNER JOIN
                  sale.order_item B ON A.product_id = B.product_id INNER JOIN
                  sale.orders C ON B.order_id = C.order_id INNER JOIN
                  sale.customer D ON C.customer_id = D.customer_id
WHERE  (A.product_name like '%2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD')
or(A.product_name like '%Polk Audio - 50 W Woofer - Black%')
or(A.product_name like 'Virtually Invisible 891 In-Wall Speakers (Pair)')
or(A.product_name like '%SB-2000 12 500W Subwoofer%')
--Ýsim,soyisim,1.2.3. ürün listelerini bulduk. 
select E.customer_id, E.first_name, E.last_name
	,ISNULL(NULLIF (ISNULL(STR(F.customer_id), 'No'), STR(F.customer_id)), 'Yes') First_product
	,ISNULL(NULLIF (ISNULL(STR(G.customer_id), 'No'), STR(G.customer_id)), 'Yes') Second_product
	,ISNULL(NULLIF (ISNULL(STR(H.customer_id), 'No'), STR(H.customer_id)), 'Yes') Third_product
FROM
			(
			SELECT        sale.customer.first_name, sale.customer.last_name, product.product.product_name, sale.customer.customer_id
			FROM            sale.customer INNER JOIN
									 sale.orders ON sale.customer.customer_id = sale.orders.customer_id AND sale.customer.customer_id = sale.orders.customer_id LEFT OUTER JOIN
									 product.product RIGHT OUTER JOIN
									 sale.order_item ON product.product.product_id = sale.order_item.product_id ON sale.orders.order_id = sale.order_item.order_id
			WHERE        (product.product.product_id = 6)
			) E  --Önce 6,13,16,21 no'lu ürünü satýn alanlarý bulduk.
	LEFT JOIN
			(
			SELECT        sale.customer.first_name, sale.customer.last_name, product.product.product_name, sale.customer.customer_id
			FROM            sale.customer INNER JOIN
									 sale.orders ON sale.customer.customer_id = sale.orders.customer_id AND sale.customer.customer_id = sale.orders.customer_id LEFT OUTER JOIN
									 product.product RIGHT OUTER JOIN
									 sale.order_item ON product.product.product_id = sale.order_item.product_id ON sale.orders.order_id = sale.order_item.order_id
			WHERE        (product.product.product_id = 13)
			) F ON E.customer_id = F.customer_id --
	LEFT JOIN
						(
			SELECT        sale.customer.first_name, sale.customer.last_name, product.product.product_name, sale.customer.customer_id
			FROM            sale.customer INNER JOIN
									 sale.orders ON sale.customer.customer_id = sale.orders.customer_id AND sale.customer.customer_id = sale.orders.customer_id LEFT OUTER JOIN
									 product.product RIGHT OUTER JOIN
									 sale.order_item ON product.product.product_id = sale.order_item.product_id ON sale.orders.order_id = sale.order_item.order_id
			WHERE        (product.product.product_id = 21)
			) G ON E.customer_id = G.customer_id
	LEFT JOIN
		(
			SELECT        sale.customer.first_name, sale.customer.last_name, product.product.product_name, sale.customer.customer_id
			FROM            sale.customer INNER JOIN
									 sale.orders ON sale.customer.customer_id = sale.orders.customer_id AND sale.customer.customer_id = sale.orders.customer_id LEFT OUTER JOIN
									 product.product RIGHT OUTER JOIN
									 sale.order_item ON product.product.product_id = sale.order_item.product_id ON sale.orders.order_id = sale.order_item.order_id
			WHERE        (product.product.product_id = 16)
		) H ON E.customer_id = H.customer_id