-- 	CREATING DATABASE:

    CREATE DATABASE IF NOT EXISTS salesdatawalmart;
    
-- CREATING TABLE:

   CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);
 
 
 -- ------------------------------------------------------------------------------------------------------------------------------------
 -- ----------------------------------------- FEATURE ENGINEERING ----------------------------------------------------------------------
 -- ------------------------------------------------------------------------------------------------------------------------------------
 
-- ADDING THE time_of_day COLUMN:
SELECT 
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);


-- ADDING THE day_name COLUMN:
SELECT
	date,
	DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);


-- ADDING THE month_name COLUMN:
SELECT
	date,
	MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- -----------------------------------------------------------------------------
-- ---------------------------- GENERIC QUESTIONS ------------------------------
-- -----------------------------------------------------------------------------

-- How many unique cities does the data have?
SELECT 
	DISTINCT city
FROM sales;
-- THE DATA HAS 3 UNIQUE CITIES


-- In which city is each branch?
SELECT 
	DISTINCT city,
    branch
FROM sales;
-- BRANCH 'A' IS IN YANGON, BRANCH 'C' IS IN NAYPYITAW, BRANCH 'B' IS IN MANDALAY

-- -----------------------------------------------------------------------------------
-- -------------------------------- PRODUCT ------------------------------------------
-- -----------------------------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT
	count(DISTINCT product_line)
FROM sales;
-- DATA HAS 6 UNIQUE PRODUCT LINES


-- What is the most common payment method?
SELECT
	payment,
	COUNT(payment) AS cnt
FROM sales
GROUP BY payment
ORDER BY cnt DESC;
-- CASH IS THE MOST COMMON PAYMENT METHOD


-- What is the most selling product line?
SELECT
	product_line,
	COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;
-- FASHION ACCESSORIES IS THE MOST SELLING PRODUCT LINE


-- What is the total revenue by month?
SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month_name 
ORDER BY total_revenue DESC;


-- What month had the largest COGS?
SELECT
	month_name AS month,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month_name 
ORDER BY cogs DESC;
-- JANUARY HAS THE LARGEST COGS


-- What product line had the largest revenue?
SELECT
	product_line,
	SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;
-- FOOD AND BEVAERAGE GENERATES THE LARGEST REVENUE


-- What is the city with the largest revenue?
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch 
ORDER BY total_revenue DESC;
-- NAYPYITAW GENERATES THE LARGEST REVENUE


-- What product line had the largest VAT?
SELECT
	product_line,
	AVG(tax_pct) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;
-- HOME AND LIFESTYLE HAS THE LARGEST VAT


-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales?
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;
-- AVERAGE SALE IS 5.4995
SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 5.4995 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;


-- Which branch sold more products than average product sold?
SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);
-- BRANCH 'A' 


-- What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;
-- FOR FEMALE FASHION ACCESSORIES IS THE MOST COMMON PRODUCT LINE AND 
-- FOR MEN HEALTH AND BEAUTY IS THE MOST COMMON PRODUCT LINE


-- What is the average rating of each product line?
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;
-- FOOD AND BEVERAGES HAS THE HIGHEST AVERAGE RATING AMONG ALL PRODUCT LINES



-- --------------------------------------------------------------------
-- ---------------------------- SALES ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday?
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- EVENINGS EXPERIENCE MOST SALES, THE STORES ARE FILLED DURING THE EVENING HOURS


-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;
-- THERE IS NOT MUCH DIFFERENCE BUT MEMBERS BRINGS THE MOST REVENUE


-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;
-- NAYPYITAW HAS THE LARGEST VAT PERCENT


-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax DESC;
-- MEMBERS PAYS THE MOST IN VAT



-- --------------------------------------------------------------------
-- -------------------------- CUSTOMERS -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;
-- DATA HAS ONLY 2 UNIQUE CUSTOMER TYPES


-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM sales;
-- DATA HAS 3 UNIQUE PAYMENT METHODS


-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;
-- THERE IS NOT MUCH DIFFERENCE, BUT MEMBER IS THE MOST COMMON TYPE


-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*) AS purchases
FROM sales
GROUP BY customer_type
ORDER BY purchases DESC;
-- AGAIN NOT MUCH DIFFERENCE BUT MEMBER BUYS THE MOST


-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;
-- WITH JUST 1 CUSTOMER DIFFERENCE MALE'S ARE THE MOST


-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;


-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- LOOKS LIKE TIME OF THE DAY DOES NOT REALLY AFFECT THE RATING
-- ITS MORE OR LESS THE SAME RATING EACH TIME OF THE DAY


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- BRANCH 'A' AND 'C' ARE DOING WELL IN RATINGS
-- BRANCH 'B' NEEDS TO DO A LITTLE MORE TO GET BETTER RATINGS


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- MON,TUE AND FRIDAY ARE THE TOP BEST DAYS FOR GOOD RATINGS


-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;
-- TUESDAY AND SATURDAY HAS THE BEST AVERAGE RATINGS PER BRANCH



-- --------------------------------------------------------------------
-- --------------------------------------------------------------------