set search_path = db_project, public;

--drop function if exists assert_free;
create or replace function assert_free() 
returns trigger as 
	$$	
		declare 
			cnt int := 0;
		begin
			execute('select count(*) 
				from service_X_booking
				where service_X_booking.emp_id = $1
				and (service_X_booking.end_time between $2 and $3 or service_X_booking.start_time between $2 and $3)') 
			into cnt using new.emp_id, new.start_time, new.end_time; 
			if cnt > 0 then 
					raise notice 'Данный рабочий в это время занят';
				return null;
			end if;
			return new;
		end;
	$$ language plpgsql;
	
--drop trigger if exists assert_free_trigger;
create or replace trigger assert_free_trigger
before insert on db_project.service_x_booking 
for each row
execute function assert_free();
-- 28-го декабря с 10 до 15 часов Миссис Рэтчед занята. Попробуем заказать её в другую комнату:
insert into service_x_booking(service_id, order_id, emp_id, start_time, end_time) values
	(3, 3, 1, '2023-12-28 13:00:00', '2023-12-28 16:00:00');
-- А 25-го декабря она свободна. Попробуем добавить её в 5 заказ:
insert into service_x_booking(service_id, order_id, emp_id, start_time, end_time) values
	(2, 5, 1, '2023-12-25 13:00:00', '2023-12-25 16:00:00');

--drop function if exists on_booking() cascade;
--create or replace function on_booking()
--returns trigger as 
	--$$
		--declare 
			--first_dish_id int;
			--second_dish_id int;
			--dishes_amount int;
		--begin
			--execute ('select count(*) from menu') into dishes_amount;
			--first_dish_id := floor(random() * (dishes_amount + 1));
			--second_dish_id = floor(random() * (dishes_amount + 1));
			--while first_dish_id = second_dish_id
				--loop
					--second_dish_id = floor(random() * (dishes_amount + 1));
				--end loop;
			--execute ('insert into menu_X_booking(dish_id, order_id, amount) values ($1, $2, 1), ($3, $2, 1);') 
			--using first_dish_id, new.order_id, second_dish_id;
			--return new;
		--end;
	--$$ language plpgsql;
	
	
--drop trigger if exists on_booking_trigger;

--create or replace trigger on_booking_trigger
--after insert on db_project.booking 	
--for each row 
--execute function on_booking();

--insert into booking(client_id, room_id, start_time, end_time) values 
	--(1, 1, '2023-12-27 10:00:00', '2023-12-27 12:00:00');
