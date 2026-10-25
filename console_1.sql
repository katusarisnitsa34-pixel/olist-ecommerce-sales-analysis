

select p.product_category_name ,p.product_id, sum(price)  as TotalRevenue,sum(freight_value)
    as FreightCost, sum(price-freight_value) as RevenueAfterFreight from olist_order_items as oi
join olist_products as p  on p.product_id=oi.product_id
group by oi.product_id, p.product_category_name order by TotalRevenue desc limit 5;





