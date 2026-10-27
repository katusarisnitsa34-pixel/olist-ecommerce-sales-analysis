--总销售量
select count(*) as TotalOrders
from olist_orders;

-- 销售额最高地区
select p.product_category_name ,p.product_id, sum(price)  as TotalRevenue,sum(freight_value)
    as FreightCost, sum(price-freight_value) as RevenueAfterFreight from olist_order_items as oi
join olist_products as p  on p.product_id=oi.product_id
group by oi.product_id, p.product_category_name order by TotalRevenue desc limit 5;

-- 销售量最高的产品
select p.product_category_name ,p.product_id, sum(price) as TotalRevenue,sum(freight_value)
as FreightCost, sum(price-freight_value) as RevenueAfterFreight from olist_order_items as oi
join olist_products as p on p.product_id=oi.product_id
group by oi.product_id, p.product_category_name order by TotalRevenue desc limit 1;

-- 订单发货延迟频次
select count(olist_orders.order_id) as Total_orders,
       sum(case when order_delivered_customer_date > olist_orders.order_estimated_delivery_date
then 1 else 0 end) as delayed_orders,
    concat(round(sum(case when order_delivered_customer_date > order_estimated_delivery_date then 1 else 0 end)*100
                     /count(*),2),'%') as percentage_of_delayed_delivery
from olist_orders
where order_status = 'delivered'
and order_delivered_customer_date is not null
and order_estimated_delivery_date is not null;

--最常用的支付方法
select payment_type, count(*) as total
from olist_order_payments
group by payment_type
order by total desc
limit 1;

--哪些月份的销售量特别高或特别低？
select substr(order_purchase_timestamp,7,4) || '-' || substr(order_purchase_timestamp,4,2) as month,
count(order_id) AS the_best_selling_month
from olist_orders
where order_status = 'delivered'
group by month
order by month desc limit 1;

select substr(order_purchase_timestamp,7,4) || '-' || substr(order_purchase_timestamp,4,2) as month,
  count(order_id) as the_month_with_the_fewest_orders
from olist_orders
where order_status = 'delivered'
group by month
order by month asc limit 1;

--计算营收环比上月变化
with monthly_sales as (
  select
    substr(order_purchase_timestamp,7,4) || '-' || substr(order_purchase_timestamp,4,2) as month,
    sum(oi.price) as revenue
  from olist_orders o
  join olist_order_items oi on o.order_id = oi.order_id
  group by substr(order_purchase_timestamp,7,4) || '-' || substr(order_purchase_timestamp,4,2)
)
select
  month,
  round(revenue, 2) AS revenue,
  round(lag(revenue) over (order by month), 2) as previous_month_revenue,
  concat(round(100 * (revenue - lag(revenue) over (order by month)) / nullif(lag(revenue) over (order by month), 0), 2),'%') as revenue_change_pct
from monthly_sales
order by month;







