set search_path = db_project, public;

--drop function if exists assert_free;
create or replace function assert_free() 
returns trigger as 
	$$	
		declare 
			cnt int;
		begin
			execute('select count(*) 
				from service_X_booking
				where service_X_booking.emp_id = $1
				and (service_X_booking.end_time > $2 or service_X_booking.start_time < $3)') 
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

--insert into service_x_booking(service_id, order_id, emp_id, start_time, end_time) values
	--(1, 5, 1, '2023-12-21 13:00:00', '2023-12-21 16:00:00');
	

