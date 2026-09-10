create database olist;
use olist;

CREATE TABLE customers (
    customer_id            VARCHAR(32) PRIMARY KEY,
    customer_unique_id      VARCHAR(32) NOT NULL,
    customer_zip_prefix     VARCHAR(10),
    customer_city           VARCHAR(100),
    customer_state          VARCHAR(2)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive (1)/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
select * from customers;


CREATE TABLE sellers (
    seller_id               VARCHAR(32) PRIMARY KEY,
    seller_zip_prefix       VARCHAR(10),
    seller_city             VARCHAR(100),
    seller_state            VARCHAR(2)
);
DESCRIBE sellers;
SELECT * FROM sellers LIMIT 5;
SELECT COUNT(*) FROM sellers;
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive (1)/olist_sellers_dataset.csv'
into table sellers
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from sellers ;



CREATE TABLE category_translation (
    product_category_name          VARCHAR(100) PRIMARY KEY,
    product_category_name_english  VARCHAR(100)
);
load data infile 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive (1)/product_category_name_translation.csv'
into table category_translation
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
select * from category_translation ;

drop table if exists products;
CREATE TABLE products (
    product_id              VARCHAR(32) PRIMARY KEY,
    product_category_name    VARCHAR(100) REFERENCES category_translation(product_category_name),
    product_weight_g         decimal(10.2),
    product_length_cm       decimal(10.2),
    product_height_cm        decimal(10.2),
    product_width_cm         decimal(10.2),
     product_name_lenght	decimal(10.2),
	product_description_lenght decimal(10.2),
	product_photos_qty decimal(10.2)
	);
select * from products ;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive (1)/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    product_id,
    product_category_name,
    @product_name_lenght,
    @product_description_lenght,
    @product_photos_qty,
    @product_weight_g,
    @product_length_cm,
    @product_height_cm,
    @product_width_cm
)
SET
product_name_lenght = NULLIF(@product_name_lenght,''),
product_description_lenght = NULLIF(@product_description_lenght,''),
product_photos_qty = NULLIF(@product_photos_qty,''),
product_weight_g = NULLIF(@product_weight_g,''),
product_length_cm = NULLIF(@product_length_cm,''),
product_height_cm = NULLIF(@product_height_cm,''),
product_width_cm = NULLIF(@product_width_cm,'');


CREATE TABLE orders (
    order_id                        VARCHAR(32) PRIMARY KEY,
    customer_id                     VARCHAR(32) REFERENCES customers(customer_id),
    order_status                    VARCHAR(20),
    order_purchase_timestamp        TIMESTAMP,
    order_approved_at               TIMESTAMP,
    order_delivered_carrier_date    TIMESTAMP,
    order_delivered_customer_date   TIMESTAMP,
    order_estimated_delivery_date   TIMESTAMP
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive (1)/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    order_id,
    customer_id,
    order_status,
    @order_purchase_timestamp,
    @order_approved_at,
    @order_delivered_carrier_date,
    @order_delivered_customer_date,
    @order_estimated_delivery_date
)
SET
order_purchase_timestamp =
    STR_TO_DATE(@order_purchase_timestamp, '%d-%m-%Y %H:%i'),

order_approved_at =
    STR_TO_DATE(NULLIF(@order_approved_at, ''), '%d-%m-%Y %H:%i'),

order_delivered_carrier_date =
    STR_TO_DATE(NULLIF(@order_delivered_carrier_date, ''), '%d-%m-%Y %H:%i'),

order_delivered_customer_date =
    STR_TO_DATE(NULLIF(@order_delivered_customer_date, ''), '%d-%m-%Y %H:%i'),

order_estimated_delivery_date =
    STR_TO_DATE(@order_estimated_delivery_date, '%d-%m-%Y %H:%i');




CREATE TABLE order_items (
    order_id            VARCHAR(32) REFERENCES orders(order_id),
    order_item_id        INT,
    product_id           VARCHAR(32) REFERENCES products(product_id),
    seller_id            VARCHAR(32) REFERENCES sellers(seller_id),
    shipping_limit_date   TIMESTAMP,
    price                 NUMERIC(10,2),
    freight_value         NUMERIC(10,2),
    PRIMARY KEY (order_id, order_item_id)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive (1)/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
order_id,
order_item_id,
product_id,
seller_id,
@shipping_limit_date,
price,
freight_value)
SET
   shipping_limit_date =
    STR_TO_DATE(NULLIF(@shipping_limit_date,''), '%d-%m-%Y %H:%i');



CREATE TABLE order_payments (
    order_id             VARCHAR(32) REFERENCES orders(order_id),
    payment_sequential    INT,
    payment_type          VARCHAR(20),
    payment_installments  INT,
    payment_value         NUMERIC(10,2),
    PRIMARY KEY (order_id, payment_sequential)
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive (1)/olist_order_payments_dataset.csv'
INTO TABLE order_payments 
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DROP TABLE  order_reviews;
CREATE TABLE order_reviews (
    review_id                  VARCHAR(32) ,
    order_id                   VARCHAR(32) REFERENCES orders(order_id),
    review_score               INT,
    review_comment_title       VARCHAR(255),
    review_comment_message     TEXT,
    review_creation_date        TIMESTAMP,
    review_answer_timestamp    TIMESTAMP
);
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/archive (1)/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    @review_creation_date,
    @review_answer_timestamp
)
SET
    review_creation_date =
        STR_TO_DATE(NULLIF(@review_creation_date, ''), '%d-%m-%Y %H:%i'),

    review_answer_timestamp =
        STR_TO_DATE(NULLIF(@review_answer_timestamp, ''), '%d-%m-%Y %H:%i');
        SELECT COUNT(*) FROM order_reviews;
select review_id, count(*)
from order_reviews
group by review_id
having count(*)>1;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT review_id) AS unique_review_ids
FROM order_reviews;