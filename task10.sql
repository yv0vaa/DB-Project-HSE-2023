set search_path = db_project, public;

--drop procedure if exists make_discount;
create or replace procedure  make_discount(total_sum int, discount_start timestamp, discount_end timestamp) as 
$$
	declare 
		o_id int;
		d_id int;
	begin
		for o_id in (select order_id from booking where booking.end_time between discount_start and discount_end)
		loop 
			if (select sum(menu_X_booking.amount * menu.price) 
				from menu_X_booking
				inner join menu
				on menu_X_booking.dish_id = menu.dish_id
				where menu_X_booking.order_id = o_id
				group by menu_X_booking.order_id) > total_sum then 
					for d_id in (select menu_X_booking.dish_id from menu_X_booking where menu_X_booking.order_id = o_id)
					loop 
						execute('update menu_X_booking set amount = greatest(amount - 1, 0) where order_id = $1 and dish_id = $2') using o_id, d_id; 
					end loop;
			end if;
		end loop;
	end
$$ language plpgsql;
--31-го декабря есть заказ, в котором у блюд с номерами 1, 5, 6 количества 1, 3, 2 соответственно
--Ожидается, что станет 0, 2, 1
call make_discount(1000, '2023-12-31 00:00:00', '2023-12-31 10:00:00');
--Проверим, что если скидка от заказа на 100 т.р., то ничего не изменится
call make_discount(100000, '2023-12-31 00:00:00', '2023-12-31 10:00:00');

--drop procedure if exists make_order;
create or replace procedure make_order(client_id int, new_start_time timestamp, new_end_time timestamp, service_id int) 
as $$
	declare 
		free_room_id int := -1;
		free_emp_id int := -1;
		dish_id int;
		dishes_amount int;
		new_order_id int;
		rm_id int;
		e_id int;
	begin 
		for rm_id in (select room_id from room)
		loop	
			if (select distinct booking.room_id 
				from booking 
				where (booking.start_time between new_start_time and new_end_time or booking.end_time between new_start_time and new_end_time) and booking.room_id = rm_id limit 1) is null then 
				free_room_id := rm_id;
				exit;
			end if;
		end loop;
		if free_room_id = -1 then
			raise exception 'Все комнаты заняты';
		end if;
		execute('insert into booking(client_id, room_id, start_time, end_time) values($1, $2, $3, $4);') using client_id, free_room_id, new_start_time, new_end_time;
		execute('select b.order_id from booking b where b.client_id = $1 and b.start_time = $2 and b.end_time = $3;') into new_order_id using client_id, new_start_time, new_end_time;
		for e_id in (select emp_id from employees)
		loop
			if (select distinct service_X_booking.emp_id 
				from service_X_booking 
				where (service_X_booking.start_time between new_start_time and new_end_time or service_X_booking.end_time between new_start_time and new_end_time) and service_X_booking.emp_id = e_id limit 1) is null then
				free_emp_id := e_id;
				exit;
			end if;
		end loop;
		if free_emp_id = -1 then
			raise notice 'Увы, все рабочие заняты';
			execute('select count(*) from menu') into dishes_amount;
			dish_id := floor(random() * (dishes_amount + 1)) + 1;
			execute('insert into menu_X_booking(dish_id, order_id, amount) values($1, $2, 1);') using dish_id, new_order_id;
		else 
			execute('insert into service_X_booking(service_id, order_id, emp_id, start_time, end_time) values($1, $2, $3, $4, $5);') 
				using service_id, new_order_id, free_emp_id, new_start_time, new_end_time;
		end if;
	end;
	$$ language plpgsql;
	
call make_order(10, '2020-12-22 00:00:00', '2020-12-22 10:00:00', 3);
