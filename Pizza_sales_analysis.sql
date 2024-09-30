create database pizzahut;
use pizzahut;
create table orders	(
order_id int not null,
order_date date not null,
order_time time not null, 
primary key (order_id));


create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id));


select * from order_details;
select * from orders;
select * from pizza_types;
select * from pizzas;

#-----------------questions------------------#
# Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS 
    `total number of orders placed`
FROM
    orders;


# Calculate the total revenue generated from pizza sales.
SELECT 
    FORMAT(SUM((quantity) * (price)), 2) AS 
    `total revenue generated`
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;


select round(sum((quantity)*(price)),2) as `total revenue generated` from order_details
join pizzas on
order_details.pizza_id = pizzas.pizza_id;


# Identify the highest-priced pizza.
SELECT 
    pizza_types.name AS `pizza name`,
    CONCAT('$', ' ', MAX(price)) AS `price`
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY `pizza name`
ORDER BY MAX(price) DESC
LIMIT 1; 





# Identify the most common pizza size ordered.
SELECT 
    size,
    FORMAT(COUNT(order_details_id), 2) AS `total quantity ordered`
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY size
ORDER BY COUNT(order_details_id) DESC;





# List the top 5 most ordered pizza types along with their quantities.

select * from order_details;
select * from orders;
select * from pizza_types; 
select * from pizzas;
#----------------------------------------#

SELECT 
    `name`, SUM(order_details.quantity) AS `total quantity`
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY `name`
ORDER BY `total quantity` DESC
LIMIT 5;


# Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS `total quantity`
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY 1;



# Determine the distribution of orders by hour of the day.
SELECT 
    *
FROM
    orders;
SELECT 
    EXTRACT(HOUR FROM order_time) AS hour,
    COUNT(order_id) AS total_orders
FROM
    orders
GROUP BY 1;

#alternatively
select hour(order_time) as hour, 
count(order_id) as total_orders from orders
group by 1;





# Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    *
FROM
    pizza_types;
SELECT 
    category, COUNT(name) AS `category count`
FROM
    pizza_types
GROUP BY category;




# Group the orders by date and calculate the average number of pizzas ordered per day.
select * from orders;
select * from order_details;

SELECT 
    ROUND(AVG(`orders count`), 0) AS `average quantity ordered`
FROM
    (SELECT 
        order_date, COUNT(order_details.order_id) AS `orders count`
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY 1) AS Order_quantity;




# Determine the top 3 most ordered pizza types based on revenue.
select * from pizzas;
select * from pizza_types;
select * from order_details;
SELECT 
    `name`,
    FORMAT(SUM(pizzas.price * order_details.quantity),
        2) AS `total sales`
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY `name` , category
ORDER BY `total sales` DESC
LIMIT 3;









# Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    CONCAT(ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                            SUM(order_details.quantity * pizzas.price)
                        FROM
                            order_details
                                JOIN
                            pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
                    2),
            '%') AS percentage_contribution
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;


# Analyze the cumulative revenue generated over time.
select order_date, round(sum(revenue) over(order by order_date),1) as `cumulative revenue`
from 
(select orders.order_date, 
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas on
order_details.pizza_id = pizzas.pizza_id
join orders on 
orders.order_id = order_details.order_id
group by 1) as sales;





# Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select * from pizzas;
select * from pizza_types;
select * from order_details;

select name,category, revenue from
(select name, category,revenue, dense_rank() over(partition by category order by revenue desc) as rnk from
(select pizza_types.name, pizza_types.category, sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas on 
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on 
order_details.pizza_id = pizzas.pizza_id
group by 1,2) as a) as b
where rnk <=3;

# so we get the category wise top 3 selling pizzas 