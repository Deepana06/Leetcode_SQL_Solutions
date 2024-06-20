/*Easy*/
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


