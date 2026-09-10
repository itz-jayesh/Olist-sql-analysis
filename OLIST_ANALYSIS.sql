use olist;
show tables;

-- Q1. Ops wants a distinct list of every state we currently ship customers to. Deliverable: one column, no duplicates. Difficulty: 2/10
	select * from customers;
    select distinct(customer_state) from customers;
    
-- Q2. Customer support wants to see the 10 most recently placed orders, regardless of status, for a spot-check. 
-- Deliverable: order_id, customer_id, order_status, purchase timestamp — most recent first. Difficulty: 2/10
	select * from orders;
    select order_id, customer_id, order_status, order_purchase_timestamp 
    from orders
    order by  order_purchase_timestamp desc
    limit 10;

-- Q3. The catalog team wants to know how many distinct product categories currently exist. Deliverable: a single number. Difficulty: 2/10
	select count(distinct(product_category_name)) as product_categories_count from category_translation ;
    
-- Q4. Finance is auditing "boleto" (a common Brazilian payment slip) transactions and wants every payment row using that method. 
-- Deliverable: full payment rows filtered to that method. Difficulty: 3/10
	select * from order_payments
    where payment_type ='boleto';
    
-- Q5. Finance wants total revenue (sum of payment value) broken down by payment type, 
-- to understand which methods drive the most money through the platform. Deliverable: payment_type, total_revenue, sorted highest to lowest. Difficulty: 3/10
select * from order_payments ;
select payment_type,sum(payment_value) as total_revenue
from order_payments
group by payment_type
order by total_revenue;

-- Q6. Ops wants a month-by-month count of orders placed during 2017 to spot seasonality. Deliverable: month, order_count. Difficulty: 4/10
 select * from orders;
 
 select monthname(order_purchase_timestamp) as monthsof_2017,count(order_id)
 from orders
 where year(order_purchase_timestamp) = 2017
 group by monthname(order_purchase_timestamp),month(order_purchase_timestamp)
 order by month(order_purchase_timestamp);

-- when to use only one year use "monthname() & where"
--  when to use multiple years use dateformat(column,year_month) 
-- DONT USE AND OR & while using group by 


-- Q7. The category manager wants average product price by category, but only for categories that have meaningful volume 
-- — at least 30 order-items. Deliverable: category, avg_price, filtered to the volume threshold. Difficulty: 5/10

select * from ccategory_translationategory_translation;
select * from products;
describe products;
select * from order_items;

select p.product_category_name as Product_Category ,avg(o.price) as avg_price 
from products p
join order_items o
 on p.product_id = o.product_id
group by p.product_category_name;

-- Q8. CX wants every delivered order labeled as "Early," "On Time," or "Late" by comparing the actual delivery date to the 
-- estimated delivery date. Deliverable: order_id, delivery status label. Difficulty: 5/10
select * from orders;
select count(*)from orders
where  order_delivered_customer_date is null;
select order_id ,
case 
	when order_delivered_customer_date < order_estimated_delivery_date then 'Early'
    	when order_delivered_customer_date = order_estimated_delivery_date then 'On_time'
        	when order_delivered_customer_date > order_estimated_delivery_date then 'Late'
            else 'Not_delivred'
END as Delivery_Status
from orders;


-- Level 3 — Joins

-- Q9. Marketing wants a single report showing each order alongside the customer's state and the order's current status, for a regional campaign. 
-- Deliverable: order_id, customer_state, order_status. Difficulty: 5/10
	select * from customers;
    select * from orders;
    select  o.order_id,c.customer_state,o.order_status
    from customers c join orders o 
    on c.customer_id = o.customer_id;
    
    
-- Q10. Ops suspects some sellers are onboarded but have never fulfilled a single delivered order, and wants them flagged for review — 
-- this needs to include sellers with zero delivered orders, not just low counts. Deliverable: seller_id, delivered_order_count (including zero). Difficulty: 6/10
select * from sellers;
select * from order_items;
select * from orders;
select distinct order_status from orders;

select s.seller_id, 
		count(distinct 
		case
		when o.order_status= 'delivered'
		then o.order_id
        -- diff order id can have multiple items thats why we counting order id where status is delivered 
        end ) AS Order_count
from orders o join order_items i
on o.order_id = i.order_id
join sellers s on s.seller_id = i.seller_id
group by s.seller_id
having Order_count = 0;


-- Q11. Finance wants each order's total payment value shown next to which payment type(s) were used to settle it. 
-- Deliverable: order_id, payment_type, payment_value. Difficulty: 5/10
select * from order_items;
select * from order_payments;

select i.order_id,p.payment_type,sum(p.payment_value) as total_value 
from order_items i 
join order_payments p
on i.order_id = p.order_id
group by i.order_id,p.payment_type;

select distinct(order_id), payment_type,sum(payment_value)
from order_payments
group by order_id,payment_type;

-- Q12. Category managers are tired of reading Portuguese category codes and want every order-item matched to its English category name. 
-- Deliverable: order_item detail with product_category_name_english. Difficulty: 4/10
select * from category_translation ;
select * from order_items;
select * from products;
SELECT
    p.*,
    t.product_category_name_english
FROM products p
LEFT JOIN category_translation t
    ON p.product_category_name = t.product_category_name;


-- Level 4 — Subqueries & CTEs

-- Q13. Ops wants every order whose total payment value is above the platform-wide average payment value, 
-- to understand what a "high value" order looks like. Deliverable: order_id, order_total, filtered against the computed average.
-- Difficulty: 6/10 

With total_avg as(
select order_id, sum(payment_value) as Order_total
from order_payments
group by order_id
)
select * from total_avg 
where Order_total >(select avg(Order_total) from total_avg);

-- Q14. Customer success wants to identify genuine repeat customers — people who've placed more than one delivered order — 
-- since cancelled/undeslivered orders shouldn't count toward loyalty. Deliverable: customer_unique_id, delivered_order_count (>1 only). Difficulty: 7/10

with temp as (
select * from orders 
where order_status= 'delivered'
)
select c.customer_unique_id, count(t.order_status) as total_orders
from temp t
join customers c
on c.customer_id = t.customer_id
group by customer_unique_id
having total_orders>1;


-- Q15. Category management wants to know which product categories are underperforming on customer satisfaction — 
-- specifically, categories whose average rseview score sits below the platform-wide average review score. 
-- Deliverable: category, avg_review_score, below the global benchmark. Difficulty: 7/10


WITH temp AS (
    SELECT
        i.order_id,
        p.product_category_name
    FROM order_items i
    JOIN products p
        ON i.product_id = p.product_id
),

category_scores AS (
    SELECT
        t.product_category_name,
        AVG(r.review_score) AS avg_review_score
    FROM temp t
    JOIN order_reviews r
        ON t.order_id = r.order_id
    GROUP BY t.product_category_name
),

global_score AS (
    SELECT AVG(review_score) AS global_avg
    FROM order_reviews
)

SELECT
    c.product_category_name AS category,
    c.avg_review_score,
    CASE
        WHEN c.avg_review_score < g.global_avg
            THEN 'Below Average'
        ELSE 'At or Above Average'
    END AS performance
FROM category_scores c
CROSS JOIN global_score g;



-- Q16. Finance wants a state-by-state revenue breakdown that also shows what percentage of total company 
-- revenue each state contributes — built as a clean, reusable CTE rather than a nested subquery. 
-- Deliverable: states, state_revenue, pct_of_total_revenue. Difficulty: 7/10-
select sum(price) as total from order_items ;
-- 13591643.70
select s.seller_state as state , sum(o.price) 
from sellers s
join order_items o
on s.seller_id = o.seller_id
group by state;

with revenue as
(
select seller_state as state , sum(price) as state_revenue
from sellers s
join order_items o
on s.seller_id = o.seller_id
group by state
) 
select * ,(state_revenue/  13591643.70)*100 as pct_of_total_revenue
from revenue;

-- Level 5 — Window Functions & Senior Analyst Business Analysis

/*Q17. The CEO wants to know, for every state, which single product category generates 
the most revenue there — a "state's #1 category" leaderboard, not a full ranked list.
 Deliverable: one row per state — top category and its revenue. Difficulty: 8/10*/
 
with state_wise_sales as (
select s.seller_state as state, o.product_id,sum(o.price) as revenue
from sellers s
join order_items o
on s.seller_id = o.seller_id
group by 
    state,
    o.product_id
),
p_category as(
select r.state,sum(r.revenue) as revenue,p.product_category_name
from products p
join state_wise_sales r
on p.product_id = r.product_id
group by
		 r.state,
         p.product_category_name
),
final as (
SELECT 
    state,
    product_category_name AS product_category,
    revenue,
    ROW_NUMBER() OVER (
        PARTITION BY state 
        ORDER BY revenue DESC
    ) AS ranking
FROM p_category		)
select * from final
where ranking = 1;


/*Q18. Ops wants a running (cumulative) total of daily revenue across the full dataset 
so leadership can watch cumulative performance trend on a dashboard. 
Deliverable: date, daily_revenue, running_total. Difficulty: 8/10*/

-- 
with temp as(
select date(o.order_purchase_timestamp) as date, sum(i.price) as daily_revenue
from orders o 
join order_items i
on o.order_id = i.order_id
group by date
)
select *,
		sum(daily_revenue) over(order by date ) as revenue
 from temp;

/*Q19. The retention team wants each customer's orders ranked chronologically so we can separate 
"first order" from "repeat orders," and ultimately measure the average number of days between a 
customer's first and second order.
 Deliverable: per-customer order rank, plus the average gap metric. Difficulty: 9/10 */

/*
Q19. Retention analysis:
1. Rank each customer's orders chronologically.
2. Identify each customer's first and second order.
3. Calculate the days between those orders.
4. Calculate the average gap across customers.
*/

WITH ranked_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,

        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp
        ) AS order_rank

    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
),

customer_orders AS (
    SELECT
        customer_unique_id,
        order_id,
        order_purchase_timestamp,
        order_rank,

        MAX(
            CASE
                WHEN order_rank = 1
                THEN order_purchase_timestamp
            END
        ) OVER (
            PARTITION BY customer_unique_id
        ) AS first_order,

        MAX(
            CASE
                WHEN order_rank = 2
                THEN order_purchase_timestamp
            END
        ) OVER (
            PARTITION BY customer_unique_id
        ) AS second_order

    FROM ranked_orders
),

final AS (
    SELECT
        customer_unique_id,
        order_id,
        order_purchase_timestamp,
        order_rank,
        first_order,
        second_order,

        DATEDIFF(
            second_order,
            first_order
        ) AS days_between_first_second

    FROM customer_orders
)

SELECT
    customer_unique_id,
    order_id,
    order_purchase_timestamp,
    order_rank,
    days_between_first_second
FROM final
ORDER BY
    customer_unique_id,
    order_rank;

/*Q20. The growth team wants month-over-month revenue growth expressed as a percentage,
 comparing every month's revenue to the prior month's.
 Deliverable: month, revenue, mom_growth_pct. Difficulty: 9/10*/
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        SUM(i.price) AS revenue
    FROM orders o
    JOIN order_items i
        ON o.order_id = i.order_id
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
),

monthly_with_previous AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY month
        ) AS previous_month_revenue
    FROM monthly_revenue
)

SELECT
    month,
    revenue,
    ROUND(
        (revenue - previous_month_revenue)
        * 100
        / previous_month_revenue,
        2
    ) AS mom_growth_pct
FROM monthly_with_previous
ORDER BY month;










