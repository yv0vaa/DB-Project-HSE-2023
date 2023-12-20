SET search_path = db_project, public;
--inserts into menu_X_booking
INSERT INTO menu_X_booking VALUES 
	(3, 6, 1),
	(4, 6, 2),
	(9, 6, 3),
	(2, 8, 1),
	(5, 8, 1),
	(7, 8, 2),
	(1, 10, 1),
	(5, 10, 1),
	(6, 10, 2);

--select from menu_X_booking блюда в 6 заказе
SELECT menu.dish_name 
	FROM menu INNER JOIN menu_X_booking
	ON menu.dish_id = menu_X_booking.dish_id
	WHERE menu_X_booking.order_id = 6;

-- update menu_X_booking table добавить ещё по 2 штуки 3 и 5 блюда
UPDATE menu_X_booking
	SET amount = amount + 2
	WHERE order_id = 6 
	AND dish_id = 3 OR dish_id = 5;
	
-- delete from menu_X_booking удалить блюдо, заказанное в одном экземпляре
delete from menu_x_booking 
	where order_id = 8 
	and amount = 1;  

-- inserts into service_X_booking
insert into service_X_booking(service_id, order_id, emp_id, amount, start_time, end_time) values 
	(2, 2, 2, '2023-12-31 21:00:00', '2024-01-01 11:00:00'),
	(5, 3, 1, '2023-12-21 12:00:00', '2023-12-21 21:00:00'),
	(7, 5, 2, '2023-12-25 18:00:00', '2023-12-26 02:00:00'),
	(8, 4, 2, '2023-12-24 19:00:00', '2023-12-24 23:00:00'),
	(4, 5, 4, '2023-12-23 16:00:00', '2023-12-23 19:00:00'),
	(3, 6, 1, '2023-12-23 18:00:00', '2023-12-23 20:00:00'),
	(5, 7, 2, '2023-12-31 23:00:00', '2024-01-01 03:00:00'),
	(1, 8, 3, '2023-12-25 16:00:00', '2023-12-25 19:00:00'),
	(8, 9, 1, '2023-12-28 10:00:00', '2023-12-28 15:00:00'),
	(2, 10, 2, '2023-12-30 20:00:00', '2023-12-31 07:00:00');
	
--select from service_X_booking облуга 7 заказа
select first_name, last_name 
	from employees 
	inner join service_X_booking
	on service_X_booking.emp_id = employees.emp_id 
	where order_id = 7;

-- service_X_booking updates поменять оказывающего услугу
update service_X_booking
	set service_id = 1
	where order_id = 1;

-- delete from service_X_booking отменить услугу
delete from service_X_booking
	where order_id = 7 and emp_id = 1;






