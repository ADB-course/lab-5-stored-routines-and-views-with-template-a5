-- (i) A Procedure called PROC_LAB5
-- Step 1: Create the Procedure (PROC_LAB5)
-- This procedure retrieves the top customers by order frequency and total amount spent in a given date range.
DELIMITER //
CREATE PROCEDURE PROC_LAB5(IN startDate DATE, IN endDate DATE, IN topN INT)
BEGIN
    SELECT c.customerID, c.customerName, COUNT(o.orderID) AS orderCount, 
           SUM(o.orderTotal) AS totalSpent
    FROM customers c
    JOIN orders o ON c.customerID = o.customerID
    WHERE o.orderDate BETWEEN startDate AND endDate
    GROUP BY c.customerID, c.customerName
    ORDER BY totalSpent DESC, orderCount DESC
    LIMIT topN;
END //
DELIMITER ;

-- Step 2: Create the Function (FUNC_LAB5)
-- This function calculates a "loyalty score" for a customer based on order frequency and total amount spent.
DELIMITER //
CREATE FUNCTION FUNC_LAB5(customerID INT) RETURNS DECIMAL(5, 2)
BEGIN
    DECLARE loyaltyScore DECIMAL(5, 2);
    DECLARE orderCount INT;
    DECLARE totalSpent DECIMAL(10, 2);
    
    -- Get total order count and spending for the customer
    SELECT COUNT(orderID), SUM(orderTotal) INTO orderCount, totalSpent
    FROM orders
    WHERE customerID = customerID;

    -- Calculate loyalty score: each order gives 10 points, and each $100 spent gives 1 point
    SET loyaltyScore = (orderCount * 10) + (totalSpent / 100);

    RETURN IFNULL(loyaltyScore, 0);  -- Return 0 if the customer has no orders
END //
DELIMITER ;

-- Step 3: Create the View (VIEW_LAB5)
-- This view shows recent high-value orders (over $500), with customer details, order info, and loyalty scores.
CREATE VIEW VIEW_LAB5 AS
SELECT c.customerID, c.customerName, o.orderID, o.orderDate, o.orderTotal,
       FUNC_LAB5(c.customerID) AS loyaltyScore,
       RANK() OVER (ORDER BY o.orderTotal DESC) AS spendingRank
FROM customers c
JOIN orders o ON c.customerID = o.customerID
WHERE o.orderDate >= CURDATE() - INTERVAL 90 DAY AND o.orderTotal > 500
ORDER BY o.orderDate DESC, o.orderTotal DESC;

-- Notes:
-- 1. The procedure `PROC_LAB5` retrieves the top N customers based on order frequency and spending within a date range.
-- 2. The function `FUNC_LAB5` calculates a loyalty score that weights order frequency and total spending.
-- 3. The view `VIEW_LAB5` shows high-value recent orders, including loyalty scores and a ranking of spending.



