set search_path = db_project, public;

--Прибыль, принесенная заведению каждым рабочим за какой то промежуток времени
drop view if exists employees_impact;
create or replace view employees_impact as
	select employees.first_name as "Имя рабочего",
	employees.last_name as "Фамилия рабочего",
	service_X_booking.start_time as "Начало слота",
	service_X_booking.end_time as "Конец слота",
	sum(service.price) over (partition by employees.emp_id order by service_X_booking.start_time) as cumulative_total
from db_project.employees
inner join db_project.service_x_booking
on employees.emp_id = service_x_booking.emp_id
inner join db_project.service 
on service.service_id = service_x_booking.service_id
where service_X_booking.end_time between date '2020-01-01' and '2024-01-01';
select * from employees_impact;

--Суммарное количество часов, проведенных каждым рабочим с каждым клиентом
drop view if exists clients_x_employees;
create or replace view clients_x_employees as
	select client.first_name as "Имя клиента",
		client.last_name as "Фамилия клиента",
		employees.first_name as "Имя рабочего",
		employees.last_name as "Фамилия рабочего",
		service_X_booking.start_time as "Начало слота",
		service_X_booking.end_time as "Конец слота",
		sum(extract(epoch from service_X_booking.end_time - service_X_booking.start_time) / 3600) over  (partition by client.client_id, employees.emp_id order by service_X_booking.start_time) as cumulative_total
from db_project.client
inner join db_project.booking
on client.client_id = booking.client_id 
inner join db_project.service_x_booking
on service_x_booking.order_id = booking.order_id 
inner join db_project.employees
on employees.emp_id = service_x_booking.emp_id;

select * from clients_x_employees;

-- Процентное соотношение затраченных на каждое блюдо денег для каждого клиента
drop view if exists menu_statistics;
create or replace view menu_statistics as
	select client.first_name as "Имя клиента ",
		client.last_name as "Фамилия клиента",
		menu.dish_name as "Название блюда",
		cast(cast(round(sum(menu.price * menu_X_booking.amount) / (
			select sum(sm) from (
				select sum(m.price * mxb.amount) as sm
				from db_project.menu_x_booking mxb 
				inner join db_project.menu m 
				on m.dish_id = mxb.dish_id 
				inner join booking b 
				on b.order_id = mxb.order_id 
				where b.client_id = client.client_id
				group by m.dish_id
			) as s
		), 2) * 100 as int) as text) || '%' as percentage 
from db_project.client
inner join db_project.booking
on client.client_id = booking.client_id 
inner join db_project.menu_x_booking 
on menu_x_booking.order_id = booking.order_id
inner join db_project.menu
on menu_x_booking.dish_id = menu.dish_id
group by client.client_id, menu.dish_id
order by client.client_id, menu.dish_id;

select * from menu_statistics;
