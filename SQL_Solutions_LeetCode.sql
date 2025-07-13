/*Easy*/
/*Leet code 50 sql challenge*/

/*Write a solution to find the ids of products that are both low fat and recyclable.
Return the result table in any order.
The result format is in the following example.*/
select distinct product_id from products
where low_fats='Y' and recyclable='Y'

/*Find the names of the customer that are not referred by the customer with id = 2.
Return the result table in any order.
The result format is in the following example.*/
SELECT name FROM Customer
where isnull(referee_id,'')<>2

/*A country is big if:
it has an area of at least three million (i.e., 3000000 km2), or
it has a population of at least twenty-five million (i.e., 25000000).
Write a solution to find the name, population, and area of the big countries.
Return the result table in any order.*/

select name, population,area from world
where (
    area>=3000000 OR
    population>=25000000
)
/*Write a solution to find all the authors that viewed at least one of their own articles.
Return the result table sorted by id in ascending order.*/
select distinct author_id as id from views
where author_id=viewer_id
order by 1
/*Write a solution to find the IDs of the invalid tweets. The tweet is invalid if the number of characters
 used in the content of the tweet is strictly greater than 15.
Return the result table in any order.*/
select tweet_id from tweets
where len(content)>15	
/*Write a solution to show the unique ID of each user, If a user does not have a unique ID replace just show null.
Return the result table in any order.*/
select en.unique_id,e.name from employees e 
left join employeeuni en
on e.id=en.id
/*Medium*/
/*Write a solution to find managers with at least five direct reports.
Return the result table in any order.*/
; with group_mid as
(
SELECT managerId FROM Employee
where managerid is not null
group by managerId
having count(distinct id)>=5
)
select e.name from group_mid g inner join employee e
on g.managerId=e.id
/*The confirmation rate of a user is the number of 'confirmed' messages divided by the total number of requested confirmation messages. 
The confirmation rate of a user that did not request any confirmation messages is 0. Round the confirmation rate to two decimal places.
Write a solution to find the confirmation rate of each user.
Return the result table in any order.*/
/* Write your T-SQL query statement below */
;with tot_count as
(
select s.user_id,COUNT(c.action)as total_counts
from signups s
left join confirmations c
    on s.user_id=c.user_id
group by s.user_id
)
, conf_count as
(
select s.user_id,COUNT(c.action)as total_counts_cf
from signups s
join confirmations c
    on s.user_id=c.user_id
where action='confirmed'
group by s.user_id
)
select distinct t.user_id,
cast(cast(isnull(total_counts_cf,0)as decimal(4,3))/
cast((case when total_counts=0 then 1 else total_counts end)as decimal(4,3))as decimal(4,2))
as confirmation_rate
from tot_count t
left join conf_count c
on t.user_id=c.user_id
order by 2 

/*Write a solution to report the product_name, year, and price for each sale_id in the Sales table.*/
select p.product_name, s.year,s.price from sales s 
inner join product p
    on s.product_id=p.product_id
	
/*Write a solution to find the IDs of the users who visited without making any transactions and the number of times they made these types of visits.*/
select v.customer_id,count(isnull(t.transaction_id,1))as count_no_trans
 from visits v 
left join transactions t
    on v.visit_id=t.visit_id
where t.transaction_id is null
group by v.customer_id

/*Write a solution to find all dates' Id with higher temperatures compared to its previous dates (yesterday).

Return the result table in any order.*/
/* Write your T-SQL query statement below */
select id from (
select Lag(temperature, 1) OVER( ORDER BY recorddate ASC) AS lag_temp,
Lag(recorddate, 1) OVER( ORDER BY recorddate ASC) AS lag_recdate,
* from weather
)r
where r.lag_temp is not null
and lag_temp-temperature<0
and DATEDIFF(day, recorddate,lag_recdate)=-1

/*There is a factory website that has several machines each running the same number of processes. 
Write a solution to find the average time each machine takes to complete a process.
The time to complete a process is the 'end' timestamp minus the 'start' timestamp. 
The average time is calculated by the total time to complete every process on the machine divided by the number of processes that were run.
The resulting table should have the machine_id along with the average time as processing_time, which should be rounded to 3 decimal places.*/
;with start_activity as
(
select * from activity
where activity_type='start'
),
end_activity as 
(
select * from activity
where activity_type='end'
), proc_time as
(
select s.machine_id,s.process_id,(e.timestamp-s.timestamp) as process_time
from start_activity s
inner join end_activity e
    on s.machine_id=e.machine_id
    and s.process_id=e.process_id
)
select machine_id, CAST(SUM(process_time)/COUNT(process_id) AS DECIMAL(5,3))AS processing_time
FROM proc_time
GROUP BY machine_id

/*Write a solution to report the name and bonus amount of each employee with a bonus less than 1000.
Return the result table in any order.*/
select  e.name,b.bonus from employee e
left join bonus b
    on e.empid=b.empid
where isnull(b.bonus,0)<1000
/*Write a solution to find the number of times each student attended each exam.
Return the result table ordered by student_id and subject_name.*/
select distinct s.student_id,s.student_name,s.subject_name,
COUNT(e.subject_name)over (partition by s.student_id,e.subject_name order by s.student_id)
as attended_exams
from (select * from students  cross join subjects ) s
left join subjects su
    on su.subject_name=s.subject_name
left join examinations e
    on s.student_id=e.student_id
    and e.subject_name=s.subject_name

/*Not boring Cinemas*/
select * from cinema
where id%2<>0
and description<>'boring'
order by rating desc

/*Write a solution to find the average selling price for each product. average_price should be rounded to 2 decimal places.*/

;with base as
(
select p.product_id,
case when u.purchase_date between p.start_date and p.end_date
    then (p.price*u.units)
else 0
end as Average_price
from prices p 
left join unitssold u
    on p.product_id=u.product_id
), avg_p as
(
select b.product_id,sum(Average_price) as Average_price
from base b 
group by b.product_id
)
select a.product_id, 
isnull(cast(cast(a.Average_price as decimal(10,2))/
cast(u.sum_units as decimal(10,2)) as decimal(10,2)),0)as Average_price
from avg_p a left join 
(select product_id, sum(units)as sum_units from UnitsSold
group by product_id)u
    on a.product_id=u.product_id
/*Write an SQL query that reports the average experience years of all the employees for each project, rounded to 2 digits.*/	
select p.project_id,
cast(cast(sum(isnull(e.experience_years,''))as decimal(10,2))/
cast(count(isnull(e.employee_id,'')) as decimal(10,2))as decimal(10,2)) as average_years
from project p left join employee e
    on p.employee_id=e.employee_id
group by p.project_id


/*Write a solution to find the percentage of the users registered in each contest rounded to two decimals.
Return the result table ordered by percentage in descending order. In case of a tie, order it by contest_id in ascending order.*/

select r.contest_id,cast((cast(count(distinct r.user_id) as decimal(5,2))
/cast(u1.tot_users as decimal(5,2))*100)as decimal(5,2)) as percentage
from users u
inner join register r
    on u.user_id=r.user_id
cross join (select count(user_id)as tot_users from users) u1
group by r.contest_id,u1.tot_users
order by 2 desc,1 asc

/*We define query quality as:
The average of the ratio between query rating and its position.
We also define poor query percentage as:
The percentage of all queries with rating less than 3.
Write a solution to find each query_name, the quality and poor_query_percentage.
Both quality and poor_query_percentage should be rounded to 2 decimal places.
Return the result table in any order*/

select query_name,
CAST(SUM(CAST(rating AS DECIMAL(5,2))/CAST(position AS DECIMAL(5,2)))
/cast(count(result) as decimal(5,2))AS DECIMAL(5,2)) as Quality,
CAST(CAST(sum(case when rating<3 then 1 else 0 end)as decimal(5,2))
/CAST(count(result)as decimal(5,2))*100 AS DECIMAL(5,2)) AS poor_query_percentage
from queries
where query_name is not null
group by query_name

/*Write an SQL query to find for each month and country, the number of transactions and their total amount, 
the number of approved transactions and their total amount.
Return the result table in any order.*/

select left(trans_date,7) as month,country,count(id) as Trans_Count,
SUM(case when [state]='approved' then 1 else 0 end)as approved_count,
SUM(AMOUNT)AS trans_total_amount, 
SUM(case when [state]='approved' then AMOUNT else 0 end) as approved_total_amount
from transactions
group by left(trans_date,7),country

/*If the customer's preferred delivery date is the same as the order date, then the order is called immediate; otherwise, it is called scheduled.
The first order of a customer is the order with the earliest order date that the customer made. It is guaranteed that a customer has precisely one first order.
Write a solution to find the percentage of immediate orders in the first orders of all customers, rounded to 2 decimal places.*/

; with Delivery1 as
(
select rank()over(partition by customer_id order by order_date asc)as rw,*
from Delivery
), scheduled_order as
(
select sum(case when order_date= customer_pref_delivery_date
    then 1 else 0 end)as Scheduled_order_count
from Delivery1 
where rw=1
), result as
(
select cast(cast(Scheduled_order_count as decimal(5,2))/
cast(d.Customer_count as decimal(5,2))as decimal(5,2))*100 as immediate_percentage
from scheduled_order 
cross join (select count(distinct customer_id)as Customer_count from Delivery) d
)
select cast(cast(Scheduled_order_count as decimal(5,2))/
cast(d.Customer_count as decimal(5,2)) *100 as decimal(5,2)) as immediate_percentage
from scheduled_order 
cross join (select count(distinct customer_id)as Customer_count from Delivery) d


/*Write a solution to report the fraction of players that logged in again on the day after the day they first logged in, rounded to 2 decimal places. 
In other words, you need to count the number of players that logged in for at least two consecutive days starting from their first login date, 
then divide that number by the total number of players.*/

; with initial_login as
(
select row_number()over(partition by player_id order by event_date)as rw,* 
from activity
), count_players as
(
select count(i.player_id) as count_player_id from
(select * from initial_login 
where rw=1)as i 
inner join (select * from initial_login 
where rw=2)as i1 
on i.player_id=i1.player_id
where i1.event_date=dateadd(dd,1,i.event_date)
)
select cast(cast(count_player_id as decimal(5,2))/
cast(count_player_id_1 as decimal(5,2)) as decimal(5,2)) as fraction
from count_players c 
cross join (select count(distinct player_id)as count_player_id_1 from activity)a
/*Write a solution to calculate the number of unique subjects each teacher teaches in the university.
Return the result table in any order.*/
select teacher_id, count(distinct subject_id) as cnt from Teacher
group by teacher_id
/*Write a solution to find the daily active user count for a period of 30 days ending 2019-07-27 inclusively. 
A user was active on someday if they made at least one activity on that day.
Return the result table in any order.*/
select activity_date as day, count(distinct user_id)active_users
from Activity
where activity_date between dateadd(dd,-29,'2019-07-27') and '2019-07-27'
group by activity_date
/*Write a solution to select the product id, year, quantity, and price for the first year of every product sold.
Return the resulting table in any order.The result format is in the following example.*/
select product_id, first_year,quantity,price
from
(
select s.product_id, s.year as first_year, s.quantity ,s.price ,
Row_number()over(partition by s.product_id order by Year asc )as rw
from sales s 
)r
where r.rw=1
/*Write a solution to find managers with at least five direct reports.
Return the result table in any order.
The result format is in the following example.*/
select name from employee
where id in (
select managerid from employee
group by managerid
having count(distinct id)>=5)
/*(sale_id, year) is the primary key (combination of columns with unique values) of this table.
product_id is a foreign key (reference column) to Product table.
Each row of this table shows a sale on the product product_id in a certain year.
Note that the price is per unit.
product_id is the primary key (column with unique values) of this table.
Each row of this table indicates the product name of each product.*/

select s.product_id,p.year as First_Year, quantity,(price) as price
from sales s 
inner join (select min(Year)as Year,product_id from sales
group by product_id
)p
on p.product_id=s.product_id
and p.year=s.year
/* 
Table: Customer
Column Name | Type    |
+-------------+---------+
| customer_id | int     |
| product_key | int  
This table may contain duplicates rows. 
customer_id is not NULL.
product_key is a foreign key (reference column) to Product table.
Table: Product
+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| product_key | int     |
+-------------+---------+
product_key is the primary key (column with unique values) for this table.*/

; With customer_I as
(select customer_id,count(distinct product_key) Product_Key_count
from customer
group by customer_id)
select customer_id from customer_I
where Product_Key_count in(select count(distinct product_key) from product)

/*Second Highest Salary*/

select DISTINCT Salary as SecondHighestSalary
 from
(
SELECT Dense_rank()over(order by Salary desc)as rk,*
from Employee)r
where r.rk=2
UNION
SELECT NULL
WHERE NOT EXISTS (
    SELECT 1 FROM (
SELECT Dense_rank()over(order by Salary desc)as rk,*
from Employee)r
where r.rk=2
);

/*+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| id          | int     |
| num         | varchar |
+-------------+---------+
In SQL, id is the primary key for this table.
id is an autoincrement column starting from 1.
 

Find all numbers that appear at least three times consecutively.

Return the result table in any order.*/
select distinct num as ConsecutiveNums  from 
(
select lag(num,1)over(order by id)as lg,lead(num,1)over(order by id)as ld,* from Logs)r
where r.lg=r.num
and r.ld=r.num

/*626. Exchange Seats*/
Select 
ID,
Case when ID_1=1
    then isnull(ld,Student)
    Else isnull(lg,Student)
end as student
from 
(
SELECT lead(Student,1)over(order by ID)as ld,ID%2 as ID_1,
lag(Student,1)over(order by ID)as lg,
* FROM SEAT
)r

/*Movie Rating*/
;with reviews_count as
(select user_id,count(movie_id)as review_count
from MovieRating
group by user_id
)
, avgrating as
(
select avg(rating)as avg_rating,movie_id from MovieRating
group by movie_id
),Review_User as
(
select min(u.[name])as [Results] 
from reviews_count r
inner join Users u
on r.User_id=u.User_id
where review_count =(select max(review_count) from reviews_count)
),max_rating as
(
select max(m.title) as Results
from Movies m inner join avgrating a
on m.movie_id=a.movie_id
where avg_rating=(select max(avg_rating) from avgrating)
)
select * from Review_User
union 
select * from max_rating

/*(product_id, change_date) is the primary key (combination of columns with unique values) of this table.
Each row of this table indicates that the price of some product was changed to a new price at some date.
 

Write a solution to find the prices of all products on 2019-08-16. Assume the price of all products before any change is 10.

Return the result table in any order.

The result format is in the following example.
*/
; with a2 as 
(
    select 
    product_id,
    case when change_date<='2019-08-16'
        then new_price
    else NULL end as price,change_date,new_price
    from products
    where CHANGE_DATE BETWEEN '1900-01-01' and '2019-08-16'
),a3 as 
(
select distinct a2.product_id,
a2.price 
from 
a2 a2 inner join (
select product_id,max(change_date)change_date from a2
group by product_id) a1
on a2.product_id=a1.product_id
and a2.change_date=a1.change_date
)
select distinct
p.product_id,
case when a3.product_id is null then '10'
else a3.price end as price
from products p left join a3 a3
on a3.product_id=p.product_id

/*1484. Group Sold Products By The Date*/
/* Write your T-SQL query statement below */
select sell_date,count(distinct product)num_sold,STRING_AGG( product, ',') WITHIN GROUP (ORDER BY product) AS products
from (select distinct * from activities)r
group by sell_date
order by sell_date
