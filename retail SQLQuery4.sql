USE master;

sp_rename 'retail_Sales.sales_date date','sales_date'

alter table retail_sales
alter column sales_date date;

alter table retail_sales
alter column sale_time time(00);

--this shows limit that we can select how many rows we needed 
select top 10 * from retail_Sales                                   
---------------------------------data exploration-----------------------------------------------
--i'm counting the number of rows(total  number of rows in a table)(how many sales we have)
select count(*)  as count from retail_Sales

----checking how many customers we have (by using count and distinct)no duplicates unique customer will come
select count(distinct(customer_id)) as total_sales from retail_sales 

---how many category we have in the table
select count(distinct(category)) as total_sales from retail_sales 

---what are the category we have in the table
select distinct(category) as total_sales from retail_sales 


--this shows limit that we can select how many rows we needed 
select top 10 * from retail_Sales


----------------------------------data cleaning-----------------------------------

--dealing with null values (we are looking for null values which is present in table)
select * from retail_Sales
where TRANSACTIONs_ID is null or
sales_date is null
or
sale_time is null
or customer_id is null
or gender is null
or age is null
or category is null
or quantiy is null
or price_per_unit is null
or cogs is null
or total_sale is null

--deleting the null values (because we dont the values for the null)

delete from retail_Sales
where TRANSACTIONs_ID is null or
sales_date is null
or
sale_time is null
or customer_id is null
or gender is null
or age is null
or category is null
or quantiy is null
or price_per_unit is null
or cogs is null
or total_sale is null

-----business key problem (data analysis)

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

select * from retail_Sales              
where sales_date like '2022-11-05'
order by sale_time asc


/*Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and
the quantity sold is more than 10 in the month of Nov-2022*/

select category,
quantiy,
sales_date
from retail_sales
where sales_date between '2022-11-01' and '2022-11-30'
and category = 'clothing'
and quantiy =4

group by category ,sales_date,quantiy
order by sales_date



-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

select sum(total_Sale) as total_sales,category
from retail_sales
group by category


---Q.4 Write a SQL query to calculate the total sales (total_sale) and total orders for each category 

select sum(total_Sale) as total_sales,
category,
count(*) as total_orders
from retail_sales
group by category



-- Q.5 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

select round(avg(age),2) as avg_ages,category
from retail_sales
where category = 'beauty'
group by category



-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.


select * from retail_sales
where total_sale >1000	



-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

select count(transactions_id) as count_id,gender,category
from retail_Sales
group by gender,category
order by category 

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

select * from(select  year(sales_date) as year_sale,
month(sales_date) as month_Sale,
avg(total_Sale) as avg_sale,
sum(total_sale) as total_Sale,
rank() over (partition by year(sales_date)order by sum(total_Sale)desc) as rank_sale
from retail_Sales
group by year(sales_date),month(sales_date)
--ORDER BY year(sales_date) ASC,AVG(total_sale) asc
) as t2
where rank_sale = 1



-- Q.8 Write a SQL query to calculate the average sale for each month and total sales of that month. Find out best selling month in each year

SELECT 
    YEAR(sales_date) AS year,
    MONTH(sales_date) AS month,
    AVG(total_sale) AS avg_sale,
    SUM(total_sale) AS total_sales,
    RANK() OVER (PARTITION BY YEAR(sales_date) ORDER BY SUM(total_sale) DESC) AS sales_rank
FROM retail_sales
GROUP BY YEAR(sales_date), MONTH(sales_date)
ORDER BY year ASC,AVG(total_sale) asc

-- Q.9 Write a SQL query to find the top 5 customers based on the highest total sales 

select top 5 customer_id,
sum(total_sale)
from retail_sales
group by customer_id
order by sum(total_sale)desc

-- Q.10 Write a SQL query to find the number of unique customers who purchased items from each category.


select category,count(distinct (customer_id)) as unique_customers
from retail_sales
group by category




-- Q.11 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)


WITH hourly_sale AS (
    SELECT *,
        CASE 
            WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
            WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shifts
    FROM retail_sales
)
SELECT shifts ,COUNT(*)
FROM hourly_sale
GROUP BY shifts



--Q.12 Write a SQL query to find the total revenue and total quantity sold for each product category in the year 2022.



select sum(total_Sale) as total_revenue,
sum(quantiy) as quantity,category ,
count(total_sale) as count_no

from retail_sales
where year(sales_date) = 2022
group by category
order by total_revenue desc

--Q.13 Write a SQL query to find the top 3 product categories that generated the highest revenue in 2022.

select top 3 sum(total_sale)as top_3_cat, category
from retail_Sales
where year(sales_date) = 2022
group by category
order by top_3_cat desc

--Q.14 Write a SQL query to calculate the total number of transactions made in each month of 2022.(order by highest number of total transactions_id)



select month(sales_date) as month_total , 
sum(transactions_id) as total_transc
from retail_sales 
where year(sales_date) =2022
group by month(sales_date)
order by total_transc desc

--Q.15 Write a SQL query to retrieve all sales transactions where the cogs (cost of goods sold) is greater than total_sale

select * from retail_Sales 
where cogs >total_sale
order by  cogs

--Q.16 Write a SQL query to find the average total sale amount per transaction for each product category.

select round(avg(total_sale),2) as avg_sales,category
from retail_sales
group by category

--Q.17 Write a SQL query to determine the most common age group of customers who purchased items from the 'Electronics' category.

with age_group
as 
(select
case
when age between 13 and 22 then 'teens'
when age between 23 and 40 then 'adults'
when age between 41 and 65 then 'ultra_adults'
else 'old'
end as age_group
from retail_sales
where category = 'electronics'
)

select age_group, count(*) as customers
from age_group
group by age_group
------------------------------we can also do without using case or ctc expression by using union clase
SELECT COUNT(*) AS customer_count, 'teens' AS age_group
FROM retail_sales
WHERE age BETWEEN 13 AND 22 AND category = 'electronics'

UNION

SELECT COUNT(*) AS customer_count, 'adults' AS age_group
FROM retail_sales
WHERE age BETWEEN 23 AND 40 AND category = 'electronics'

UNION

SELECT COUNT(*) AS customer_count, 'ultra_adults' AS age_group
FROM retail_sales
WHERE age BETWEEN 41 AND 100 AND category = 'electronics';


--Q.18 Write a SQL query to calculate the total profit (total_sale - cogs) generated for each category in 2022.


select category,sum(total_sale-cogs) as total_profit
from retail_sales
where year(sales_date) = 2022
group by category
order by total_profit desc

--Q.19 Write a SQL query to find the total number of transactions made in the morning, afternoon, and evening shifts.

with shifts
as
(
select 
case
when datepart(hour,sale_time)<12 then 'morning'
when datepart(hour,sale_time)between 12 and 17 then 'afternoon'
else 'evening'
end as shifts
from retail_sales
)
select count(*) as total_transc,shifts
from shifts
group by shifts
order by  total_transc desc

----------------------------------we can also use subquery to do this------------------------

SELECT shifts, 
       COUNT(*) AS total_transactions
FROM (
    SELECT transactions_id, 
           CASE 
               WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning'
               WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
               ELSE 'Evening'
           END AS shifts
    FROM retail_sales
) AS shift_data
GROUP BY shifts
ORDER BY total_transactions DESC;

--Q.20 Write a SQL query to identify the month and which year with the lowest total sales in the dataset.

select top 1
			
			month(sales_date) as month_total,
			sum(total_sale) as lowest_sales,
			year(sales_date) as year_total
from  retail_sales
group by year(sales_date), month(sales_date)
order by lowest_sales asc

--Q.21 Write a SQL query to find the customer who made the highest number of purchases and display their total sales.

select * from retail_Sales


select  top 1 customer_id ,sum(total_Sale) as highest_sale
from retail_sales
group by customer_id
order by highest_Sale desc


--Q.22 Write a SQL query to find the customer who made the highest number of purchases and display their total transaction count.

SELECT TOP 1 customer_id, 
       COUNT(transactions_id) AS total_purchases
FROM retail_sales
GROUP BY customer_id
ORDER BY total_purchases DESC;


