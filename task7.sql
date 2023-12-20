CREATE chema IF not exists task7_views;

set search_path = db_project, public;

--service view
create or replace view show_service as
	select service_name as "Название",
		description as "Описание",
		price as "Стоимость"
	from db_project.service;

select * from show_service;

--menu view 
create or replace view show_menu as
	select dish_name as "Название",
		description as "Описание",
		price as "Стоимость"
	from db_project.menu;

select * from show_menu;

--room view
create or replace view show_rooms as
	select room_name
	from db_project.room;
	
select * from show_rooms;

-- service_X_order view
create or replace view service_X_order_view as
	select substr(employees.first_name, 1, 4) || regexp_replace(substr(employees.first_name, length(employees.first_name) - 4), '\w', '*', 'g') || ' ' 
	|| substr(employees.last_name, 1, 4) || regexp_replace(substr(employees.last_name, length(employees.last_name) - 4), '\w', '*', 'g') as "Имя сотрудника",
	service_X_booking.start_time,
	service_X_booking.end_time
	from db_project.employees 
	inner join db_project.service_x_booking
	on employees.emp_id = service_x_booking.emp_id; 
	
select * from service_X_order_view;
	
-- employees_view TODO: why isn't working?
create or replace view employees_view as
	select substr(employees.first_name, 1, 4) || regexp_replace(substr(employees.first_name, length(employees.first_name) - 4), '\w', '*', 'g') as "Имя сотрудника",
	substr(employees.last_name, 1, 4) || regexp_replace(substr(employees.last_name, length(employees.last_name) - 4), '\w', '*', 'g') as "Фамилия сотрудника",
	periods.post as "Должность сотрудника",
	periods.salary as "Зарплата сотрудника"
from
	db_project.employees
	inner join db_project.periods
	on employees.emp_id = periods.emp_id
	where now()::date between periods.valid_to and periods.valid_from;
	
select * from employees_view;
	
--booking view
create or replace view booking_view as
	select substr(client.first_name, 1, 4) || regexp_replace(substr(client.first_name, length(client.first_name) - 4), '\w', '*', 'g') as "Имя клиента",
	substr(client.last_name, 1, 4) || regexp_replace(substr(client.last_name, length(client.last_name) - 4), '\w', '*', 'g') as "Фамилия клиента",
	booking.start_time,
	booking.end_time,
	room.room_name
from db_project.booking
inner join db_project.client
on booking.client_id = client.client_id
inner join db_project.room
on booking.room_id = room.room_id

select * from booking_view;


--client view
create or replace view client_view as
	select substr(client.first_name, 1, 4) || regexp_replace(substr(client.first_name, length(client.first_name) - 4), '\w', '*', 'g') as "Имя клиента",
	substr(client.last_name, 1, 4) || regexp_replace(substr(client.last_name, length(client.last_name) - 4), '\w', '*', 'g') as "Фамилия клиента", 
	1000000000000000 + (client.card_no >> 40)  as "Номер карты"
from db_project.client;

select * from client_view;

--menu_X_booking view
create or replace view menu_X_booking_view as
	select substr(client.first_name, 1, 4) || regexp_replace(substr(client.first_name, length(client.first_name) - 4), '\w', '*', 'g') as "Имя клиента", 
	substr(client.last_name, 1, 4) || regexp_replace(substr(client.last_name, length(client.last_name) - 4), '\w', '*', 'g') as "Фамилия клиента",
	booking.start_time as "Начало визита",
	booking.end_time as "Конец визита",
	menu.dish_name as "Название блюда",
	sum(menu_x_booking.amount) as "Количество"
from db_project.client
inner join db_project.booking
on client.client_id = booking.client_id
inner join db_project.menu_x_booking
on booking.order_id = menu_x_booking.order_id
inner join db_project.menu
on menu_x_booking.dish_id = menu.dish_id
group by client.client_id, menu.dish_id, booking.order_id;

select * from menu_x_booking_view;
