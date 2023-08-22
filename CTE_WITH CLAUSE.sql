use alex;
select * from employees;


-- Fetch all employees names who earn more than average salary of all employees

with average_salary(avg_sal) as
	(select AVG(salary) from employees)

select *
from  employees e, average_salary av
where e.salary > av.avg_sal;


 -- Creating employees table
CREATE TABLE sales(
    store_id int,
    store_name varchar (50),
    product varchar (50),
    quantity int,
    cost int
);
INSERT INTO sales 
values  (1,'Apple Originals 1','iPhone 12 Pro',1,1000),
        (1,'Apple Originals 1','MacBook pro 13',3,2000),
        (1,'Apple Originals 1','AirPods Pro',2,280),
        (2,'Apple Originals 2','iPhone 12 Pro',2,1000),
        (3,'Apple Originals 3','iPhone 12 Pro',1,1000),
        (3,'Apple Originals 3','MacBook pro 13',1,2000),
		(3,'Apple Originals 3','MacBook Air',4,1100),
		(3,'Apple Originals 3','iPhone 12 Pro',2,1000),
		(3,'Apple Originals 3','AirPods Pro',3,280),
		(4,'Apple Originals 4','iPhone 12 Pro',2,1000),
		(4,'Apple Originals 4','MacBook pro 13',1,2500);	


select * from sales;

-- Find stores who's sales where better than the average sales across all stores.

1) Total sales per each store -- Total_sales


select s.store_id, sum(cost) as total_sales_per_store
from sales s
group by store_id;


2) Find the average sales with respect to all the stores


select AVG(total_sales_per_store)
from (select s.store_id, sum(cost) as total_sales_per_store
from sales s
group by store_id)x;

3) Find the stores where the Total_sales > Avg_Sales of all stores


-- Subqueries

select *
from (select s.store_id, sum(cost) as total_sales_per_store
		from sales s
		group by store_id) total_sales
join (select AVG(total_sales_per_store) as avg_sales_for_all_stores
		from (select s.store_id, sum(cost) as total_sales_per_store
				from sales s
				group by store_id) x) avg_sales
	on total_sales.total_sales_per_store > avg_sales.avg_sales_for_all_stores;


-- WITH clause
with Total_Sales(store_id, total_sales_per_store) as
		(select s.store_id, sum(cost) as total_sales_per_store
			from sales s
			group by store_id),
	avg_sales(avg_sales_per_store) as
		(select AVG(total_sales_per_store)as avg_sales_per_store
			from Total_Sales)

select * 
from Total_Sales ts
join avg_sales av
on ts.total_sales_per_store > av.avg_sales_per_store;
