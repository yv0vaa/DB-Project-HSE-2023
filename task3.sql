-- schema
create schema if not exists db_project;
set SEARCH_path = db_project, public;

-- service table
--drop table if exists service cascade;
create table if not exists service (
  	service_id serial primary key,  
  	service_name text check(length(service_name) > 4),
  	description text check(length(description) > 4),  
  	price int check (price > 0)
);

-- menu table
--drop table if exists menu cascade;
create table if not exists menu (  
 	dish_id serial primary key,
  	dish_name text check(length(dish_name) > 4),  
  	description text check(length(description) > 4),
  	price int check (price > 0)  
);
 
-- room table
--drop table if exists room cascade;
create table if not exists room (
   	room_id serial primary key,   
   	room_name text check(length(room_name) > 4)
);
 
-- client table
--drop table if exists client cascade;
create table if not exists client (
 	client_id serial primary key,
   	first_name text check(length(first_name) > 1),   
   	last_name text check(length(last_name) > 1),
   	card_no bigint check(card_no between 999999999999999 and 10000000000000000)  
);

-- employee table
--drop table if exists employees cascade;
create table if not exists employees (
   	emp_id serial primary key,   
   	first_name text check(length(first_name) > 1),
   	last_name text check(length(last_name) > 1)        
);

--period table
--drop table if exists periods cascade;
create table if not exists periods (
	emp_id int,
	salary int check(salary >= 0),
	post text check(length(post) > 4),
	valid_from date default current_date,
	valid_to date default '2100-01-01' check (valid_from <= valid_to)
);
alter table periods add constraint emp_id foreign key (emp_id) references employees(emp_id) on update cascade on delete cascade; 

-- booking table
--drop table if exists booking cascade; 
create table if not exists booking (  
 	order_id serial primary key,
  	client_id int,    
  	room_id int,
    create_time date DEFAULT current_date,    
    start_time timestamp not null,
    end_time timestamp not NULL CHECK (start_time <= end_time)    
);
alter table booking add constraint client_id foreign key (client_id) references client(client_id) on update cascade on delete cascade;
alter table booking add constraint room_id foreign key (room_id) references room(room_id) on update cascade on delete cascade;  

-- service_X_booking table
--drop table if exists service_X_booking cascade; 
create table if not exists service_X_booking (   
 	service_id int,
  	order_id int,    
  	emp_id int,    
    start_time timestamp not null,
    end_time timestamp not null check(start_time <= end_time),
    primary key(emp_id, order_id)
);
alter table service_X_booking add constraint service_id foreign key (service_id) REFERENCES service(service_id) on update cascade on delete cascade; 
alter table service_X_booking add constraint order_id foreign key (order_id) REFERENCES booking(order_id)on update cascade on delete cascade;
alter table service_X_booking add constraint emp_id foreign key (emp_id) REFERENCES employees(emp_id) on update cascade on delete cascade; 

-- menu_X_booking table
--drop table if exists menu_X_booking; 
create table if not exists menu_X_booking (
   	dish_id int,
   	order_id int,
    amount int check(amount >= 0),
    primary key(dish_id, order_id)
);
alter table menu_X_booking add constraint dish_id foreign key (dish_id) REFERENCES menu(dish_id) on update cascade on delete cascade;
alter table menu_X_booking add constraint order_id foreign key (order_id) REFERENCES booking(order_id) on update cascade on delete cascade;
