-- Analysis Started

-- 1. Select all records from the Products table:
SELECT * FROM Products;

-- 2. Filter products by category 'Electronics':
SELECT * FROM Products WHERE category = 'Electronics';

-- 3. Sort products by price in descending order:
SELECT * FROM Products ORDER BY price DESC;

-- 4. Count the number of interactions:
SELECT COUNT(*) AS interaction_count FROM Interactions;

-- 5. Calculate the total purchase amount for each user:
SELECT user_id, SUM(total_amount) AS total_purchase_amount 
FROM Past_Purchases 
GROUP BY user_id;

-- 6. Retrieve the oldest purchase date:
SELECT MIN(purchase_date) AS oldest_purchase FROM Past_Purchases;

-- 7. Join Products and Interactions to get product details with interaction type:
SELECT p.*, i.interaction_type 
FROM Products p
JOIN Interactions i ON p.product_id = i.product_id;

-- 8. Subquery to find products with more than 10 interactions:
SELECT * FROM Products 
WHERE product_id IN (SELECT product_id FROM Interactions GROUP BY product_id HAVING COUNT(*) > 10);

-- Run the inner query separately to verify if it returns the expected counts of interactions per product:

SELECT product_id, COUNT(*) AS interaction_count 
FROM Interactions 
GROUP BY product_id;

-- 9. Update product price for a specific product:
UPDATE Products SET price = 1500 WHERE product_id = 'P001';

-- 10. Delete an interaction record:
DELETE FROM Interactions WHERE interaction_id = 5;

-- 11. Retrieve the top 5 users with the highest total purchase amount:
SELECT user_id, SUM(total_amount) AS total_purchase_amount 
FROM Past_Purchases 
GROUP BY user_id 
ORDER BY total_purchase_amount DESC 
LIMIT 5;

-- 12. Count the number of unique brands in the Products table:
SELECT COUNT(DISTINCT brand) AS unique_brands FROM Products;

-- 13. Window function to rank products by price within each category:
SELECT product_id, product_name, category, price, 
       RANK() OVER (PARTITION BY category ORDER BY price) AS price_rank
FROM Products;

-- 14. Common Table Expression (CTE) to find the average price of products:
WITH AvgPrice AS (
    SELECT AVG(price) AS average_price FROM Products
)
SELECT * FROM Products WHERE price > (SELECT average_price FROM AvgPrice);

-- 14. Create an index on the user_id column of the Past_Purchases table:
CREATE INDEX idx_user_id ON Past_Purchases(user_id);

-- 15. Retrieve the product with the highest total purchase amount:
SELECT product_id, SUM(total_amount) AS total_purchase_amount 
FROM Past_Purchases 
GROUP BY product_id 
ORDER BY total_purchase_amount DESC 
LIMIT 1;

-- 16. Create a view to show interactions with product details:
CREATE VIEW InteractionDetails AS
SELECT i.*, p.product_name, p.category, p.brand 
FROM Interactions i
JOIN Products p ON i.product_id = p.product_id;

-- 17. Rollback a transaction if an error occurs while updating interactions:
START TRANSACTION;
UPDATE Interactions SET interaction_type = 'Click' WHERE interaction_id = 10;
SAVEPOINT before_commit;
UPDATE Interactions SET interaction_type = 'View' WHERE interaction_id = 11;
ROLLBACK TO before_commit;
COMMIT;

-- 18. Count the number of interactions per product
SELECT product_id, COUNT(*) AS interaction_count
FROM Interactions
GROUP BY product_id;

-- 19. List top N most popular products based on interactions
SELECT product_id, COUNT(*) AS interaction_count
FROM Interactions
GROUP BY product_id
ORDER BY interaction_count DESC
LIMIT 3;

-- 20. Retrieve product details along with user interactions:
SELECT p.*, i.interaction_type, i.user_id
FROM Products p
INNER JOIN Interactions i ON p.product_id = i.product_id;

-- 21. Find products with no interactions:
SELECT p.*
FROM Products p
LEFT JOIN Interactions i ON p.product_id = i.product_id
WHERE i.product_id IS NULL;

-- 22. Rank products by price within each category using window functions:
SELECT product_id, product_name, category, price,
       RANK() OVER (PARTITION BY category ORDER BY price) AS price_rank
FROM Products;

-- 24. Calculate the cumulative sum of total purchases by user:
SELECT user_id, purchase_id, total_amount,
       SUM(total_amount) OVER (PARTITION BY user_id ORDER BY purchase_id) AS cumulative_sum
FROM Past_Purchases;

-- 25. Find products purchased more than once:
SELECT * 
FROM Products
WHERE product_id IN (
    SELECT product_id
    FROM Past_Purchases
    GROUP BY product_id
    HAVING COUNT(*) > 1
);

-- 26. Retrieve interactions for products with prices above the average price:
SELECT *
FROM Interactions
WHERE product_id IN (
    SELECT product_id
    FROM Products
    WHERE price > (SELECT AVG(price) FROM Products)
);

-- 27. Create a CTE to calculate average product price by category:
WITH AvgPriceByCategory AS (
    SELECT category, AVG(price) AS avg_price
    FROM Products
    GROUP BY category
)
SELECT p.product_id, p.product_name, p.category, p.price, c.avg_price
FROM Products p
JOIN AvgPriceByCategory c ON p.category = c.category;

-- 28. Use a CTE to find the top 3 users with the highest total purchase amounts:
WITH UserPurchaseTotals AS (
    SELECT user_id, SUM(total_amount) AS total_purchase_amount
    FROM Past_Purchases
    GROUP BY user_id
)
SELECT user_id, total_purchase_amount
FROM UserPurchaseTotals
ORDER BY total_purchase_amount DESC
LIMIT 3;

-- 29. Calculate the percentage contribution of each product to the total sales amount:
WITH ProductSales AS (
    SELECT product_id, SUM(total_amount) AS total_sales
    FROM Past_Purchases
    GROUP BY product_id
)
SELECT p.product_id, p.product_name, p.price, ps.total_sales,
       (ps.total_sales / (SELECT SUM(total_amount) FROM Past_Purchases)) * 100 AS sales_percentage
FROM Products p
JOIN ProductSales ps ON p.product_id = ps.product_id;

-- 30. Identify users who made purchases of more than $500 in a single transaction:
SELECT user_id, purchase_id, total_amount
FROM Past_Purchases
WHERE total_amount > 500;

-- 31. Calculate the average time between consecutive purchases for each user:
WITH UserPurchaseTimes AS (
    SELECT user_id, 
           purchase_date - LAG(purchase_date, 1) OVER (PARTITION BY user_id ORDER BY purchase_date) AS time_diff
    FROM Past_Purchases
)
SELECT user_id, AVG(time_diff) AS avg_time_between_purchases
FROM UserPurchaseTimes
GROUP BY user_id;

-- Above  query uses a window function to calculate the time difference between consecutive purchases for each user. Then, it calculates the average time between purchases for each user.

-- 32. Identify products that have been interacted with but not purchased:
SELECT i.product_id, p.product_name
FROM Interactions i
LEFT JOIN Past_Purchases pp ON i.product_id = pp.product_id
JOIN Products p ON i.product_id = p.product_id
WHERE pp.product_id IS NULL;

-- 33. Find users who made purchases in the first and last quarter of the year:
SELECT user_id
FROM Past_Purchases
WHERE EXTRACT(QUARTER FROM purchase_date) = 1
   OR EXTRACT(QUARTER FROM purchase_date) = 4;

-- 34. Calculate the average quantity of products purchased by users who interacted with products priced above the average price:
WITH InteractedProducts AS (
    SELECT DISTINCT user_id, product_id
    FROM Interactions
),
AvgProductPrice AS (
    SELECT AVG(price) AS avg_price
    FROM Products
)
SELECT ip.user_id, AVG(pp.quantity) AS avg_quantity
FROM InteractedProducts ip
JOIN Products p ON ip.product_id = p.product_id
JOIN Past_Purchases pp ON ip.user_id = pp.user_id AND ip.product_id = pp.product_id
CROSS JOIN AvgProductPrice avgp
WHERE p.price > avgp.avg_price
GROUP BY ip.user_id;

-- 35. Find users who have interacted with products across multiple categories:
SELECT user_id
FROM (
    SELECT user_id, COUNT(DISTINCT category) AS num_categories
    FROM Interactions i
    JOIN Products p ON i.product_id = p.product_id
    GROUP BY user_id
) AS user_categories
WHERE num_categories > 1;
