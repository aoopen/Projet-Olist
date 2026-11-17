\copy geolocation(geolocation_zip_code_prefix,geolocation_lat,geolocation_lng,geolocation_city,geolocation_state) FROM 'C:\path\to\file\olist_geolocation_dataset.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy customers FROM 'C:\path\to\file\olist_customers_dataset.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy orders FROM 'C:\path\to\file\olist_orders_dataset.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy order_payments(payment_order_id, payment_sequential, payment_type, payment_installments, payment_value) FROM 'C:\path\to\file\olist_order_payments_dataset.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy order_reviews(review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp) FROM 'C:\path\to\file\olist_order_reviews_dataset.csv' WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8');

\copy products FROM 'C:\path\to\file\olist_products_dataset.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy sellers FROM 'C:\path\to\file\olist_sellers_dataset.csv' WITH (FORMAT CSV, HEADER TRUE);

\copy order_items(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value) FROM 'C:\path\to\file\olist_order_items_dataset.csv' WITH (FORMAT CSV, HEADER TRUE);