DROP TABLE IF EXISTS geolocation, customers, orders, order_payments, order_reviews, products, sellers, order_items;


CREATE TABLE IF NOT EXISTS geolocation (
	geolocation_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	geolocation_zip_code_prefix VARCHAR(5) NOT NULL,
	geolocation_lat NUMERIC(10, 8),
	geolocation_lng NUMERIC(11, 8),
	geolocation_city VARCHAR(100),
	geolocation_state CHAR(2)
);

CREATE TABLE IF NOT EXISTS customers (
	customer_id VARCHAR(32) PRIMARY KEY,
	customer_unique_id VARCHAR(32) NOT NULL,
	customer_zip_code_prefix VARCHAR(5) NOT NULL,
	customer_city VARCHAR(100) NOT NULL,
	customer_state CHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(32) PRIMARY KEY,
    order_customer_id VARCHAR(32) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_purchase_timestamp TIMESTAMP NOT NULL,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP NOT NULL,
	FOREIGN KEY (order_customer_id) REFERENCES customers(customer_id)
	
);

CREATE TABLE IF NOT EXISTS order_payments (
	payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    payment_order_id VARCHAR(32) NOT NULL,
    payment_sequential INTEGER NOT NULL,
    payment_type VARCHAR(30) NOT NULL,
    payment_installments INTEGER NOT NULL,
    payment_value NUMERIC(10, 2) NOT NULL,
	FOREIGN KEY (payment_order_id) REFERENCES orders(order_id)
);

CREATE TABLE IF NOT EXISTS order_reviews (
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    review_id VARCHAR(32) NOT NULL,
    order_id VARCHAR(32) NOT NULL,
    review_score INTEGER NOT NULL,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP NOT NULL,
    review_answer_timestamp TIMESTAMP NOT NULL,
	FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE IF NOT EXISTS products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(5) NOT NULL,
    seller_city VARCHAR(100) NOT NULL,
    seller_state CHAR(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS order_items (
	order_item_id INTEGER NOT NULL,
	order_id VARCHAR(32) NOT NULL,
	product_id VARCHAR(32) NOT NULL,
	seller_id VARCHAR(32) NOT NULL,
	shipping_limit_date TIMESTAMP NOT NULL,
	price NUMERIC(10, 2) NOT NULL,
	freight_value NUMERIC(10, 2) NOT NULL,
	FOREIGN KEY (order_id) REFERENCES orders(order_id),
	FOREIGN KEY (product_id) REFERENCES products(product_id),
	FOREIGN KEY (seller_id) REFERENCES sellers(seller_id),
	PRIMARY KEY (order_item_id, order_id)
);














