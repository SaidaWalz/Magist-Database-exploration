-- business questions:
use magist;
-- 2.1. In relation to the products:
-- What categories of tech products does Magist have?
select count(product_category_name_english),
case
when product_category_name_english in ('audio', 'electronics', 'computers_accessories', 'computers',  'pc_gamer', 'telephony') then 'tech'
when product_category_name_english not in ('audio', 'electronics', 'computers_accessories', 'computers',  'pc_gamer', 'telephony') then  'non tech'
end as tech
from product_category_name_translation group by tech;
 #where product_category_name_english in ('audio', 'electronics', 'computers_accessories', 'computers',  'pc_gamer', 'telephony');
-- How many products of these tech categories have been sold (within the time window of the database snapshot)?

select count(product_id) from order_items join products using (product_id) left join product_category_name_translation using (product_category_name) where product_category_name_english in ('audio','electronics', 'computers_accessories', 'computers',  'pc_gamer', 'telephony');
#15715
#select order_item_id from order_items;
-- What percentage does that represent from the overall number of products sold?
select count(product_id) from order_items;
#112650

#(17116/15715)*100 so about 15 percent tech products are sold vs all sold products



-- What’s the average price of the products being sold?


select avg(price) from order_items
 join products using (product_id) 
 left join product_category_name_translation using (product_category_name)
 where product_category_name_english in ('audio',  'electronics', 'computers_accessories', 'computers',  'pc_gamer', 'telephony');

#110.3

-- Are expensive tech products popular? *
#count(product_id), price  
select count(product_id),  case
when price > 1000 then 'expensive'
when price > 500 then 'midrange'
else 'cheap'
end as 'price_range'
from order_items
left join products using (product_id) 
left join product_category_name_translation using (product_category_name) 
where product_category_name_english in ('audio', 'electronics', 'computers_accessories', 'computers',  'pc_gamer', 'telephony') group by price_range;


-- 2.2. In relation to the sellers:
-- How many months of data are included in the magist database?
select TIMESTAMPDIFF(month, min(order_purchase_timestamp), max(order_purchase_timestamp)) from orders;
-- its 25 months 

-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
select count(seller_id) from sellers;
#3095

select count( distinct seller_id) from sellers
 left join order_items using(seller_id) left join products using (product_id)
 left join product_category_name_translation using (product_category_name)
 where product_category_name_english in ('audio', 'electronics', 'computers_accessories', 'computers',  'pc_gamer', 'telephony');
#486




#100 percent

select distinct order_status from orders;

-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?


select sum(payment_value) from order_payments 
join orders using(order_id)
where order_status not in ('canceled', 'unavailable')  ; #join orders;
#15739137.029585503

#16008872.139586091
select sum(payment_value) from order_payments 
left join orders using(order_id)
left join order_items using(order_id) 
left join products using (product_id)
join product_category_name_translation using (product_category_name)
where product_category_name_english in ('audio', 'electronics', 'computers_accessories', 'computers',  'pc_gamer', 'telephony')
and order_status not in ('canceled', 'unavailable')  ; #join orders;;
#2646506.6664336827

-- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?
select distinct order_status from orders;
-- for all sellers it is: 15739137.029585503/25= 629565.48118342012
-- for tech sellers it is: #2646506.6664336827/25=105860.266657347308



#select avg(payment_value), seller_id, month(order_purchase_timestamp), year(order_purchase_timestamp) from order_payments
#left join order_items using(order_id)
#left join products using (product_id)
#left join sellers using(seller_id)
#left join orders using (order_id)
#group by seller_id, month(order_purchase_timestamp), year(order_purchase_timestamp) having order_status not in ('canceled', 'unavailable') ;



#select * from order_payments;
#select avg(payment_value), seller_id from order_payments left join order_items using(order_id) left join products using (product_id) join sellers using(seller_id) join product_category_name_translation where product_category_name_english in ('audio', 'consoles_games', 'electronics', 'computers_accessories', 'computers',  'pc_gamer', 'telephony', 'fixed_telephony') group by seller_id;
#'162465078.90748727'


-- 2.3. In relation to the delivery time:





-- What’s the average time between the order being placed and the product being delivered?

select avg(datediff(order_delivered_customer_date, order_delivered_carrier_date)) from orders;


-- How many orders are delivered on time vs orders delivered with a delay?

#9.3138
-- das habe ich falsch verstanden, ich muss die differenz zwischen estimated time und delivery time checken!!!


select count(datediff(order_estimated_delivery_date,order_delivered_customer_date)),
case
 when datediff(order_estimated_delivery_date, order_delivered_carrier_date) < 3 then  'in time'
 when datediff(order_estimated_delivery_date, order_delivered_carrier_date) between 3 and 7 then 'delayed'
 else 'very delayed'
 end as delay
from orders group by delay;


select datediff(order_delivered_customer_date, order_delivered_carrier_date),
case
 when datediff(order_delivered_customer_date, order_delivered_carrier_date) < 9.5 then  'in time'
 when datediff(order_delivered_customer_date, order_delivered_carrier_date) >10 then 'delayed'
 end
 from orders ;
-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
select datediff(order_delivered_customer_date, order_delivered_carrier_date), avg(product_weight_g), 
case
 when datediff(order_delivered_customer_date, order_delivered_carrier_date) < 9.5 and avg(product_weight_g) < 2276.7489 then 'light in time'
 when datediff(order_delivered_customer_date, order_delivered_carrier_date) < 9.5 and avg(product_weight_g) > 2276.7489 then 'heavy in time'
 when datediff(order_delivered_customer_date, order_delivered_carrier_date) >= 9.5 and avg(product_weight_g) < 2276.7489 then 'light and delayed'
 when datediff(order_delivered_customer_date, order_delivered_carrier_date) >=9.5 and avg(product_weight_g)> 2276.7489 then 'heavy and delayed'
 end as order_weight
 from orders 
 join order_items using(order_id)
 join products using (product_id)
 #where order_delivered_customer_date is not null
 group by order_id,order_delivered_customer_date, order_delivered_carrier_date;


select avg(product_weight_g) from products;
#2276.7489




SELECT 
    -- 1. Create categories based on Volume (Length * Width * Height)
    CASE 
        WHEN (p.product_length_cm * p.product_height_cm * p.product_width_cm) < 5000 THEN 'Small (<5k cm³)'  -- ex: shoebox
        WHEN (p.product_length_cm * p.product_height_cm * p.product_width_cm) BETWEEN 5000 AND 30000 THEN 'Medium (5k-30k cm³)' -- ex: microwave
        WHEN (p.product_length_cm * p.product_height_cm * p.product_width_cm) > 30000 THEN 'Large (>30k cm³)' -- large appliances
        ELSE 'Unknown'
    END AS size_class,

    -- 2. Total items
    COUNT(*) AS total_items_delivered,

    -- 3. Delayed items
    SUM(CASE 
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 
        ELSE 0 
    END) AS delayed_items,

    -- 4. Calculate percentage
    FORMAT(
        (SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1 ELSE 0 END) / COUNT(*)) * 100, 
        2
    ) AS percentage_delayed

FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY size_class
order by size_class

#bei postcodes gucken, da sollte ein pattern drin liegen!! und guck bei geo, wie weit sind carrier und empfänger entfernt!

