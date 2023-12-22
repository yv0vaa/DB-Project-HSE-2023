SET search_path = db_project;

-- В результате запроса 0 будет выведено сколько блюд каждого типа купил каждый клиент
select client.first_name,
	client.last_name,
	menu.dish_name,
	sum(menu_X_booking.amount) as total
from client
inner join booking
on client.client_id = booking.client_id
inner join menu_x_booking
on booking.order_id = menu_X_booking.order_id
inner join menu
on menu.dish_id = menu_X_booking.dish_id
group by client.client_id, menu.dish_id 
order by client.client_id;

-- В результате запроса 1 будет получена сводка по количеству проданных блюд в фиксированную дату
select menu.dish_name,
	sum(menu_x_booking.amount) as sold
from menu
inner join menu_x_booking
on menu.dish_id = menu_x_booking.dish_id 
inner join booking 
on menu_x_booking.order_id = booking.order_id 
and booking.end_time::date = date '2023-12-21'
group by menu.dish_id
order by sold;
	 
--В результате запроса 2 будет выведен список блюд и услуг в порядке возрастания их популярности
select menu.dish_name, 
	sum(menu_x_booking.amount)  as ordered
from menu
inner join menu_x_booking
on menu.dish_id = menu_x_booking.dish_id
group by menu.dish_id 
union all 
select service.service_name, 
	count(*) as ordered
from service
inner join service_x_booking 
on service.service_id  =service_x_booking.service_id
group by service.service_id 
order by ordered;

-- В результате запроса 3 будет выведено суммарное число часов, отработанных каждым рабочим
select employees.first_name,
	employees.last_name, 
	service_X_booking.end_time, 
	sum(extract(epoch from service_x_booking.end_time - service_x_booking.start_time) / 3600.00)  over (partition by employees.emp_id order by service_x_booking.start_time) as cumulative_hours
from employees
inner join service_x_booking
on employees.emp_id = service_x_booking.emp_id;

-- В результате запроса 4 будет получен список актуальных на какой-то конкретный период должностей и зарплат по работникам
select employees.first_name,
	employees.last_name,
	periods.salary,
	periods.post,
	greatest (date '2020-10-10', periods.valid_from) as valid_from,
	least (date '2023-12-12', periods.valid_to) as valid_to
from employees 
inner join periods
on employees.emp_id = periods.emp_id 
where date '2020-10-10' < periods.valid_to and date '2023-12-12' > periods.valid_from;

--В результате запроса 5 будет получена информация о прибыли от каждого блюда в процентах
select menu.dish_name,
	cast(cast(round(sum(menu.price * menu_x_booking.amount) / (
		select sum(summ) from(
			select sum(menu.price * menu_x_booking.amount) as summ
			from menu
			inner join menu_x_booking
			on menu.dish_id = menu_x_booking.amount
			group by menu.dish_id
		) 	as s
	), 2) * 100 as int) as text) || '%' as percentage
from menu
inner join menu_x_booking
on menu.dish_id = menu_x_booking.dish_id 
group by menu.dish_name;

-- В результате запроса 6 будут выведена сводка по общим затратам каждого клиента
select  client.first_name,
	client.last_name,
	rank() over (order by sum(menu.price * menu_x_booking.amount + service.price)) as "rank",
	sum(menu.price * menu_x_booking.amount + service.price) as total
from client
inner join booking 
on client.client_id = booking.client_id 
inner join service_x_booking
on service_x_booking.order_id = booking.order_id 
inner join service
on service.service_id = service_x_booking.service_id 
inner join menu_x_booking 
on menu_x_booking.order_id = booking.order_id 
inner join menu 
on menu.dish_id = menu_x_booking.dish_id
group by client.client_id; 
 
