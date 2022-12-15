create or replace view customer_activity as
	select customer_id, convert(rental_date, date) as activity_date,
	date_format(convert(rental_date,date), "%m") as activity_month,
	date_format(convert(rental_date, date), "%Y") as activity_year
	from rental;
    
select * from user_activity;    
-- 1. Get number of monthly active customers.
create or replace view monthly_active_customers as 
   select activity_year, activity_month, count(distinct customer_id) as active_customers
   from user_activity
   group by activity_year, activity_month
   order by activity_year, activity_month asc;
select * from monthly_active_customers;

-- 2. Active users in the previous month.
create or replace view monthly_and_last_active_customers as 
select 
	activity_year,
	activity_month, 
	active_customers,
	lag(active_customers) over (order by activity_year, activity_month) as last_month
from monthly_active_customers;
select * from monthly_and_last_active_customers;

-- 3. Percentage change in the number of active customers.
select activity_year, activity_month, active_customers,
lag(active_customers) over (order by activity_year, activity_month) as last_month,
(active_customers - last_month / active_customers ) * 100 as Percentage_Change from monthly_and_last_active_customers;

-- 4. Retained customers every month.
create or replace view distinct_customers as
select
	distinct(customer_id) as active_id, 
	activity_year, 
	activity_month
from customer_activity
order by activity_year, activity_month, active_id;
select * from distinct_customers;

create or replace view retained_customers as
select d1.active_id, d1.activity_year, d1.activity_month, d2.activity_month as Previous_month from distinct_customers d1
join distinct_customers d2
on d1.activity_year = d2.activity_year 
and d1.activity_month = d2.activity_month+1 
and d1.active_id = d2.active_id 
order by d1.active_id, d1.activity_year, d1.activity_month;

select * from retained_customers;

create or replace view total_retained_customers as
select activity_year, activity_month, count(active_id) as retained_customers from retained_customers
group by activity_year, activity_month;

select * from total_retained_customers;
